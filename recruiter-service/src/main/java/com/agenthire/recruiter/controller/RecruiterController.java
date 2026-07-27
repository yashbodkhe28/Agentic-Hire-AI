package com.agenthire.recruiter.controller;

import com.agenthire.recruiter.entity.*;
import com.agenthire.recruiter.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequiredArgsConstructor
public class RecruiterController {

    private final JobRepository jobRepository;
    private final JobApplicationRepository applicationRepository;
    private final RecruiterRepository recruiterRepository;
    private final CompanyRepository companyRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    // ========= COMPANIES =========
    @GetMapping("/api/companies")
    public ResponseEntity<List<Company>> getAllCompanies() {
        return ResponseEntity.ok(companyRepository.findAll());
    }

    @PostMapping("/api/companies")
    public ResponseEntity<Company> createCompany(@RequestBody Map<String, Object> data) {
        Company company = Company.builder()
                .name((String) data.get("name"))
                .description((String) data.get("description"))
                .website((String) data.get("website"))
                .industry((String) data.get("industry"))
                .size((String) data.get("size"))
                .location((String) data.get("location"))
                .build();
        return ResponseEntity.status(201).body(companyRepository.save(company));
    }

    @GetMapping("/api/companies/{id}")
    public ResponseEntity<Company> getCompany(@PathVariable Long id) {
        return companyRepository.findById(id).map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // ========= RECRUITERS =========
    @PostMapping("/api/recruiters/user/{userId}")
    public ResponseEntity<Recruiter> createRecruiter(@PathVariable Long userId,
                                                      @RequestBody Map<String, Object> data) {
        Company company = data.get("companyId") != null ?
                companyRepository.findById(((Number) data.get("companyId")).longValue()).orElse(null) : null;
        Recruiter recruiter = Recruiter.builder()
                .userId(userId)
                .company(company)
                .designation((String) data.get("designation"))
                .department((String) data.get("department"))
                .build();
        return ResponseEntity.status(201).body(recruiterRepository.save(recruiter));
    }

    @GetMapping("/api/recruiters/user/{userId}")
    public ResponseEntity<Recruiter> getRecruiterByUserId(@PathVariable Long userId) {
        return recruiterRepository.findByUserId(userId)
                .map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // ========= JOBS =========
    @GetMapping("/api/jobs")
    public ResponseEntity<Page<Job>> searchJobs(
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) Boolean isRemote,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Job> jobs = jobRepository.searchJobs(title, location, JobStatus.ACTIVE, isRemote, pageable);
        return ResponseEntity.ok(jobs);
    }

    @GetMapping("/api/jobs/{id}")
    public ResponseEntity<Job> getJob(@PathVariable Long id) {
        return jobRepository.findById(id).map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/api/jobs")
    public ResponseEntity<?> createJob(@RequestBody Map<String, Object> data,
                                        @RequestHeader(value = "X-User-Id", required = false) String userId,
                                        @RequestHeader(value = "X-User-Email", required = false) String userEmail) {
        if (userId == null || userId.isBlank()) {
            return ResponseEntity.status(400).body(
                Map.of("success", false,
                       "message", "Session expired — please sign out and sign back in to post jobs."));
        }

        long uid = Long.parseLong(userId);

        // Auto-create recruiter + company profile if not yet set up
        Recruiter recruiter = recruiterRepository.findByUserId(uid).orElseGet(() -> {
            // Create a default company for this recruiter
            Company company = Company.builder()
                    .name(userEmail != null ? userEmail.split("@")[0] + "'s Company" : "My Company")
                    .description("Auto-created company profile")
                    .industry("Technology")
                    .location("India")
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build();
            company = companyRepository.save(company);

            Recruiter newRecruiter = Recruiter.builder()
                    .userId(uid)
                    .company(company)
                    .designation("Recruiter")
                    .department("Human Resources")
                    .isActive(true)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build();
            return recruiterRepository.save(newRecruiter);
        });

        Job job = Job.builder()
                .recruiter(recruiter)
                .company(recruiter.getCompany())
                .title((String) data.get("title"))
                .description((String) data.get("description"))
                .requirements((String) data.get("requirements"))
                .responsibilities((String) data.get("responsibilities"))
                .location((String) data.get("location"))
                .isRemote(Boolean.TRUE.equals(data.get("isRemote")))
                .status(JobStatus.ACTIVE)
                .build();

        if (data.get("jobType") != null)
            job.setJobType(JobType.valueOf(data.get("jobType").toString().toUpperCase()));
        if (data.get("experienceLevel") != null)
            job.setExperienceLevel(ExperienceLevel.valueOf(data.get("experienceLevel").toString().toUpperCase()));
        if (data.get("minSalary") != null)
            job.setMinSalary(new BigDecimal(data.get("minSalary").toString()));
        if (data.get("maxSalary") != null)
            job.setMaxSalary(new BigDecimal(data.get("maxSalary").toString()));
        if (data.get("deadline") != null)
            job.setDeadline(LocalDate.parse(data.get("deadline").toString()));

        Job saved = jobRepository.save(job);
        try {
            kafkaTemplate.send("job-events", String.valueOf(saved.getId()),
                    Map.of("eventType", "JOB_POSTED", "jobId", saved.getId(),
                           "recruiterId", recruiter.getId(), "timestamp", LocalDateTime.now().toString()));
        } catch (Exception e) { /* non-critical */ }

        return ResponseEntity.status(201).body(Map.of(
                "success", true,
                "id", saved.getId(),
                "title", saved.getTitle() != null ? saved.getTitle() : "",
                "status", saved.getStatus() != null ? saved.getStatus().name() : "ACTIVE",
                "message", "Job posted successfully!"
        ));
    }


    @PutMapping("/api/jobs/{id}")
    public ResponseEntity<Job> updateJob(@PathVariable Long id, @RequestBody Map<String, Object> data) {
        return jobRepository.findById(id).map(job -> {
            if (data.get("title") != null) job.setTitle((String) data.get("title"));
            if (data.get("description") != null) job.setDescription((String) data.get("description"));
            if (data.get("status") != null) job.setStatus(JobStatus.valueOf(data.get("status").toString()));
            if (data.get("isRemote") != null) job.setIsRemote(Boolean.TRUE.equals(data.get("isRemote")));
            return ResponseEntity.ok(jobRepository.save(job));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/api/jobs/{id}")
    public ResponseEntity<Void> deleteJob(@PathVariable Long id) {
        jobRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // ========= APPLICATIONS =========
    @PostMapping("/api/applications")
    public ResponseEntity<?> applyForJob(@RequestBody Map<String, Object> data) {

        Long jobId = ((Number) data.get("jobId")).longValue();
        Long candidateId = ((Number) data.get("candidateId")).longValue();

        // Prevent duplicate applications
        if (applicationRepository.findByCandidateIdAndJobId(candidateId, jobId).isPresent()) {
            return ResponseEntity.status(409).build();
        }

        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found: " + jobId));

        JobApplication application = JobApplication.builder()
                .candidateId(candidateId)
                .job(job)
                .resumeId(data.get("resumeId") != null ? ((Number) data.get("resumeId")).longValue() : null)
                .coverLetter((String) data.get("coverLetter"))
                .status(ApplicationStatus.APPLIED)
                .build();

        JobApplication saved = applicationRepository.save(application);

        try {
            kafkaTemplate.send("application-events", String.valueOf(saved.getId()),
                    Map.of("eventType", "APPLICATION_SUBMITTED", "applicationId", saved.getId(),
                           "jobId", jobId, "candidateId", candidateId,
                           "timestamp", LocalDateTime.now().toString()));
        } catch (Exception e) { /* non-critical */ }

        // Return plain map to avoid Hibernate lazy-proxy serialization errors
        return ResponseEntity.status(201).body(Map.of(
                "success", true,
                "id", saved.getId(),
                "jobId", jobId,
                "candidateId", candidateId,
                "status", "APPLIED",
                "message", "Application submitted successfully!"
        ));
    }


    @GetMapping("/api/applications/job/{jobId}")
    public ResponseEntity<List<JobApplication>> getApplicationsByJob(@PathVariable Long jobId) {
        return ResponseEntity.ok(applicationRepository.findByJobId(jobId));
    }

    @Transactional(readOnly = true)
    @GetMapping("/api/applications/candidate/{candidateId}")
    public ResponseEntity<List<Map<String, Object>>> getApplicationsByCandidate(@PathVariable Long candidateId) {
        List<JobApplication> apps = applicationRepository.findByCandidateId(candidateId);
        List<Map<String, Object>> result = apps.stream().map(a -> {
            Map<String, Object> m = new java.util.LinkedHashMap<>();
            m.put("id", a.getId());
            m.put("candidateId", a.getCandidateId());
            m.put("jobId", a.getJob() != null ? a.getJob().getId() : null);
            m.put("status", a.getStatus().name());
            m.put("appliedAt", a.getAppliedAt() != null ? a.getAppliedAt().toString() : null);
            m.put("coverLetter", a.getCoverLetter());
            if (a.getJob() != null) {
                m.put("jobTitle", a.getJob().getTitle());
                m.put("companyName", a.getJob().getCompany() != null ? a.getJob().getCompany().getName() : "");
            }
            return m;
        }).collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(result);
    }


    @PutMapping("/api/applications/{id}/status")
    public ResponseEntity<?> updateApplicationStatus(
            @PathVariable Long id, @RequestBody Map<String, Object> data) {
        return applicationRepository.findById(id).map(app -> {
            app.setStatus(ApplicationStatus.valueOf(data.get("status").toString().toUpperCase()));
            applicationRepository.save(app);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "id", app.getId(),
                "status", app.getStatus().name()
            ));
        }).orElse(ResponseEntity.notFound().build());
    }
    @Transactional(readOnly = true)
    @GetMapping("/api/applications/shortlisted")
    public ResponseEntity<List<Map<String, Object>>> getShortlistedApplications() {
        List<ApplicationStatus> active = List.of(
            ApplicationStatus.SHORTLISTED, ApplicationStatus.INTERVIEW, ApplicationStatus.HIRED
        );
        List<JobApplication> apps = applicationRepository.findByStatusIn(active);
        List<Map<String, Object>> result = apps.stream().map(a -> {
            Map<String, Object> m = new java.util.LinkedHashMap<>();
            m.put("id", a.getId());
            m.put("candidateId", a.getCandidateId());
            m.put("jobId", a.getJob() != null ? a.getJob().getId() : null);
            m.put("status", a.getStatus().name());
            m.put("appliedAt", a.getAppliedAt() != null ? a.getAppliedAt().toString() : null);
            m.put("coverLetter", a.getCoverLetter());
            if (a.getJob() != null) {
                m.put("jobTitle", a.getJob().getTitle());
                m.put("companyName", a.getJob().getCompany() != null ? a.getJob().getCompany().getName() : "");
            }
            return m;
        }).collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/api/applications/stats")
    public ResponseEntity<Map<String, Object>> getApplicationStats() {
        return ResponseEntity.ok(Map.of(
            "total", applicationRepository.count(),
            "applied", applicationRepository.countByStatus(ApplicationStatus.APPLIED),
            "shortlisted", applicationRepository.countByStatus(ApplicationStatus.SHORTLISTED),
            "interview", applicationRepository.countByStatus(ApplicationStatus.INTERVIEW),
            "hired", applicationRepository.countByStatus(ApplicationStatus.HIRED),
            "rejected", applicationRepository.countByStatus(ApplicationStatus.REJECTED)
        ));
    }

    /** Comprehensive analytics endpoint for the Analytics dashboard */
    @Transactional(readOnly = true)
    @GetMapping("/api/applications/analytics")
    public ResponseEntity<Map<String, Object>> getAnalytics(@RequestParam(defaultValue = "30") int days) {
        Map<String, Object> result = new LinkedHashMap<>();

        // ── KPIs ──────────────────────────────────────────────────────────
        long totalApps   = applicationRepository.count();
        long hired       = applicationRepository.countByStatus(ApplicationStatus.HIRED);
        long shortlisted = applicationRepository.countByStatus(ApplicationStatus.SHORTLISTED);
        long interview   = applicationRepository.countByStatus(ApplicationStatus.INTERVIEW);
        long offered     = applicationRepository.countByStatus(ApplicationStatus.OFFERED);
        long rejected    = applicationRepository.countByStatus(ApplicationStatus.REJECTED);
        long applied     = applicationRepository.countByStatus(ApplicationStatus.APPLIED);
        long screening   = applicationRepository.countByStatus(ApplicationStatus.SCREENING);
        long totalJobs   = jobRepository.count();
        long activeJobs  = jobRepository.findByStatus(JobStatus.ACTIVE).size();

        Map<String, Object> kpis = new LinkedHashMap<>();
        kpis.put("totalApplications", totalApps);
        kpis.put("hired", hired);
        kpis.put("interview", interview);
        kpis.put("shortlisted", shortlisted);
        kpis.put("totalJobs", totalJobs);
        kpis.put("activeJobs", activeJobs);
        result.put("kpis", kpis);

        // ── Funnel ────────────────────────────────────────────────────────
        Map<String, Long> funnel = new LinkedHashMap<>();
        funnel.put("Applied",     applied);
        funnel.put("Screening",   screening);
        funnel.put("Shortlisted", shortlisted);
        funnel.put("Interview",   interview);
        funnel.put("Offered",     offered);
        funnel.put("Hired",       hired);
        result.put("funnel", funnel);

        // ── Job type distribution ─────────────────────────────────────────
        Map<String, Long> jobTypes = new LinkedHashMap<>();
        for (JobType jt : JobType.values()) {
            long cnt = jobRepository.findAll().stream()
                .filter(j -> j.getJobType() == jt).count();
            jobTypes.put(jt.name(), cnt);
        }
        result.put("jobTypes", jobTypes);

        // ── Applications per day (last N days) ────────────────────────────
        List<Object[]> rawDays = applicationRepository.countByDateLastNDays(days);
        List<Map<String, Object>> timeline = new ArrayList<>();
        for (Object[] row : rawDays) {
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("date",  row[0] != null ? row[0].toString() : "");
            entry.put("count", row[1] != null ? ((Number) row[1]).longValue() : 0L);
            timeline.add(entry);
        }
        result.put("timeline", timeline);
        result.put("days", days);

        return ResponseEntity.ok(result);
    }
}

