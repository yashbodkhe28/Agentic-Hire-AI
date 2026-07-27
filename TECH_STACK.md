# 🛠️ AgentHire AI — Tech Stack Deep Dive

## Why Each Technology Was Chosen

---

## 1. ☕ Java 17 + Spring Boot 3.2.5

**What:** Java 17 is an LTS (Long-Term Support) version. Spring Boot auto-configures everything.

**Why chosen:**
- Java is the industry standard for enterprise backend
- Spring Boot eliminates boilerplate (no XML config, embedded Tomcat)
- Auto-configuration = less code, more focus on business logic
- Huge ecosystem: Security, JPA, Cloud, Kafka — all first-class support

**Key features used:**
```java
@SpringBootApplication          // Auto-configures everything
@RestController                 // REST API controller
@Service                        // Business logic layer
@Repository                     // Data access layer
@Entity / @Table                // JPA entity mapping
@Transactional(readOnly=true)   // Session management for lazy loading
```

**Interview point:** *"Spring Boot's auto-configuration saved hours of setup. I focused on business logic instead of infrastructure."*

---

## 2. 🔐 Spring Security + JWT

**What:** JWT = JSON Web Token. Stateless authentication mechanism.

**Why JWT over Sessions:**
```
Sessions (OLD WAY):          JWT (MODERN WAY):
- Stored on server           - Stored on client (localStorage)
- Not scalable               - Stateless = infinitely scalable
- Breaks with load balancers - Works with any number of servers
- Requires sticky sessions   - Microservice-friendly
```

**JWT Structure:**
```
eyJhbGciOiJIUzI1NiJ9     ← Header (Base64): algorithm
.eyJ1c2VySWQiOjI0fQ      ← Payload (Base64): userId, role, expiry
.SflKxwRJSMeKKF2QT4f     ← Signature: HMAC-SHA256(header+payload, SECRET)
```

**Why it's secure:** The signature uses a secret key only the server knows. If anyone tampers with the payload (e.g., changes role from CANDIDATE to RECRUITER), the signature check fails → 401.

**Library:** `io.jsonwebtoken:jjwt 0.12.5`
```java
Jwts.builder()
    .subject(user.getEmail())
    .claim("userId", user.getId())
    .claim("role", user.getRole())
    .expiration(new Date(System.currentTimeMillis() + 86400000)) // 24 hours
    .signWith(secretKey)
    .compact();
```

---

## 3. 🌐 Spring Cloud — Microservices Toolkit

### Netflix Eureka (Service Discovery)
**Why:** In Docker, each container gets a dynamic IP. Eureka is the phone book that lets services find each other.
```
Without Eureka: hardcode IPs → breaks when containers restart
With Eureka:    services register themselves → always findable
```

### Spring Cloud Config Server
**Why:** 11 services × multiple environments = config nightmare. Config Server centralizes all `application.yml` files.
```
Without Config: 11 × application.yml files to update
With Config:    one place, all services fetch their config at startup
```

### Spring Cloud Gateway
**Why:** Single entry point for all API calls. Gateway handles:
- JWT validation (before request reaches any service)
- Rate limiting (prevent abuse)
- Request logging
- Load balancing

---

## 4. 🗄️ MySQL + Spring Data JPA (Hibernate 6)

**Why MySQL:**
- Relational data fits hiring domain (users ↔ jobs ↔ applications ↔ interviews)
- ACID compliance = data integrity (no half-saved applications)
- Industry standard that every company uses

**Why JPA/Hibernate:**
```java
// Without JPA (raw SQL):
String sql = "SELECT * FROM jobs WHERE id = ?";
PreparedStatement ps = conn.prepareStatement(sql);
ps.setLong(1, jobId);
ResultSet rs = ps.executeQuery();
// ... manually map 15 columns

// With JPA:
jobRepository.findById(jobId); // One line!
```

**Key concept I learned — Lazy Loading:**
```java
// @ManyToOne(fetch = FetchType.LAZY)
// Job is NOT loaded until you call getJob()
// PROBLEM: If Hibernate session is closed, getJob() fails
// SOLUTION: Add @Transactional(readOnly = true) to controller methods
//           This keeps the session open for the entire request
```

---

## 5. 🔴 Redis

**What:** In-memory key-value store. Extremely fast (microsecond reads).

**How I used it — Token Blacklist:**
```
Problem: JWT tokens can't be invalidated (they're stateless).
         If user logs out but their token hasn't expired,
         anyone with that token can still use it.

Solution: Logout stores token in Redis with TTL = remaining expiry time
          Gateway checks Redis before allowing any request
          O(1) lookup → zero performance impact

Redis command equivalent:
  SET "blacklist:eyJ..." "revoked" EX 86400
  EXISTS "blacklist:eyJ..." → 0 or 1
```

---

## 6. 📨 Apache Kafka

**What:** Distributed event streaming platform. Like a message queue but more powerful.

**Why Kafka over direct REST calls:**
```
Direct call (tight coupling):
  interview-service → HTTP POST → notification-service
  Problem: If notification-service is down, interview scheduling FAILS

Kafka (loose coupling):
  interview-service → publish to Kafka topic → returns immediately
  notification-service → reads from Kafka when ready → sends notification
  Problem: notification-service down? Kafka holds the message until it's back up
```

**Key concepts:**
- **Topic:** Named channel (like `interview-events`)
- **Producer:** Service that sends messages (interview-service)
- **Consumer:** Service that reads messages (notification-service)
- **Offset:** Position in topic (Kafka remembers where each consumer left off)

---

## 7. 🐳 Docker + Docker Compose

**What:** Containerization platform. Package app + all dependencies into a container.

**Why Docker:**
```
Without Docker:
  "Works on my machine" → fails in production
  Need to install Java 17, MySQL 8, Redis, Kafka on every machine

With Docker:
  docker compose up -d → all 20 services start in seconds
  Same behavior on any OS
  Isolated environments (services can't interfere with each other)
```

**docker-compose.yml defines:**
- 20 containers with their images, ports, environment variables
- Service dependencies (auth-service waits for MySQL to be healthy)
- Network (all services on `agenthire-network` bridge)
- Volume mounts for MySQL data persistence

**Health checks in docker-compose:**
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s
  timeout: 5s
  retries: 5
```

---

## 8. 🤖 AI Integration (OpenAI / Gemini)

**Architecture:** Strategy Pattern with fallback chain

```java
// LlmProvider interface — multiple implementations
public interface LlmProvider {
    String chat(String systemPrompt, String userPrompt);
}

// @Primary → OpenAI is tried first
@Primary @Service
public class OpenAiProvider implements LlmProvider { ... }

// Fallback → if no OpenAI key, Gemini
@Service
public class GeminiProvider implements LlmProvider { ... }

// Smart mock → if no API key at all
private String mockResponse(String systemPrompt, String userPrompt) {
    // Keyword detection → appropriate demo response
}
```

**Why this design:**
- Demo without API key costs → smart mock responses
- Easy to swap AI providers
- No hardcoded vendor dependency

---

## 9. 📊 Chart.js (Frontend)

**Why Chart.js over heavy frameworks (D3.js, etc.):**
- Lightweight (no dependencies)
- Beautiful out of the box
- 8 chart types
- Canvas-based = performant

**Charts used:**
- Line chart → Applications over time
- Doughnut chart → Hiring funnel
- Bar chart → Applications by job type
- Progress bars → Status breakdown (custom HTML)

---

## 10. 🏗️ Maven Multi-Module

**What:** Parent POM manages all 11 child modules.

**Why:**
```xml
<!-- Parent pom.xml -->
<modules>
  <module>auth-service</module>
  <module>recruiter-service</module>
  <!-- ... 9 more -->
</modules>

<!-- Child pom.xml inherits: -->
<parent>
  <artifactId>agenthire-ai</artifactId>
</parent>
<!-- No need to repeat Java version, Spring Boot version, common deps -->
```

**One command builds everything:**
```bash
mvn clean package -DskipTests
```

---

## Summary Table

| Technology | Version | Purpose | Why Chosen |
|-----------|---------|---------|------------|
| Java | 17 (LTS) | Backend language | Industry standard, Spring ecosystem |
| Spring Boot | 3.2.5 | Framework | Auto-config, embedded server |
| Spring Security | 6.x | Auth/Authz | Industry standard, JWT support |
| jjwt | 0.12.5 | JWT library | Modern, maintained, easy API |
| Spring Cloud | 2023.0.1 | Microservice patterns | Eureka, Gateway, Config |
| MySQL | 8.0 | Primary database | Relational, ACID, industry standard |
| Hibernate | 6.x | ORM | Via Spring Data JPA |
| Redis | 7.x | Cache/Blacklist | In-memory, TTL support, O(1) |
| Apache Kafka | 3.x | Messaging | Async, decoupled, resilient |
| Docker | Latest | Containerization | Portability, consistency |
| Docker Compose | v3.8 | Orchestration | Multi-container management |
| OpenAI/Gemini | API | AI capabilities | State-of-the-art LLMs |
| Chart.js | 4.4.0 | Charts | Lightweight, beautiful |
| Prometheus | Latest | Metrics | Industry standard monitoring |
| Grafana | Latest | Visualization | Dashboard for metrics |
| Zipkin | Latest | Tracing | Distributed request tracing |
