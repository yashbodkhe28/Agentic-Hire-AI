# 🏗️ AgentHire AI — Detailed System Architecture

## Table of Contents
1. [Architectural Philosophy — Why Microservices?](#1-architectural-philosophy)
2. [Full System Diagram](#2-full-system-diagram)
3. [Service Registry — Netflix Eureka](#3-service-registry--netflix-eureka)
4. [API Gateway — Single Entry Point](#4-api-gateway)
5. [Security Architecture — JWT Deep Dive](#5-security-architecture--jwt-deep-dive)
6. [Config Server — Centralized Configuration](#6-config-server)
7. [Event-Driven Architecture — Apache Kafka](#7-event-driven-architecture--apache-kafka)
8. [Caching Strategy — Redis](#8-caching-strategy--redis)
9. [RBAC Design — Role-Based Access Control](#9-rbac-design)
10. [Database Architecture — 22 Tables](#10-database-architecture)
11. [AI Agent Architecture](#11-ai-agent-architecture)
12. [Observability Stack](#12-observability-stack)
13. [Docker & Deployment](#13-docker--deployment)

---

## 1. Architectural Philosophy

### Monolith vs Microservices — Why I Chose Microservices

A **monolith** puts everything in one deployable unit:
```
MONOLITH:
  agenthire-app.jar
  ├── AuthModule
  ├── JobModule
  ├── CandidateModule
  ├── InterviewModule
  └── AIModule

  Problems:
  - Scale the WHOLE app even if only AI is under load
  - One bug in AI module brings down entire system
  - Deploying a small change requires redeploying EVERYTHING
  - All teams share the same codebase → merge conflicts, coupling
```

A **microservices** architecture distributes responsibilities:
```
MICROSERVICES:
  auth-service.jar     ← scales independently
  recruiter-service.jar ← scales independently
  agent-service.jar    ← scale THIS when AI is busy
  interview-service.jar ← scale independently

  Benefits:
  ✅ Scale only what needs scaling
  ✅ Failure isolation — AI crash doesn't break login
  ✅ Deploy changes to one service without touching others
  ✅ Teams own their service independently
  ✅ Different services can use different languages/DBs if needed
```

**Trade-offs I had to handle:**
- **Service Discovery**: How do services find each other? → Eureka
- **Distributed Configuration**: 11 services × config files → Config Server
- **Cross-service communication**: How to call other services? → REST via Gateway or Kafka events
- **Debugging**: Errors span multiple services → Zipkin distributed tracing
- **Auth**: Every service needs to know who the user is → JWT headers injected by Gateway

---

## 2. Full System Diagram

```
┌────────────────────────────────────────────────────────────────────────────────────┐
│                                  BROWSER / CLIENT                                   │
│                             http://localhost:8090                                   │
└────────────────────────────────────┬───────────────────────────────────────────────┘
                                     │ HTTP (page navigation)
┌────────────────────────────────────▼───────────────────────────────────────────────┐
│                          WEBAPP — Apache Tomcat (port 8090)                         │
│                                                                                     │
│  JSP Templates:  login.jsp | register.jsp | dashboard.jsp | jobs.jsp               │
│                  candidates.jsp | interviews.jsp | analytics.jsp | agents.jsp       │
│                                                                                     │
│  Static Assets:  /static/css/style.css   (glassmorphism dark theme)                │
│                  /static/js/app.js       (API helper, auth, routing)                │
│                                                                                     │
│  Spring MVC Controllers map URL paths to JSP views:                                 │
│    /dashboard → dashboard.jsp                                                       │
│    /jobs      → jobs.jsp                                                            │
│    /agents    → agents.jsp                                                          │
│                                                                                     │
│  Fetch API calls from JS:  GET/POST /api/**  →  API Gateway                        │
└────────────────────────────────────┬───────────────────────────────────────────────┘
                                     │ /api/** HTTP via Fetch API
                                     │
┌────────────────────────────────────▼───────────────────────────────────────────────┐
│                     API GATEWAY — Spring Cloud Gateway (port 8080)                  │
│                              (Reactive / WebFlux-based)                             │
│                                                                                     │
│  Filter Chain (executes in order for every request):                                │
│  ┌──────────────────────────────────────────────────────────────────────────────┐   │
│  │ 1. RequestLoggingFilter    — log method, path, timestamp                     │   │
│  │ 2. RateLimitingFilter      — Redis sliding window, 100 req/min per IP        │   │
│  │ 3. JwtAuthenticationFilter — validate JWT, check blacklist, inject headers   │   │
│  │    ┌──────────────────────────────────────────────────────────────────────┐  │   │
│  │    │ Skip auth for: /api/auth/login, /api/auth/register, /actuator/**     │  │   │
│  │    │ Extract: Authorization: Bearer <token>                                │  │   │
│  │    │ Validate: HMAC-SHA256 signature with JWT_SECRET                       │  │   │
│  │    │ Check: token expiry (exp claim)                                        │  │   │
│  │    │ Check: Redis blacklist (was this token used to logout?)               │  │   │
│  │    │ Inject: X-User-Id, X-User-Email, X-User-Role into request headers    │  │   │
│  │    └──────────────────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  Routing Table:                                                                     │
│  ┌────────────────────────────────────────────────────────────────────────┐         │
│  │  /api/auth/**          → lb://AUTH-SERVICE       (load balanced)       │         │
│  │  /api/candidates/**    → lb://CANDIDATE-SERVICE                        │         │
│  │  /api/jobs/**          → lb://RECRUITER-SERVICE                        │         │
│  │  /api/applications/**  → lb://RECRUITER-SERVICE                        │         │
│  │  /api/recruiters/**    → lb://RECRUITER-SERVICE                        │         │
│  │  /api/interviews/**    → lb://INTERVIEW-SERVICE                        │         │
│  │  /api/coding/**        → lb://LIVE-CODING-SERVICE                      │         │
│  │  /api/agents/**        → lb://AGENT-SERVICE                            │         │
│  │  /api/notifications/** → lb://NOTIFICATION-SERVICE                    │         │
│  │  /api/analytics/**     → lb://ANALYTICS-SERVICE                        │         │
│  └────────────────────────────────────────────────────────────────────────┘         │
│                                                                                     │
│  Circuit Breaker (Resilience4j):                                                    │
│  If a service is down, gateway returns fallback response instead of hanging         │
└────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬─────────────┘
     │          │          │          │          │          │          │
     ▼ :8081    ▼ :8082    ▼ :8083    ▼ :8084    ▼ :8085    ▼ :8086    ▼ :8087
┌─────────┐┌─────────┐┌─────────┐┌─────────┐┌─────────┐┌─────────┐┌──────────────┐
│  AUTH   ││CANDIDATE││RECRUITER││INTERVIEW││  LIVE   ││  AGENT  ││NOTIFICATION  │
│ SERVICE ││ SERVICE ││ SERVICE ││ SERVICE ││ CODING  ││ SERVICE ││  SERVICE     │
│         ││         ││         ││         ││ SERVICE ││         ││              │
│Register ││Profiles ││ Jobs    ││Schedule ││ Code    ││Resume   ││Kafka Consumer│
│Login    ││Resumes  ││ Apply   ││ Track   ││ Run     ││Analyze  ││Send Alerts   │
│JWT Gen  ││ Skills  ││Shortlist││Evaluate ││ Submit  ││ Match   ││Store Notif.  │
│Refresh  ││ Certs   ││Analytics││         ││         ││Gen Ques ││              │
│Logout   ││         ││         ││         ││         ││ Eval    ││              │
└────┬────┘└────┬────┘└────┬────┘└────┬────┘└─────────┘└────┬────┘└──────────────┘
     │          │          │          │                      │
     └──────────┴──────────┴──────────┴──────────────────────┘
                                  │
              ┌───────────────────▼──────────────────────────┐
              │           MySQL 8.0  (port 3306)              │
              │            Database: agenthire_db             │
              │                  22 Tables                    │
              │                                               │
              │  users  roles  refresh_tokens  login_history  │
              │  candidates  candidate_skills  resumes        │
              │  recruiters  companies  jobs  job_skills      │
              │  job_applications  interviews  agent_reports  │
              │  coding_sessions  notifications  audit_logs   │
              └───────────────────────────────────────────────┘

              ┌──────────────────┐       ┌──────────────────────────────────────┐
              │   Redis (6379)   │       │         Apache Kafka (9092)          │
              │                  │       │                                      │
              │ Key: blacklist:  │       │  Topics:                             │
              │   <token>        │       │  ┌────────────────┐                  │
              │ Value: "revoked" │       │  │  user-events   │ ← auth-service   │
              │ TTL: remaining   │       │  │  USER_REGISTERED│   publishes     │
              │   token life     │       │  │  USER_LOGGED_IN │                  │
              │                  │       │  └────────┬───────┘                  │
              │ Also: Rate limit │       │           │ notification-service      │
              │ counters per IP  │       │           ▼ consumes                 │
              └──────────────────┘       │  ┌────────────────────┐              │
                                         │  │ interview-events   │              │
                                         │  │ INTERVIEW_SCHEDULED│              │
                                         │  └────────────────────┘              │
                                         └──────────────────────────────────────┘

              INFRASTRUCTURE SERVICES:
              ┌──────────────┐  ┌──────────────────┐  ┌────────────────────────┐
              │ EUREKA :8761 │  │ CONFIG SVR :8888  │  │   ZIPKIN :9411         │
              │              │  │                  │  │                        │
              │ Service      │  │ Serves config    │  │ Distributed Tracing    │
              │ Registry     │  │ .yml files for   │  │ Visualize request path │
              │ Health Check │  │ all 11 services  │  │ across services        │
              └──────────────┘  └──────────────────┘  └────────────────────────┘

              ┌────────────────────────┐  ┌──────────────────────────┐
              │  PROMETHEUS :9090      │  │  GRAFANA :3000           │
              │  Scrapes /actuator/    │  │  Dashboards for JVM,     │
              │  prometheus every 15s  │  │  requests, errors, etc.  │
              └────────────────────────┘  └──────────────────────────┘
```

---

## 3. Service Registry — Netflix Eureka

### The Problem It Solves
In a Docker Compose environment, each container gets an internal IP address like `172.20.0.5`. These IPs change every time you restart a container. Without a registry, you'd need to hardcode IPs in the gateway config — which breaks constantly.

### How Eureka Works
```
STARTUP SEQUENCE:
  1. eureka-server starts first (it's the registry itself)

  2. Every other service starts and sends a POST to Eureka:
     POST http://eureka-server:8761/eureka/apps/RECRUITER-SERVICE
     Body: { hostname: "recruiter", port: 8083, status: "UP" }

  3. Eureka stores this registration in memory

  4. API Gateway asks Eureka at startup:
     GET http://eureka-server:8761/eureka/apps
     → Gets all registered services with their addresses

  5. Gateway routes /api/jobs/** → http://172.20.0.5:8083/api/jobs/**

  6. Every 30 seconds, each service sends a heartbeat:
     PUT http://eureka-server:8761/eureka/apps/RECRUITER-SERVICE/recruiter
     → "I'm still alive"

  7. If heartbeat stops for 90 seconds → Eureka marks service DOWN
     → Gateway stops routing to that service

EUREKA DASHBOARD:
  http://localhost:8761
  Shows: all services, their instances, status (UP/DOWN), IP:port
```

### Configuration
```yaml
# Each service's application.yml:
eureka:
  client:
    service-url:
      defaultZone: http://eureka-server:8761/eureka/
    register-with-eureka: true
    fetch-registry: true
  instance:
    prefer-ip-address: true
    lease-renewal-interval-in-seconds: 10
    lease-expiration-duration-in-seconds: 30
```

---

## 4. API Gateway

### Why a Gateway?
Without a gateway, the frontend would need to know the address of every microservice:
```
// WITHOUT GATEWAY (bad):
fetch('http://auth-service:8081/api/auth/login')
fetch('http://recruiter-service:8083/api/jobs')
fetch('http://agent-service:8086/api/agents/execute')
// Frontend needs to know all service addresses → security nightmare

// WITH GATEWAY (good):
fetch('/api/auth/login')    // always hits gateway
fetch('/api/jobs')          // gateway routes to recruiter-service
fetch('/api/agents/execute')// gateway routes to agent-service
// Frontend only knows one address → gateway handles the rest
```

### JWT Filter Logic (Step by Step)
```java
@Component
public class JwtAuthenticationFilter implements GlobalFilter, Ordered {

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getPath().value();

        // 1. Skip auth for public endpoints
        List<String> publicPaths = List.of("/api/auth/login", "/api/auth/register",
                                           "/api/auth/refresh", "/actuator");
        if (publicPaths.stream().anyMatch(path::startsWith)) {
            return chain.filter(exchange); // pass through without JWT check
        }

        // 2. Extract token from Authorization header
        String authHeader = exchange.getRequest().getHeaders().getFirst("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
        String token = authHeader.substring(7); // remove "Bearer "

        // 3. Validate JWT signature and expiry
        Claims claims = Jwts.parser()
            .verifyWith(secretKey)
            .parseSignedClaims(token)
            .getPayload(); // throws if invalid or expired

        // 4. Check Redis blacklist (was this token revoked at logout?)
        if (Boolean.TRUE.equals(redisTemplate.hasKey("blacklist:" + token))) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        // 5. Inject user info as headers for downstream services
        ServerHttpRequest mutatedRequest = exchange.getRequest().mutate()
            .header("X-User-Id",    claims.get("userId").toString())
            .header("X-User-Email", claims.getSubject())
            .header("X-User-Role",  claims.get("role").toString())
            .build();

        return chain.filter(exchange.mutate().request(mutatedRequest).build());
    }
}
```

---

## 5. Security Architecture — JWT Deep Dive

### What is JWT?
JSON Web Token is a compact, self-contained token that securely transmits information between parties.

```
Structure: HEADER.PAYLOAD.SIGNATURE

HEADER (Base64 encoded):
{
  "alg": "HS256",   ← algorithm: HMAC-SHA256
  "typ": "JWT"      ← token type
}

PAYLOAD (Base64 encoded):
{
  "sub": "user@example.com",    ← subject (email)
  "userId": 24,                  ← custom claim
  "role": "CANDIDATE",           ← custom claim
  "iat": 1750000000,             ← issued at (Unix timestamp)
  "exp": 1750086400              ← expiry (24 hours later)
}

SIGNATURE:
  HMAC-SHA256(
    base64(header) + "." + base64(payload),
    JWT_SECRET                               ← only the server knows this
  )
```

### Why JWT is Tamper-Proof
If an attacker modifies the payload (e.g., changes `"role": "CANDIDATE"` to `"role": "RECRUITER"`), the signature check fails because the signature was computed on the original payload. The server rejects it.

### Token Generation (auth-service)
```java
@Service
public class JwtTokenProvider {

    @Value("${JWT_SECRET}")
    private String jwtSecret;

    @Value("${JWT_EXPIRATION_MS:86400000}")
    private long jwtExpirationMs; // 24 hours

    public String generateAccessToken(UserDetails userDetails) {
        User user = (User) userDetails;

        return Jwts.builder()
            .subject(user.getEmail())
            .claim("userId", user.getId())
            .claim("role", user.getRole().getName().name())
            .issuedAt(new Date())
            .expiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
            .signWith(getSigningKey())
            .compact();
    }

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtSecret));
    }
}
```

### Logout — Token Blacklisting with Redis
```java
// On logout:
public void logout(String token) {
    // Get remaining time-to-live of the token
    Claims claims = parseToken(token);
    long remainingTtlMs = claims.getExpiration().getTime() - System.currentTimeMillis();

    // Store in Redis with TTL — key auto-deletes when token would have expired anyway
    redisTemplate.opsForValue().set(
        "blacklist:" + token,     // key
        "revoked",                // value (doesn't matter)
        remainingTtlMs,           // TTL
        TimeUnit.MILLISECONDS
    );
}

// On every gateway request:
if (redisTemplate.hasKey("blacklist:" + token)) {
    return 401 Unauthorized;
}
```

**Why this is elegant:** We don't keep tokens in Redis forever — the TTL automatically cleans them up exactly when they would have expired anyway. Zero maintenance.

---

## 6. Config Server

### The Problem
11 services, each with their own `application.yml`. If you change the DB password or Kafka broker address, you'd need to update 11 files and redeploy 11 services.

### The Solution
```
Config Server fetches config from a central repository.
Each service asks Config Server for its config at startup.

config-server/src/main/resources/config-repo/
├── application.yml           ← shared by ALL services
│     - eureka.client.service-url
│     - management.endpoints (actuator)
│     - logging.level
├── auth-service.yml          ← only auth-service gets this
│     - JWT_SECRET, JWT_EXPIRATION_MS
│     - spring.datasource.*
│     - spring.redis.*
├── recruiter-service.yml     ← only recruiter-service gets this
│     - spring.datasource.*
│     - spring.kafka.bootstrap-servers
└── agent-service.yml         ← only agent-service gets this
      - ai.openai.api-key
      - ai.gemini.api-key
```

Each service's `bootstrap.yml`:
```yaml
spring:
  application:
    name: recruiter-service
  config:
    import: optional:configserver:http://config-server:8888
```
→ Service fetches `application.yml` + `recruiter-service.yml` from Config Server.

---

## 7. Event-Driven Architecture — Apache Kafka

### Sync vs Async Communication
```
SYNCHRONOUS (REST call):
  interview-service → POST http://notification-service/notify → waits for response
  Problem: If notification-service is DOWN → interview scheduling FAILS
  Problem: Slow notification → blocks interview-service thread

ASYNCHRONOUS (Kafka):
  interview-service → publish to Kafka topic → returns IMMEDIATELY
  notification-service reads from Kafka when ready
  Problem solved: notification failure doesn't break interview scheduling
```

### Kafka Key Concepts
```
TOPIC: A named channel (like a database table for messages)
  - user-events
  - interview-events

PARTITION: Topics are split into partitions for parallelism
  - Messages within a partition are ordered

PRODUCER: Service that writes to a topic
  - auth-service writes to user-events

CONSUMER: Service that reads from a topic
  - notification-service reads from user-events

OFFSET: Position of a message in a partition
  - Kafka remembers where each consumer group read up to
  - If consumer goes down and restarts, it continues from where it stopped
  - No message is lost

BROKER: Kafka server that stores messages
  - In our setup: one broker (for development)
  - Production: typically 3+ brokers for replication
```

### Implementation
```java
// Producer (in auth-service) — publish event
@Service
public class UserEventProducer {
    private final KafkaTemplate<String, Object> kafkaTemplate;

    public void publishUserRegistered(User user) {
        UserEvent event = UserEvent.builder()
            .eventType("USER_REGISTERED")
            .userId(user.getId())
            .email(user.getEmail())
            .role(user.getRole().getName().name())
            .timestamp(LocalDateTime.now())
            .build();

        kafkaTemplate.send("user-events", event);
        // Returns immediately — doesn't wait for consumer to process it
    }
}

// Consumer (in notification-service) — read and process
@Service
public class NotificationConsumer {

    @KafkaListener(topics = "user-events", groupId = "notification-group")
    public void handleUserEvent(UserEvent event) {
        // This runs ASYNCHRONOUSLY when event is available
        if ("USER_REGISTERED".equals(event.getEventType())) {
            notificationService.createWelcomeNotification(event.getUserId());
        }
    }
}
```

---

## 8. Caching Strategy — Redis

### Uses in AgentHire AI

**1. Token Blacklist (Logout)**
```
SET "blacklist:eyJhbGciOiJIUzI1NiJ9..." "revoked" EX 86400
EXISTS "blacklist:eyJhbGciOiJIUzI1NiJ9..."  → 0 or 1
```
O(1) lookup — microseconds. Doesn't add load to MySQL.

**2. Rate Limiting (API Gateway)**
```
Every request from IP 203.0.113.1:
  INCR "rate:203.0.113.1"  → 47
  If value == 1: EXPIRE "rate:203.0.113.1" 60  (first request → set 1 minute TTL)
  If value > 100: return 429 Too Many Requests
```
Sliding window counter per IP, auto-resets every minute.

**3. Refresh Tokens**
```
Refresh tokens stored in Redis with TTL = 7 days
Much faster than MySQL lookup for every token refresh operation
```

---

## 9. RBAC Design

### Role Assignment
```
Registration form → user selects RECRUITER or CANDIDATE
→ stored in users.role_id FK → roles table (RECRUITER=2, CANDIDATE=3)
→ embedded in JWT: { "role": "CANDIDATE" }
→ persisted across all sessions
```

### Three-Layer Enforcement
```
LAYER 1 — JWT CLAIM:
  Role stored in token → can't be changed without new login
  Gateway extracts and forwards as X-User-Role header

LAYER 2 — BACKEND QUERY FILTER:
  Candidate calls GET /api/applications/candidate/{userId}
  Backend does: WHERE candidate_id = {userId from JWT}
  Cannot pass another user's ID to access their data
  (JWT-extracted userId overrides URL parameter where critical)

LAYER 3 — FRONTEND UI:
  JavaScript checks localStorage user role:
    if (user.role === 'CANDIDATE') {
      // Hide: Analytics link, Candidates link, AI Agents link
      window._candidateMode = true;
      document.querySelectorAll('.recruiter-only').forEach(el => el.hidden = true);
    }
  Note: This is UX only — backend is the real security gate
```

### What Each Role Can Access
```
ENDPOINT                         RECRUITER   CANDIDATE
GET /api/jobs                       ✅          ✅
POST /api/jobs                      ✅          ❌
GET /api/applications/candidate/N   ✅          ✅ (own N only)
GET /api/applications/shortlisted   ✅          ❌
PUT /api/applications/{id}/status   ✅          ❌
POST /api/interviews                ✅          ❌
GET /api/interviews/{id}            ✅          ✅ (own only)
POST /api/agents/execute/**         ✅          ❌
GET /api/applications/analytics     ✅          ❌
```

---

## 10. Database Architecture

### Entity Relationships (Key FKs)
```
users (1) ─────────── (0..1) candidates
users (1) ─────────── (0..1) recruiters
recruiters (N) ─────── (1) companies
recruiters (1) ─────── (N) jobs
jobs (1) ────────────── (N) job_applications
jobs (1) ────────────── (N) job_skills
candidates (1) ─────── (N) job_applications
candidates (1) ─────── (N) candidate_skills
candidates (1) ─────── (N) resumes
job_applications (1) ── (N) interviews
interviews (1) ─────── (0..1) agent_reports
```

### Smart Use of MySQL Views
```sql
-- Instead of WHERE deleted_at IS NULL everywhere:
CREATE VIEW active_users AS
  SELECT * FROM users WHERE deleted_at IS NULL;

CREATE VIEW active_jobs AS
  SELECT * FROM jobs WHERE status = 'ACTIVE' AND deleted_at IS NULL;

-- Now queries are cleaner:
SELECT * FROM active_jobs WHERE location LIKE '%Mumbai%';
```

### Native SQL for Analytics
```sql
-- Applications grouped by date (for timeline chart):
SELECT DATE_FORMAT(applied_at, '%Y-%m-%d') as date,
       COUNT(*) as count
FROM job_applications
WHERE applied_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE_FORMAT(applied_at, '%Y-%m-%d')
ORDER BY date;

-- Funnel counts (for doughnut chart):
SELECT status, COUNT(*) as count
FROM job_applications
GROUP BY status;
```

---

## 11. AI Agent Architecture

### Strategy Pattern Implementation
```java
// Interface — all agents implement this
public interface Agent {
    AgentType getType();
    String getName();
    AgentReport execute(AgentRequest request);
}

// Factory — creates the right agent
@Service
public class AgentFactory {
    private final Map<AgentType, Agent> agentMap;

    public AgentFactory(List<Agent> agents) {
        // Spring auto-injects all Agent beans
        agentMap = agents.stream()
            .collect(Collectors.toMap(Agent::getType, a -> a));
    }

    public Agent getAgent(AgentType type) {
        return agentMap.get(type);  // O(1) lookup
    }
}

// Context — executes the agent
@Service
public class AgentContext {
    private final AgentFactory agentFactory;

    public AgentReport executeAgent(AgentType type, AgentRequest request) {
        Agent agent = agentFactory.getAgent(type);
        return agent.execute(request);
    }
}
```

### LLM Provider with Fallback Chain
```java
// Strategy: OpenAI first (@Primary), Gemini fallback, then Mock
@Primary @Service
public class OpenAiProvider implements LlmProvider {
    public String chat(String systemPrompt, String userPrompt, double temperature) {
        if (isMockMode()) return mockResponse(systemPrompt, userPrompt);
        // Call OpenAI API...
    }
}

@Service
public class GeminiProvider implements LlmProvider {
    public String chat(String systemPrompt, String userPrompt, double temperature) {
        if (isMockMode()) return mockResponse(systemPrompt, userPrompt);
        // Call Gemini API...
    }
}
```

### Request Flow
```
POST /api/agents/execute/INTERVIEW_QUESTION_GENERATOR
Body: { payload: { jobTitle: "Backend Dev", experienceLevel: "MID", questionCount: 10 } }

  1. AgentController receives request
  2. AgentType.valueOf("INTERVIEW_QUESTION_GENERATOR") → enum
  3. AgentContext.executeAgent(INTERVIEW_QUESTION_GENERATOR, request)
  4. AgentFactory.getAgent(INTERVIEW_QUESTION_GENERATOR)
     → returns InterviewQuestionGeneratorAgent
  5. Agent builds:
     - systemPrompt: "You are an expert technical interviewer..."
     - userPrompt:   "Generate 10 questions for Backend Dev, MID level..."
  6. LlmProvider.chat(systemPrompt, userPrompt, 0.8)
     → OpenAI API call (or mock if no key)
  7. Result saved: AgentReport { agentType, referenceId, reportJson, score }
  8. Return: { success: true, reportId: 42, report: "{...JSON...}", score: 0 }
```

---

## 12. Observability Stack

### Prometheus + Grafana
```
Every Spring Boot service has Actuator enabled:
  management.endpoints.web.exposure.include: prometheus,health,info

Prometheus scrapes every 15 seconds:
  GET http://auth-service:8081/actuator/prometheus
  → Gets JVM memory, GC stats, HTTP request counts, response times

Grafana reads from Prometheus and visualizes:
  - Request rate per service
  - Error rate (5xx responses)
  - JVM heap usage
  - Active threads
  - Custom business metrics
```

### Zipkin Distributed Tracing
```
Problem: A request fails. Which of the 11 services caused it?

Solution: Micrometer adds a Trace ID to every request.
          Each service logs the Trace ID.
          Zipkin collects all spans and shows the full journey.

Example trace for GET /api/jobs:
  webapp (5ms) → api-gateway (12ms) → recruiter-service (45ms) → MySQL (32ms)
                                           ↑
                                       This is where it's slow!
```

---

## 13. Docker & Deployment

### Container Structure
```yaml
# docker-compose.yml — defines 20 containers

services:
  # Infrastructure
  mysql:           MySQL 8.0 database
  redis:           Redis 7 cache
  zookeeper:       Kafka's dependency
  kafka:           Apache Kafka broker
  kafka-ui:        Web UI for Kafka

  # Spring Cloud Infrastructure
  eureka-server:   Service registry
  config-server:   Centralized configuration

  # API Layer
  api-gateway:     JWT auth + routing

  # Business Services
  auth-service:    Authentication
  candidate-service:
  recruiter-service:
  interview-service:
  live-coding-service:
  agent-service:
  notification-service:
  analytics-service:

  # Frontend
  webapp:          JSP + Tomcat

  # Monitoring
  prometheus:      Metrics collection
  grafana:         Dashboards
  zipkin:          Distributed tracing
```

### Health Checks & Startup Order
```yaml
# Services wait for their dependencies to be healthy:
recruiter-service:
  depends_on:
    mysql:
      condition: service_healthy   # MySQL must pass healthcheck
    eureka-server:
      condition: service_started   # Eureka must be up
    config-server:
      condition: service_started   # Config must be up

# MySQL healthcheck:
mysql:
  healthcheck:
    test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 30s
```

### Environment Variables (`.env` file)
```env
# Database
MYSQL_ROOT_PASSWORD=root123
MYSQL_DATABASE=agenthire_db

# Security
JWT_SECRET=your-256-bit-base64-encoded-secret-here
JWT_EXPIRATION_MS=86400000

# AI (optional — uses mock if not set)
OPENAI_API_KEY=sk-your-key-here
GEMINI_API_KEY=your-gemini-key-here

# Infrastructure
KAFKA_BOOTSTRAP_SERVERS=kafka:9092
REDIS_HOST=redis
EUREKA_SERVER_URL=http://eureka-server:8761/eureka/
```

---

*This architecture demonstrates mastery of enterprise distributed systems patterns used at scale by leading technology companies.*
