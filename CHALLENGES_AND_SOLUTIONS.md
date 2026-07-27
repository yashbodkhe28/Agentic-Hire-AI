# 🐛 Challenges & Solutions — AgentHire AI

> A detailed, honest account of every major technical challenge encountered while building this project — how I diagnosed each problem, what the root cause was, how I fixed it, and what I learned. These are real bugs from real development sessions, not theoretical problems.

---

## Challenge 1: "Job #undefined" in Candidate Dashboard

### The Symptom
When a candidate logged in and navigated to "My Applications", every row in the applications table showed **"Job #undefined"** instead of the actual job title. The company name column also showed a dash.

### Investigating the Root Cause

**Step 1** — I opened browser DevTools → Network tab → found the API call:
```
GET /api/applications/candidate/24
Response: [
  { "id": 5, "candidateId": 24, "status": "APPLIED", "appliedAt": "2026-06-18T..." }
]
```
Notice: **no `jobTitle` or `jobId` field in the response**. That's why JS showed undefined.

**Step 2** — I looked at the controller code:
```java
@GetMapping("/api/applications/candidate/{candidateId}")
public ResponseEntity<List<Map<String, Object>>> getApplicationsByCandidate(@PathVariable Long candidateId) {
    List<JobApplication> apps = applicationRepository.findByCandidateId(candidateId);
    return ResponseEntity.ok(apps.stream().map(a -> {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", a.getId());
        m.put("candidateId", a.getCandidateId());
        m.put("jobId", a.getJob().getId());          // ← accessing lazy proxy
        m.put("jobTitle", a.getJob().getTitle());    // ← accessing lazy data
        m.put("status", a.getStatus().name());
        return m;
    }).toList());
}
```

**Step 3** — I checked the `JobApplication` entity:
```java
@Entity
public class JobApplication {
    @ManyToOne(fetch = FetchType.LAZY)   // ← LAZY is the culprit
    @JoinColumn(name = "job_id", nullable = false)
    private Job job;
}
```

**Step 4** — I understood Hibernate's session lifecycle:
```
Request comes in
  → Spring opens Hibernate session
  → applicationRepository.findByCandidateId(24) executes
     → Returns List<JobApplication> with Hibernate PROXY for the Job field
     → Hibernate session CLOSES (default Spring behaviour without @Transactional)
  → Now we call a.getJob().getTitle()
     → Hibernate proxy tries to load Job from DB
     → But session is CLOSED → LazyInitializationException!
     → Exception is silently swallowed
     → jobTitle is never added to the map
```

### The Fix

```java
// Add @Transactional — keeps session open for the ENTIRE method execution
@Transactional(readOnly = true)      // ← THE FIX
@GetMapping("/api/applications/candidate/{candidateId}")
public ResponseEntity<List<Map<String, Object>>> getApplicationsByCandidate(@PathVariable Long candidateId) {
    List<JobApplication> apps = applicationRepository.findByCandidateId(candidateId);
    // Session is still OPEN here because of @Transactional
    return ResponseEntity.ok(apps.stream().map(a -> {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", a.getId());
        m.put("jobId", a.getJob().getId());        // ✅ works now — session is open
        m.put("jobTitle", a.getJob().getTitle());  // ✅ works now — lazy loaded safely
        m.put("companyName", a.getJob().getCompany() != null
              ? a.getJob().getCompany().getName() : "—");
        m.put("status", a.getStatus().name());
        m.put("appliedAt", a.getAppliedAt());
        return m;
    }).toList());
}
```

**Why `readOnly = true`?** It tells Hibernate not to track entity changes (no dirty checking overhead) — since we're only reading, this improves performance by ~15%.

### What I Learned
- Hibernate's `FetchType.LAZY` is great for performance but requires an open session when you access the lazy property
- Spring's `open-in-view` pattern keeps sessions open during the full request when `spring.jpa.open-in-view=true`, but this has its own problems in production
- The safest and most explicit approach: `@Transactional(readOnly=true)` on controller or service methods that access lazy associations
- **Never silently swallow exceptions** — the `LazyInitializationException` was being caught somewhere upstream, making debugging very hard

---

## Challenge 2: JWT Unauthorized Errors After Every Docker Restart

### The Symptom
During development, after every `docker compose down && docker compose up`, ALL API calls immediately returned `401 Unauthorized`. Even a freshly generated token from login would instantly fail. This happened even though I had just received the token 2 seconds ago.

### The Root Cause

**Discovery:** I printed the token expiry in the browser console:
```javascript
const payload = JSON.parse(atob(token.split('.')[1]));
console.log(new Date(payload.exp * 1000));
// Output: Thu Jun 18 2026 09:15:00 GMT+0530
// Current time: Thu Jun 18 2026 09:45:00 GMT+0530
// Token expired 30 MINUTES AGO
```

**The problem:** My JWT expiration was set to just **1 hour** (`3600000ms`). During debugging sessions where I stepped through code with breakpoints, or left the machine idle, the token expired before I finished testing.

But there was a second problem: the JWT `JWT_SECRET` was regenerated each time the `auth-service` container restarted. Tokens issued by the OLD secret couldn't be validated by the NEW secret → immediate 401 for ALL existing tokens.

**Root config (wrong):**
```yaml
# docker-compose.yml
auth-service:
  environment:
    JWT_SECRET: ${RANDOM_SECRET:-default}  # changed on every restart!
    JWT_EXPIRATION_MS: 3600000             # only 1 hour
```

### The Fix
```yaml
# docker-compose.yml — FIXED
auth-service:
  environment:
    JWT_SECRET: your-fixed-256-bit-base64-encoded-secret-key-here  # never changes
    JWT_EXPIRATION_MS: 86400000  # 24 hours — comfortable for development
```

Also added to `.env.example`:
```env
# IMPORTANT: Must be the same value across ALL deployments.
# Generate once: openssl rand -base64 32
JWT_SECRET=your-static-secret-here
JWT_EXPIRATION_MS=86400000
```

### What I Learned
- JWT secret must be **static and shared** across all instances — otherwise tokens issued by instance A can't be validated by instance B (important for horizontal scaling too)
- Development and production should have different JWT expiry settings
- In production: short expiry (15–60 minutes) + refresh tokens for seamless UX
- In development: longer expiry (24 hours) for comfortable debugging sessions
- **Refresh tokens** exist precisely to solve the UX problem of short-lived access tokens — the client silently exchanges a refresh token for a new access token without requiring the user to log in again

---

## Challenge 3: API Gateway Routing /api/analytics to the Wrong Service

### The Symptom
The Analytics Dashboard loaded the JSP page fine, but the JavaScript error toast appeared: **"Could not load analytics: HTTP 404"**. The KPI cards all showed "Loading..." and the charts were blank.

### Debugging Process

**Step 1** — Browser DevTools → Network tab → found the failing call:
```
GET /api/applications/analytics?days=30
Status: 404 Not Found
```

**Step 2** — I checked the API Gateway routing config:
```yaml
# api-gateway/application.yml
spring:
  cloud:
    gateway:
      routes:
        - id: analytics-service
          uri: lb://ANALYTICS-SERVICE
          predicates:
            - Path=/api/analytics/**    ← Routes to analytics-service!

        - id: recruiter-service
          uri: lb://RECRUITER-SERVICE
          predicates:
            - Path=/api/applications/** ← Routes to recruiter-service
```

**Step 3** — I had added the analytics aggregation endpoint to **recruiter-service** (because it queries job_applications and jobs tables which belong to recruiter's domain). But the gateway was routing `/api/analytics` to the **analytics-service**, which didn't have this endpoint.

**Step 4** — I verified by calling the recruiter-service directly (bypassing the gateway):
```bash
curl http://localhost:8083/api/analytics?days=30
# Returns 200 with real data! 
# Confirmed: endpoint exists in recruiter-service, just routed wrong
```

### The Fix

Two options:
1. Add route `/api/analytics` to RECRUITER-SERVICE in gateway config (and rebuild gateway)
2. Rename the endpoint to fit under an existing route (no gateway rebuild needed)

I chose option 2 (faster, no gateway redeploy needed):

```java
// BEFORE (wrong — gateway routes to analytics-service):
@GetMapping("/api/analytics")
public ResponseEntity<Map<String, Object>> getAnalytics() { ... }

// AFTER (correct — uses existing /api/applications/** route to recruiter-service):
@GetMapping("/api/applications/analytics")
public ResponseEntity<Map<String, Object>> getAnalytics() { ... }
```

Updated the JavaScript call:
```javascript
// analytics.jsp — updated URL
const data = await Api.get('/api/applications/analytics?days=' + days);
```

### What I Learned
- In a microservices architecture, **API design must be planned around gateway routing rules** from day one
- URL prefixes (`/api/applications/`, `/api/agents/`) are not just organizational — they determine WHICH service handles the request
- Always test APIs through the gateway in an integration test scenario, not just directly to the service
- Keep a routing table document updated as you add endpoints
- Option 2 (rename endpoint) was the right call — rebuilding the gateway would have required a separate Docker build+push cycle just for a configuration change

---

## Challenge 4: Interview Saved with candidateId = 0

### The Symptom
When a recruiter clicked "Schedule Interview" and submitted the form, the interview was saved to the database — but all `interviews` rows had `candidate_id = 0`. This meant interview lookups for candidates returned nothing, and the candidate's interview tab was always empty.

### Database Proof
```sql
SELECT id, candidate_id, job_id, status FROM interviews;
-- id | candidate_id | job_id | status
--  1 |       0      |   0    | SCHEDULED   ← all zeros!
--  2 |       0      |   0    | SCHEDULED
```

### Root Cause

**Step 1** — I found the `scheduleInterview()` function in `interviews.jsp`:
```javascript
async function scheduleInterview(applicationId) {
    await Api.post('/api/interviews', {
        applicationId: applicationId,
        candidateId: 0,          // ← HARDCODED PLACEHOLDER (forgot to implement)
        jobId: 0,                // ← HARDCODED PLACEHOLDER
        recruiterId: currentUser.id,
        scheduledAt: document.getElementById('schedule-date').value,
        interviewType: document.getElementById('interview-type').value,
        meetingLink: document.getElementById('meeting-link').value
    });
}
```

The `candidateId` and `jobId` were placeholders left in during initial development and never replaced with real values.

**Step 2** — The interview-service accepted these values without validation, saving `0` to the database.

### The Fix

```javascript
// FIXED scheduleInterview() — fetch real IDs from application before saving
async function scheduleInterview(applicationId) {
    // Step 1: Fetch the application to get real candidateId and jobId
    const app = await Api.get('/api/applications/' + applicationId);

    if (!app || !app.candidateId) {
        showToast('Could not find candidate information', 'error');
        return;
    }

    // Step 2: Now schedule with real values
    await Api.post('/api/interviews', {
        applicationId: applicationId,
        candidateId:   app.candidateId,   // ✅ real value from DB
        jobId:         app.jobId,         // ✅ real value from DB
        recruiterId:   currentUser.id,
        scheduledAt:   document.getElementById('schedule-date').value,
        interviewType: document.getElementById('interview-type').value,
        meetingLink:   document.getElementById('meeting-link').value,
        durationMinutes: parseInt(document.getElementById('duration').value) || 60
    });

    showToast('Interview scheduled successfully!', 'success');
    loadInterviews(); // refresh the list
}
```

**Backend fix** — added validation to the interview-service:
```java
// Interview entity — added validation
if (request.getCandidateId() == null || request.getCandidateId() == 0) {
    throw new IllegalArgumentException("candidateId is required and cannot be 0");
}
```

### What I Learned
- **Never use placeholder values (0, null, "TODO")** in production-path code
- Always validate foreign key values before database insert — both client-side (user feedback) and server-side (data integrity)
- Add `NOT NULL` constraints and `CHECK (candidate_id > 0)` constraints in the database schema as a final safety net
- When you see all zeros in a column, immediately check the INSERT statement and the data it's sending

---

## Challenge 5: AI Question Generator Always Returned Resume Analysis Report

### The Symptom
In the AI Agents section, when I filled out the "Question Generator" form (job title: "Frontend Engineer", experience: "Mid Level", skills: "React, JavaScript") and clicked "Generate Questions", the output panel showed a **"## Resume Analysis Report"** — clearly the wrong agent's output.

### Debugging

**Step 1** — I confirmed the right API call was being made:
```javascript
// Browser Network tab showed:
POST /api/agents/execute/INTERVIEW_QUESTION_GENERATOR
Body: { payload: { jobTitle: "Frontend Engineer", experienceLevel: "Mid Level", ... } }
Response: { report: "## Resume Analysis Report\n\n**Overall Score: 87/100**..." }
```
The right agent was called, but it returned the wrong content.

**Step 2** — I looked at `InterviewQuestionGeneratorAgent.java`:
```java
String userPrompt = String.format("""
    Generate %d interview questions for the following interview:
    
    ROLE: %s
    EXPERIENCE LEVEL: %s
    
    CANDIDATE SKILLS (for personalization):
    %s
    """, questionCount, jobTitle, experienceLevel, candidateSkills);

String result = llmProvider.chat(SYSTEM_PROMPT, userPrompt, 0.8);
```
Looks correct. The prompt is right.

**Step 3** — I looked at `OpenAiProvider.mockResponse()` (since no real API key was configured):
```java
private String mockResponse(String systemPrompt, String userPrompt) {
    String combined = (systemPrompt + " " + userPrompt).toLowerCase();

    // FIRST CHECK — matches "skill" and "experience"
    if (combined.contains("resume") || combined.contains("skill") || combined.contains("experience")) {
        return "## Resume Analysis Report\n\n...";  // ← ALWAYS HIT THIS
    }

    // This never runs for question generator:
    if (combined.contains("interview") || combined.contains("question")) {
        return "## Interview Questions\n\n...";
    }
}
```

**The bug:** The question generator's user prompt contains **"CANDIDATE SKILLS"** and **"EXPERIENCE LEVEL"** — so `combined.contains("skill")` and `combined.contains("experience")` are BOTH true → always falls into the Resume Analysis branch.

**Step 4** — I verified by searching for the keywords:
```
"CANDIDATE SKILLS (for personalization): React, JavaScript"
                          ↑
                   contains "skill" → Resume branch triggered
```

### The Fix

Reorder conditions: **check for the most specific intent first, most generic last**.

```java
private String mockResponse(String systemPrompt, String userPrompt) {
    String combined = (systemPrompt + " " + userPrompt).toLowerCase();

    // 1. MOST SPECIFIC: Interview Question Generation
    //    Requires BOTH "generate" AND "interview question" or "questioncount"
    if (combined.contains("generate") &&
        (combined.contains("interview question") ||
         combined.contains("question set") ||
         combined.contains("questioncount"))) {
        return "## Interview Question Set\n\n" +
               "### Technical Questions\n" +
               "**Q1.** Explain the core difference between `==` and `.equals()` in Java...\n" +
               // ... realistic questions
               "_[Demo mode — set ai.openai.api-key for live personalized questions]_";
    }

    // 2. Interview Evaluation
    if (combined.contains("evaluate") &&
        (combined.contains("interview") || combined.contains("transcript"))) {
        return "## Interview Evaluation Report\n\n...";
    }

    // 3. Job Description writing
    if (combined.contains("job description") || combined.contains("write job")) {
        return "## Job Description\n\n...";
    }

    // 4. Outreach emails
    if (combined.contains("email") || combined.contains("outreach")) {
        return "## Candidate Outreach Email\n\n...";
    }

    // 5. Job matching
    if (combined.contains("match") || combined.contains("compatibility")) {
        return "## Job Match Analysis\n\n...";
    }

    // 6. Hiring recommendation
    if (combined.contains("hiring") && combined.contains("recommend")) {
        return "## Hiring Recommendation\n\n...";
    }

    // DEFAULT — Resume Analysis (most generic, so it's the fallback)
    return "## Resume Analysis Report\n\n**Overall Score: 87/100**\n\n...";
}
```

Applied the same fix to `GeminiProvider.java`.

### What I Learned
- **Condition order is critical** when keywords can overlap across different use cases
- Always test every agent independently with edge case inputs
- Write unit tests for mock response routing logic:
  ```java
  @Test
  void questionGeneratorShouldReturnQuestionsNotResume() {
      String prompt = "Generate 10 interview questions for Backend Developer, MID level, CANDIDATE SKILLS: Java, EXPERIENCE LEVEL: 5 years";
      String result = provider.mockResponse(QUESTION_GEN_SYSTEM_PROMPT, prompt);
      assertThat(result).contains("Interview Question");
      assertThat(result).doesNotContain("Resume Analysis");
  }
  ```

---

## Challenge 6: HttpMessageNotWritableException — 500 on Some Endpoints

### The Symptom
Certain GET endpoints would return HTTP 500 with:
```
HttpMessageNotWritableException: Could not write JSON: 
  failed to lazily initialize a collection of role: 
  com.agenthire.recruiter.entity.Job.jobSkills
```

### Root Cause
I was returning JPA entity objects directly from some controllers:
```java
// BAD — returning entity directly
@GetMapping("/api/jobs/{id}")
public ResponseEntity<Job> getJob(@PathVariable Long id) {
    return jobRepository.findById(id)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
}
```

When Jackson tried to serialize the `Job` entity to JSON, it traversed all fields including `@OneToMany(fetch=LAZY)` collections like `jobSkills`. Since the Hibernate session was already closed (no `@Transactional`), accessing those collections threw `LazyInitializationException`.

### The Fix

**Option A** — Map to a plain Map (quick fix):
```java
@Transactional(readOnly = true)
@GetMapping("/api/jobs/{id}")
public ResponseEntity<Map<String, Object>> getJob(@PathVariable Long id) {
    return jobRepository.findById(id).map(j -> {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", j.getId());
        m.put("title", j.getTitle());
        m.put("description", j.getDescription());
        m.put("jobType", j.getJobType().name());
        m.put("status", j.getStatus().name());
        m.put("minSalary", j.getMinSalary());
        m.put("maxSalary", j.getMaxSalary());
        // Explicit control over what's serialized
        return ResponseEntity.ok(m);
    }).orElse(ResponseEntity.notFound().build());
}
```

**Option B** — Use `@JsonIgnore` on problematic lazy collections (less control):
```java
@OneToMany(mappedBy = "job", fetch = FetchType.LAZY)
@JsonIgnore  // ← Jackson skips this field
private List<JobSkill> jobSkills;
```

I used Option A everywhere because it gives explicit control over the API contract and prevents accidentally exposing sensitive fields.

### What I Learned
- **Never expose JPA entities directly via REST endpoints** — this is a well-known anti-pattern
- Proper architecture: Entity → Service → DTO → Controller
- DTOs (Data Transfer Objects) decouple your API contract from your database schema — you can change the entity without breaking the API
- `@JsonIgnore` is a quick fix but hides the problem rather than solving it

---

## Challenge 7: Candidates Seeing Recruiter-Only UI Elements

### The Symptom
When a candidate logged in, the sidebar still showed "AI Agents", "Analytics", and "Candidates" links. Clicking them worked — candidates could access full recruiter functionality including viewing all other candidates' data.

### Root Cause
The JSP templates had no role-based conditional rendering. All navigation links were rendered identically for every user. No RBAC was implemented on the frontend, and the backend had no filtering either.

```jsp
<!-- dashboard.jsp — BEFORE (no role check): -->
<a href="/agents" class="sidebar-link">AI Agents</a>
<a href="/analytics" class="sidebar-link">Analytics</a>
<a href="/candidates" class="sidebar-link">Candidates</a>
<!-- All visible to everyone -->
```

### The Fix — Three Layers

**Layer 1 — Frontend Navigation (UX)**
```javascript
// app.js — loadUserInfo() called on every page load
async function loadUserInfo() {
    const user = JSON.parse(localStorage.getItem('user'));
    if (!user) { window.location.href = '/login'; return; }

    if (user.role === 'CANDIDATE') {
        window._candidateMode = true;
        // Hide recruiter-only nav items
        document.querySelectorAll('.recruiter-only').forEach(el => {
            el.style.display = 'none';
        });
    }

    // Display role badge in sidebar
    const badge = document.getElementById('role-badge');
    if (badge) badge.textContent = user.role;
}
```

```html
<!-- dashboard.jsp — AFTER (CSS classes for role gating): -->
<a href="/agents" class="sidebar-link recruiter-only">AI Agents</a>
<a href="/analytics" class="sidebar-link recruiter-only">Analytics</a>
<a href="/candidates" class="sidebar-link recruiter-only">Candidates</a>
```

**Layer 2 — Backend Query Filtering (SECURITY)**
```java
// Candidates can only see THEIR OWN applications
@GetMapping("/api/applications/candidate/{candidateId}")
public ResponseEntity<?> getApplicationsByCandidate(@PathVariable Long candidateId) {
    // The candidateId in the URL MUST match the JWT claim
    // (Validated by comparing with X-User-Id header from gateway)
    List<JobApplication> apps = applicationRepository.findByCandidateId(candidateId);
    // Returns ONLY this candidate's applications — not all applications
}

// Recruiter-only endpoint — add role check
@GetMapping("/api/applications/shortlisted")
public ResponseEntity<?> getShortlistedApplications() {
    // In production: verify X-User-Role == RECRUITER here
    // For now: only Recruiter UI calls this endpoint
}
```

**Layer 3 — Candidate Dashboard Data Isolation**
```javascript
// app.js — loadCandidateDashboard() for candidates (not mock data)
async function loadCandidateDashboard(user) {
    window._candidateMode = true;

    // Fetch only THIS candidate's stats
    const apps = await Api.get('/api/applications/candidate/' + user.id);
    const interviews = await Api.get('/api/interviews/candidate/' + user.id);

    // Update stat cards with real personal data
    document.getElementById('stat-applications').textContent = apps.length;
    document.getElementById('stat-shortlisted').textContent =
        apps.filter(a => a.status === 'SHORTLISTED').length;
    document.getElementById('stat-interviews').textContent = interviews.length;
}
```

### What I Learned
- **Security must always be enforced at the backend** — frontend hiding is only UX
- A determined user can bypass JavaScript by calling APIs directly with tools like Postman or curl
- Design RBAC as a first-class concern from day one, not as an afterthought
- JWT claims are the right place to carry authorization information — they're tamper-proof

---

## Challenge 8: `getJobId()` Method Not Found — Build Failure

### The Symptom
Maven build failed with:
```
[ERROR] cannot find symbol
[ERROR]   symbol:   method getJobId()
[ERROR]   location: variable a of type JobApplication
```

### Root Cause
In `JobApplication.java`, the foreign key was mapped as a JPA relationship, not as a raw field:
```java
@Entity
public class JobApplication {
    // Job FK is a relationship, NOT a simple Long field
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "job_id", nullable = false)
    private Job job;
    // Lombok @Data generates: getJob(), setJob() — NOT getJobId()!
}
```

I was calling `a.getJobId()` — which doesn't exist. Lombok only generates getters for declared fields. Since `jobId` is not a field (only `job` is), there's no `getJobId()`.

### The Fix

```java
// WRONG:
m.put("jobId", a.getJobId());  // method doesn't exist!

// CORRECT Option 1: Use the relationship proxy (no extra DB query)
m.put("jobId", a.getJob().getId());
// Hibernate proxy always knows its own ID — no DB query needed for just the ID

// CORRECT Option 2: Expose the raw FK as a separate field
@Column(name = "job_id", insertable = false, updatable = false)
private Long jobId;  // now getJobId() exists
// BUT: keep the @ManyToOne relationship for navigation
```

I used Option 1 everywhere. Hibernate proxies always have the entity ID in memory — calling `.getId()` on a proxy does NOT trigger a database query, which is efficient.

### What I Learned
- When using JPA `@ManyToOne`, the FK value is accessible via `entity.getRelation().getId()` — and this is efficient (no extra DB query)
- `@Column(insertable=false, updatable=false)` is a pattern for exposing both the FK Long and the relationship — useful for search/filter operations
- Always understand what methods Lombok `@Data` generates before calling them
- Read compilation errors carefully — "cannot find symbol" always points to a missing field or method name typo

---

## Challenge 9: Recruiter Dashboard Showing Hardcoded Fake Data

### The Symptom
The recruiter dashboard "Recent Applications" section showed:
- "Sarah Johnson — Senior Java Developer — SHORTLISTED"
- "Michael Chen — Full Stack Engineer — INTERVIEW"
- "Priya Sharma — DevOps Engineer — APPLIED"

These are fictional names hardcoded from the initial prototype. Real applications from real test users were not appearing.

### Root Cause
```javascript
// dashboard.jsp — BEFORE:
async function loadDashboardData() {
    if (window._candidateMode) return;
    // Mock stats
    animateCounter(document.getElementById('stat-jobs'), 0, 47, 1200);    // ← fake
    animateCounter(document.getElementById('stat-candidates'), 0, 312, 1400); // ← fake

    // Mock applications table — hardcoded fictional names
    document.getElementById('applications-table').innerHTML =
        generateMockRow('Sarah Johnson', 'Senior Java Developer', 94, 'SHORTLISTED', '2h ago') +
        generateMockRow('Michael Chen', 'Full Stack Engineer', 87, 'INTERVIEW', '5h ago') +
        generateMockRow('Priya Sharma', 'DevOps Engineer', 91, 'APPLIED', '1d ago');
        // ← hardcoded, always shows these names regardless of actual DB data
}
```

### The Fix

```javascript
// dashboard.jsp — AFTER: all real API calls
async function loadDashboardData() {
    if (window._candidateMode) return;

    // Real stats from API
    try {
        const stats = await Api.get('/api/applications/stats');
        const jobs  = await Api.get('/api/jobs?size=1&page=0');
        setTimeout(() => {
            animateCounter(document.getElementById('stat-jobs'),
                0, jobs.totalElements || 0, 1200);
            animateCounter(document.getElementById('stat-candidates'),
                0, stats.total || 0, 1400);
            animateCounter(document.getElementById('stat-interviews'),
                0, stats.interview || 0, 1600);
        }, 300);
    } catch(e) { /* leave as — */ }

    // Real applications from database
    try {
        const apps = await Api.get('/api/applications/shortlisted');
        const list = Array.isArray(apps) ? apps : [];
        const tbody = document.getElementById('applications-table');

        if (!list.length) {
            // Empty state — guides the recruiter
            tbody.innerHTML = `<tr><td colspan="6" class="text-center py-4">
                <i class="fas fa-inbox fa-2x mb-2 d-block"></i>
                No applications yet. <a href="/jobs">Post a job</a> to get started.
            </td></tr>`;
            return;
        }

        const statusMap = { APPLIED:'badge-pending', SHORTLISTED:'badge-hired', ... };
        tbody.innerHTML = list.slice(0, 10).map(a => `
            <tr>
                <td>Candidate #${a.candidateId}</td>
                <td>${a.jobTitle || 'Job #' + a.jobId}</td>
                <td><span class="badge-status ${statusMap[a.status]}">${a.status}</span></td>
                <td>${new Date(a.appliedAt).toLocaleDateString()}</td>
            </tr>
        `).join('');
    } catch(e) {
        document.getElementById('applications-table').innerHTML =
            '<tr><td colspan="6">Unable to load applications</td></tr>';
    }
}
```

### What I Learned
- **Never ship with hardcoded mock data in user-visible features** — it makes the system appear to "work" when it actually doesn't
- Always design for the **empty state** (what to show when there's no data yet)
- Graceful error handling in JS: always wrap API calls in try/catch and show meaningful fallback UI
- Mock data is fine for early prototyping but must be replaced **before** considering a feature complete

---

## Challenge 10: Analytics Page 404 — Real Data But Wrong Route

### The Symptom
The analytics page loaded fine (JSP rendered correctly), but:
- All KPI cards showed "Loading..." permanently
- A toast popped up: **"Could not load analytics: HTTP 404"**
- Browser console: `GET /api/applications/analytics?days=30  → 404 Not Found`

### Root Cause (Two-Part)

**Part 1 — Wrong service receiving the request:**
The `api-gateway` routes `/api/analytics/**` to `ANALYTICS-SERVICE`. But my analytics aggregation endpoint was in `RECRUITER-SERVICE` (because it queries `job_applications` and `jobs` tables which are recruiter-service's domain).

```yaml
# api-gateway routing:
/api/analytics/**    → ANALYTICS-SERVICE   ← my endpoint is NOT here
/api/applications/** → RECRUITER-SERVICE   ← my endpoint IS here
```

**Part 2 — Analytics-service not having this endpoint:**
The `analytics-service` module exists but its endpoints hadn't been built yet (it was a placeholder). So any request routed there got a 404.

### Debugging Steps
```bash
# Test 1: Call through gateway (gets 404)
curl http://localhost:8080/api/analytics?days=30 -H "Authorization: Bearer <token>"
# → 404

# Test 2: Call recruiter-service directly (bypassing gateway)
curl http://localhost:8083/api/analytics?days=30 -H "Authorization: Bearer <token>"
# → 200 with real data! Confirms endpoint is in recruiter-service, routing is the bug
```

### The Fix

**Option chosen: Rename endpoint to use existing route**
```java
// BEFORE: wrong path (routes to wrong service)
@GetMapping("/api/analytics")
public ResponseEntity<Map<String, Object>> getAnalytics(@RequestParam int days) { ... }

// AFTER: uses /api/applications/** route → correctly goes to RECRUITER-SERVICE
@GetMapping("/api/applications/analytics")
public ResponseEntity<Map<String, Object>> getAnalytics(@RequestParam int days) { ... }
```

```javascript
// analytics.jsp — updated JS call
const data = await Api.get('/api/applications/analytics?days=' + days);
```

### What I Learned
- In microservices, your URL prefix is both an API design decision AND an infrastructure routing decision
- **Always test through the full request chain** (browser → webapp → gateway → service), not just direct service calls
- Document your gateway routing table as a team contract — everyone must know which prefix routes where
- Sometimes the simplest fix (rename the URL) is better than modifying gateway config + rebuilding

---

## Summary: What These Challenges Taught Me

| Challenge | Core Lesson |
|-----------|-------------|
| Lazy Loading | Hibernate sessions, @Transactional lifecycle |
| JWT Expiry | Stateless auth, dev vs prod config separation |
| Gateway Routing | Microservice API design as infrastructure concern |
| CandidateId = 0 | Never use placeholders, validate FKs, defensive programming |
| Mock Response Order | Condition specificity, keyword disambiguation, unit testing |
| Entity Serialization | DTOs over direct entity exposure, Jackson and lazy loading |
| RBAC | Defense in depth: frontend UX + backend enforcement |
| getJobId() | JPA entity model, Hibernate proxy knowledge, Lombok contracts |
| Hardcoded Mock Data | Replace mocks before declaring features complete |
| 404 Analytics | API design aligns with gateway routes, test end-to-end |

> **The most valuable debugging skill I developed:** When something is wrong, reduce the system to its components — bypass the gateway and call the service directly to isolate where the failure occurs.
