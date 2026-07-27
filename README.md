# 🤖 AgentHire AI
### Enterprise AI-Powered Recruitment & Smart Interview Ecosystem

![Java](https://img.shields.io/badge/Java-17-orange?style=flat-square&logo=java)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.2.5-brightgreen?style=flat-square&logo=springboot)
![Spring Cloud](https://img.shields.io/badge/Spring_Cloud-2023.0.1-brightgreen?style=flat-square)
![Docker](https://img.shields.io/badge/Docker-Compose-blue?style=flat-square&logo=docker)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=flat-square&logo=mysql)
![Kafka](https://img.shields.io/badge/Apache_Kafka-3.x-black?style=flat-square&logo=apachekafka)
![Redis](https://img.shields.io/badge/Redis-7.x-red?style=flat-square&logo=redis)
![AI](https://img.shields.io/badge/AI-OpenAI%20%7C%20Gemini-purple?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

---

## 📖 Project Overview

**AgentHire AI** is a full-stack, production-grade, **AI-powered recruitment platform** built on a true **microservices architecture** using Spring Boot 3.2.5 and Spring Cloud 2023.0.1. It automates and intelligently manages the entire hiring pipeline — from job posting and candidate application, all the way through to AI-powered resume analysis, interview scheduling, live coding assessments, and final hiring recommendations.

The system is designed around **real enterprise patterns** used by companies like Netflix, Uber, and LinkedIn:
- **11 independent microservices** each owning their domain
- **20 Docker containers** orchestrated with Docker Compose
- **22 MySQL database tables** covering every aspect of recruitment
- **6 autonomous AI agents** powered by OpenAI GPT-4 / Google Gemini
- **Event-driven architecture** using Apache Kafka
- **Stateless JWT authentication** with Redis-based token blacklisting
- **Role-Based Access Control** separating Recruiter and Candidate experiences
- **Real-time analytics** with live conversion funnel and KPI tracking

This project was built to demonstrate mastery of enterprise Java development, distributed systems, cloud-native patterns, and AI integration — going far beyond a simple CRUD application.

---

## ✨ Feature Highlights

### 🔐 Authentication & Security
- JWT-based stateless authentication (no server-side sessions)
- Role-based registration: choose RECRUITER or CANDIDATE at signup
- Refresh token rotation for seamless session management
- Redis-backed token blacklist for instant logout invalidation
- BCrypt password hashing (cost factor 10)
- Login history tracking with IP and user agent
- API Gateway validates JWT before any microservice receives a request

### 💼 Recruiter Features
- **Job Management**: Create, edit, publish, and close job postings with rich details (title, description, requirements, salary range, job type, experience level, location, remote options)
- **Application Pipeline**: View all applications per job, move candidates through stages (APPLIED → SCREENING → SHORTLISTED → INTERVIEW → OFFERED → HIRED / REJECTED)
- **Candidate Profiles**: Browse all candidates with their skills, certifications, and resume
- **Interview Scheduling**: Schedule interviews with type (PHONE_SCREEN, TECHNICAL, SYSTEM_DESIGN, BEHAVIORAL, HR, FINAL), meeting link, and duration
- **Live Analytics Dashboard**: Real-time KPIs, hiring funnel conversion rates, applications over time chart, job type distribution, status breakdown
- **AI Agent Suite**: Full access to all 6 AI agents for automation

### 👤 Candidate Features
- **Profile Management**: Build professional profile with headline, experience, bio
- **Skills & Certifications**: Add technical skills with proficiency levels and certifications
- **Resume Upload**: Upload and manage resumes
- **Job Discovery**: Browse all active job postings
- **Application Tracking**: Apply to jobs and track application status in real time
- **Interview Tracking**: View scheduled interviews (own interviews only)
- **Personal Dashboard**: Stats showing application count, shortlisted count, interview count

### 🤖 AI Agent Suite (6 Agents)
| Agent | What It Does |
|-------|-------------|
| **Resume Analyzer** | Extracts skills, scores experience, identifies gaps, recommends next steps |
| **Job Matcher** | Computes compatibility percentage between candidate profile and job requirements |
| **Interview Question Generator** | Creates role-specific question sets with expected answers, difficulty levels, follow-ups |
| **Interview Evaluator** | Analyzes Q&A transcripts, scores performance across technical/behavioral/communication axes |
| **Hiring Recommender** | Synthesizes all evaluation data to produce a HIRE/NO-HIRE recommendation with reasoning |
| **Recruiter Copilot** | Assists with writing JDs, outreach emails, rejection letters, interview plans |

### 📊 Analytics Dashboard (Live Data)
- Total applications, hired count, active jobs, interview count — all from real DB queries
- Applications over time chart (7 / 30 / 90 day periods) — built from `DATE_FORMAT` + `GROUP BY` native SQL
- Hiring funnel doughnut chart — Applied → Screened → Shortlisted → Interview → Offered → Hired
- Job type distribution bar chart (Full-Time vs Contract vs Part-Time vs Internship)
- Status breakdown progress bars with conversion percentages
- Funnel rate cards (Application→Shortlist rate, Shortlist→Interview rate, Interview→Hire rate)
- Full recruitment summary table with "Live" data indicator

### 🔔 Notifications (Kafka-Powered)
- Async notification events published to Kafka topics
- `user-events` topic: USER_REGISTERED, USER_LOGGED_IN, USER_LOGGED_OUT
- `interview-events` topic: INTERVIEW_SCHEDULED, INTERVIEW_COMPLETED
- Notification-service reads events and stores in-app notifications

### 💻 Live Coding Sessions
- Integrated live coding module for technical assessments
- Support for multiple programming languages
- Code submission and result tracking

### 📡 Observability & Monitoring
- Prometheus scrapes `/actuator/prometheus` from every service
- Grafana dashboards for JVM metrics, request rates, error rates
- Zipkin distributed tracing — visualize request journey across services
- Spring Boot Actuator health checks on every service

---

## 🏛️ Architecture at a Glance

```
  BROWSER
    │
    ▼ :8090
  ┌─────────────────────────┐
  │  WEBAPP (JSP + JS)      │  ← Renders UI, calls /api/** via Fetch
  └────────────┬────────────┘
               │ /api/**
    ▼ :8080
  ┌─────────────────────────────────────────────────────────────┐
  │              API GATEWAY (Spring Cloud Gateway)              │
  │   JWT Validation → Route → Rate Limiting → Log              │
  └────┬──────────┬──────────┬──────────┬──────────┬────────────┘
       │          │          │          │          │
      8081       8082       8083       8084       8086
  ┌────▼────┐┌────▼────┐┌────▼────┐┌────▼────┐┌────▼────────┐
  │  AUTH   ││CANDIDATE││RECRUITER││INTERVIEW││ AI AGENTS   │
  │ Service ││ Service ││ Service ││ Service ││  Service    │
  └─────────┘└─────────┘└─────────┘└─────────┘└─────────────┘
       │          │          │          │          │
       └──────────┴──────────┴──────────┴──────────┘
                             │
                    ┌────────▼────────┐   ┌──────────┐   ┌──────────┐
                    │   MySQL :3306   │   │Redis:6379│   │Kafka:9092│
                    │  22 tables      │   │Blacklist │   │ Events   │
                    └─────────────────┘   └──────────┘   └──────────┘

  INFRASTRUCTURE:
  Eureka :8761  │  Config Server :8888  │  Zipkin :9411
  Prometheus :9090  │  Grafana :3000  │  Kafka UI :8086
```

---

## 🚀 Getting Started

### Prerequisites
Make sure you have installed:
- **Docker Desktop** (version 24+) — [Download](https://www.docker.com/products/docker-desktop)
- **8 GB RAM** minimum available for Docker
- The following ports must be free: 3000, 3306, 6379, 8080–8090, 9090, 9092, 9411

### 1. Clone / Open the Project
```bash
cd C:\Users\<you>\Desktop\interviewProject\agenthire-ai
```

### 2. (Optional) Configure AI API Keys
Edit `.env` and add your API key for live AI responses:
```env
OPENAI_API_KEY=sk-your-openai-key-here
# OR
GEMINI_API_KEY=your-gemini-key-here
```
> Without keys, the system uses intelligent mock responses — fully functional for demo.

### 3. Start Everything
```bash
docker compose up -d
```
This starts all 20 containers. First run downloads images (~5–8 minutes). Subsequent runs take ~30 seconds.

### 4. Wait for Services to Register
Wait ~60 seconds for all services to register with Eureka. You can monitor at:
```
http://localhost:8761  (Eureka Dashboard — wait until all services show UP)
```

### 5. Open the Application
```
http://localhost:8090
```

### 6. Stop Everything
```bash
docker compose down          # Stop but keep data
docker compose down -v       # Stop and wipe all data (fresh start)
```

---

## 🌐 All Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **Web Application** | http://localhost:8090 | Main UI — start here |
| **API Gateway** | http://localhost:8080 | All /api/** calls go here |
| **Eureka Dashboard** | http://localhost:8761 | See all registered services |
| **Config Server** | http://localhost:8888 | Centralized configuration |
| **Kafka UI** | http://localhost:8086 (alt) | Browse Kafka topics/messages |
| **Grafana** | http://localhost:3000 | Monitoring dashboards |
| **Prometheus** | http://localhost:9090 | Raw metrics |
| **Zipkin Tracing** | http://localhost:9411 | Distributed request traces |

---

## 🔑 Default Credentials

| Account Type | How To Create | Notes |
|-------------|--------------|-------|
| **Recruiter** | Register at `/register`, select RECRUITER | Full access to all features |
| **Candidate** | Register at `/register`, select CANDIDATE | Sees only own data |
| **Grafana** | admin / admin | Change after first login |
| **MySQL** | root / root123 | Accessible on port 3306 |

---

## 📁 Complete Module Structure

```
agenthire-ai/
│
├── 📄 pom.xml                          ← Parent Maven POM — shared versions & deps
├── 📄 docker-compose.yml               ← Defines all 20 containers
├── 📄 .env                             ← Environment variables (API keys, secrets)
├── 📄 .env.example                     ← Template for .env
├── 📄 START.bat / start.ps1            ← Quick start scripts for Windows
│
├── 🟢 eureka-server/                   ← Service Discovery (port 8761)
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/java/com/agenthire/eureka/
│       └── EurekaServerApplication.java   (@EnableEurekaServer)
│
├── ⚙️  config-server/                  ← Centralized Configuration (port 8888)
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/resources/
│       ├── application.yml
│       └── config-repo/                ← Per-service config files
│           ├── application.yml         (shared: eureka, actuator, logging)
│           ├── auth-service.yml
│           ├── recruiter-service.yml
│           └── ...
│
├── 🔀 api-gateway/                     ← JWT Auth + Routing (port 8080)
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/java/com/agenthire/gateway/
│       ├── ApiGatewayApplication.java
│       ├── config/GatewayConfig.java       (route definitions)
│       ├── filter/JwtAuthenticationFilter.java  (JWT validation)
│       ├── filter/RateLimitingFilter.java   (Redis rate limiting)
│       ├── filter/RequestLoggingFilter.java
│       └── fallback/FallbackController.java
│
├── 🔐 auth-service/                    ← Authentication (port 8081)
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/java/com/agenthire/auth/
│       ├── controller/AuthController.java  (POST /register, /login, /refresh, /logout)
│       ├── service/AuthService.java
│       ├── entity/User.java, Role.java, RefreshToken.java, LoginHistory.java
│       ├── security/JwtTokenProvider.java, JwtAuthenticationFilter.java
│       ├── security/SecurityConfig.java
│       ├── kafka/UserEventProducer.java
│       └── redis/RedisTokenBlacklistService.java
│
├── 👤 candidate-service/               ← Candidate Profiles (port 8082)
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/java/com/agenthire/candidate/
│       ├── controller/CandidateController.java
│       ├── entity/Candidate.java, CandidateSkill.java, Resume.java
│       └── repository/CandidateRepository.java, ResumeRepository.java
│
├── 💼 recruiter-service/               ← Jobs + Applications + Analytics (port 8083)
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/java/com/agenthire/recruiter/
│       ├── controller/RecruiterController.java  (50+ endpoints)
│       ├── entity/Job.java, JobApplication.java, Recruiter.java, Company.java
│       ├── entity/JobType.java, JobStatus.java, ApplicationStatus.java
│       └── repository/JobRepository.java, JobApplicationRepository.java
│
├── 📅 interview-service/               ← Interview Management (port 8084)
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/java/com/agenthire/interview/
│       ├── controller/InterviewController.java
│       ├── entity/Interview.java
│       └── repository/InterviewRepository.java
│
├── 💻 live-coding-service/             ← Coding Assessments (port 8085)
│   └── src/main/java/com/agenthire/coding/
│
├── 🤖 agent-service/                   ← 6 AI Agents (port 8086)
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/java/com/agenthire/agent/
│       ├── controller/AgentController.java
│       ├── agent/AgentFactory.java, AgentContext.java, AgentType.java
│       ├── agent/impl/ResumeAnalyzerAgent.java
│       ├── agent/impl/JobMatchingAgent.java
│       ├── agent/impl/InterviewQuestionGeneratorAgent.java
│       ├── agent/impl/InterviewEvaluatorAgent.java
│       ├── agent/impl/HiringRecommenderAgent.java
│       ├── agent/impl/RecruiterCopilotAgent.java
│       ├── llm/LlmProvider.java           (interface)
│       ├── llm/OpenAiProvider.java        (@Primary implementation)
│       ├── llm/GeminiProvider.java        (fallback)
│       └── entity/AgentReport.java
│
├── 🔔 notification-service/            ← Kafka Consumer + Alerts (port 8087)
│   └── src/main/java/com/agenthire/notification/
│
├── 📊 analytics-service/               ← Analytics Aggregation (port 8088)
│   └── src/main/java/com/agenthire/analytics/
│
├── 🖥️  webapp/                         ← Frontend (Tomcat, port 8090)
│   └── src/main/
│       ├── java/com/agenthire/webapp/
│       │   └── controller/               (JSP routing controllers)
│       └── webapp/
│           ├── WEB-INF/views/            ← JSP pages
│           │   ├── dashboard.jsp         (Recruiter + Candidate dashboard)
│           │   ├── jobs.jsp              (Job listings + posting)
│           │   ├── candidates.jsp        (Candidate management)
│           │   ├── interviews.jsp        (Interview scheduling)
│           │   ├── analytics.jsp         (Live analytics charts)
│           │   ├── agents.jsp            (AI Agent UI)
│           │   ├── profile.jsp           (User profile)
│           │   ├── login.jsp / register.jsp
│           │   └── live-coding.jsp
│           └── static/
│               ├── css/style.css         (glassmorphism dark theme)
│               └── js/app.js             (auth + API helper + routing)
│
├── 🗄️  sql/
│   ├── schema.sql                      ← All 22 table definitions + indexes + views
│   └── seed-data.sql                   ← Sample data for demo
│
└── 📡 monitoring/
    ├── prometheus/prometheus.yml       ← Scrape configs for all services
    └── grafana/                        ← Dashboard provisioning
```

---

## 🔄 Complete User Journeys

### Recruiter Journey
```
1. Register at /register → Select "RECRUITER" → JWT issued
2. Navigate to Jobs → Click "Post New Job"
3. Fill job details (title, description, type, salary, requirements)
4. Job is created with status ACTIVE → visible to candidates
5. Navigate to Jobs → Click job → See all applications
6. Review candidate → Click "Shortlist" → Status changes to SHORTLISTED
7. Navigate to Interviews → "Schedule Interview"
   → Fill form (type, date/time, meeting link)
   → candidateId fetched from application → saved to interviews table
8. Navigate to AI Agents → Resume Analyzer
   → Paste resume text → AI analyzes and scores
9. Navigate to Analytics → See live hiring funnel and KPIs
```

### Candidate Journey
```
1. Register at /register → Select "CANDIDATE" → JWT issued
2. Complete profile (headline, experience, bio)
3. Add skills and certifications
4. Upload resume
5. Navigate to Jobs → Browse active listings
6. Click "Apply" on a job → Cover letter → Application submitted
7. Navigate to Dashboard → See "3 Applications, 1 Shortlisted"
8. Navigate to Interviews → See own scheduled interviews
   (other candidates' interviews are NOT visible)
```

---

## 🛠️ Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | Java | 17 LTS |
| Framework | Spring Boot | 3.2.5 |
| Microservices | Spring Cloud | 2023.0.1 |
| Security | Spring Security + jjwt | 6.x + 0.12.5 |
| ORM | Spring Data JPA / Hibernate | 3.x / 6.x |
| Database | MySQL | 8.0 |
| Cache | Redis | 7.x |
| Messaging | Apache Kafka | 3.x |
| Service Discovery | Netflix Eureka | 4.x |
| API Gateway | Spring Cloud Gateway (WebFlux) | 2023.0.1 |
| Config | Spring Cloud Config | 2023.0.1 |
| AI | OpenAI GPT-4 / Google Gemini | Latest |
| HTTP Client | OkHttp | 4.x |
| Frontend | JSP + Vanilla JS + CSS | — |
| Charts | Chart.js | 4.4.0 |
| Build | Maven (multi-module) | 3.9.x |
| Containerization | Docker + Docker Compose | 24.x / v3.8 |
| Monitoring | Prometheus + Grafana | Latest |
| Tracing | Zipkin + Micrometer | Latest |
| Serialization | Jackson | 2.x |
| Utilities | Lombok | 1.18.x |

---

## 🗄️ Database Schema Summary (22 Tables)

```sql
-- AUTH DOMAIN
users                    (id, email, password, role_id, provider, is_active)
roles                    (id, name: ADMIN/RECRUITER/CANDIDATE)
refresh_tokens           (id, user_id, token, expiry_date, is_revoked)
login_history            (id, user_id, ip_address, user_agent, status)

-- CANDIDATE DOMAIN
candidates               (id, user_id, headline, experience_years, location)
candidate_skills         (id, candidate_id, skill_name, proficiency_level)
candidate_certifications (id, candidate_id, name, issuing_org, issue_date)
resumes                  (id, candidate_id, file_path, file_name, is_primary)

-- RECRUITER DOMAIN
recruiters               (id, user_id, company_id, title, department)
companies                (id, name, industry, size, website, logo_url)
jobs                     (id, recruiter_id, company_id, title, job_type,
                          experience_level, salary_range, status, deadline)
job_skills               (id, job_id, skill_name, is_required)

-- HIRING DOMAIN
job_applications         (id, candidate_id, job_id, status, cover_letter, applied_at)

-- INTERVIEW DOMAIN
interviews               (id, application_id, candidate_id, recruiter_id, job_id,
                          interview_type, status, scheduled_at, duration_minutes,
                          meeting_link, feedback, overall_score)

-- AI DOMAIN
agent_reports            (id, agent_type, reference_type, reference_id,
                          report_json, score, recommendation, created_at)
coding_sessions          (id, candidate_id, recruiter_id, language, problem, status)
coding_submissions       (id, session_id, code, language, result, passed_tests)

-- NOTIFICATION DOMAIN
notifications            (id, user_id, type, title, message, is_read, created_at)

-- AUDIT
audit_logs               (id, user_id, action, entity_type, entity_id, timestamp)

-- VIEWS (MySQL views for simplified querying)
active_users             (view on users where deleted_at IS NULL)
active_jobs              (view on jobs where status = 'ACTIVE')
active_companies         (view on companies where is_active = true)
```

---

## ⚡ Key Design Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Auth mechanism | JWT (stateless) | Scalable, microservice-compatible, no session affinity needed |
| Gateway type | Spring Cloud Gateway (WebFlux) | Non-blocking, reactive, high throughput |
| Service discovery | Netflix Eureka | Native Spring Cloud integration, battle-tested |
| Messaging | Apache Kafka | Durable, replayable, high-throughput event streaming |
| Cache | Redis | In-memory O(1) ops, TTL support for token blacklist |
| ORM | Hibernate/JPA | Industry standard, reduces SQL boilerplate |
| Frontend | JSP + Vanilla JS | No build tool needed, simple deployment in Tomcat |
| Containerization | Docker Compose | Simple multi-container orchestration for development |
| AI integration | Strategy pattern with fallback | Vendor-agnostic, demo-friendly, no API key required |
| Analytics | Native SQL + Chart.js | GROUP BY aggregations, client-side rendering |

---

*AgentHire AI — Enterprise-grade recruitment automation powered by AI, built with Spring Boot microservices.*
