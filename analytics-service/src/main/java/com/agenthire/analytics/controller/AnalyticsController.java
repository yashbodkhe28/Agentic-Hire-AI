package com.agenthire.analytics.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Analytics Service — consumes Kafka events and exposes aggregated metrics.
 */
@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
@Slf4j
public class AnalyticsController {

    // In-memory counters (use DB aggregation in production)
    private final AtomicLong totalApplications = new AtomicLong(0);
    private final AtomicLong totalInterviews = new AtomicLong(0);
    private final AtomicLong totalResumes = new AtomicLong(0);
    private final AtomicLong agentExecutions = new AtomicLong(0);
    private final ConcurrentHashMap<String, AtomicLong> agentTypeCount = new ConcurrentHashMap<>();

    // ======== Kafka Consumers ========

    @KafkaListener(topics = "application-events", groupId = "analytics-group")
    public void onApplicationEvent(Map<String, Object> event) {
        if ("APPLICATION_SUBMITTED".equals(event.get("eventType"))) {
            totalApplications.incrementAndGet();
            log.info("Analytics: Application submitted, total={}", totalApplications.get());
        }
    }

    @KafkaListener(topics = "interview-events", groupId = "analytics-group")
    public void onInterviewEvent(Map<String, Object> event) {
        if ("INTERVIEW_SCHEDULED".equals(event.get("eventType"))) {
            totalInterviews.incrementAndGet();
        }
    }

    @KafkaListener(topics = "resume-events", groupId = "analytics-group")
    public void onResumeEvent(Map<String, Object> event) {
        if ("RESUME_UPLOADED".equals(event.get("eventType"))) {
            totalResumes.incrementAndGet();
        }
    }

    @KafkaListener(topics = "agent-events", groupId = "analytics-group")
    public void onAgentEvent(Map<String, Object> event) {
        agentExecutions.incrementAndGet();
        String agentType = (String) event.getOrDefault("agentType", "UNKNOWN");
        agentTypeCount.computeIfAbsent(agentType, k -> new AtomicLong(0)).incrementAndGet();
    }

    // ======== REST Endpoints ========

    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> getSummary() {
        return ResponseEntity.ok(Map.of(
            "totalApplications", totalApplications.get(),
            "totalInterviews", totalInterviews.get(),
            "totalResumes", totalResumes.get(),
            "agentExecutions", agentExecutions.get(),
            "agentUsage", agentTypeCount,
            "generatedAt", LocalDateTime.now().toString()
        ));
    }

    @GetMapping("/hiring-funnel")
    public ResponseEntity<Map<String, Object>> getHiringFunnel() {
        // Returns mock aggregated funnel data
        // In production, query the DB with date range filters
        return ResponseEntity.ok(Map.of(
            "applied", totalApplications.get(),
            "screened", (long)(totalApplications.get() * 0.65),
            "shortlisted", (long)(totalApplications.get() * 0.35),
            "interviewed", totalInterviews.get(),
            "hired", (long)(totalInterviews.get() * 0.4),
            "conversionRate", totalApplications.get() > 0 ?
                String.format("%.1f%%", (totalInterviews.get() * 0.4 / totalApplications.get()) * 100) : "0%"
        ));
    }

    @GetMapping("/agent-usage")
    public ResponseEntity<Map<String, Object>> getAgentUsage() {
        return ResponseEntity.ok(Map.of(
            "totalExecutions", agentExecutions.get(),
            "byType", agentTypeCount,
            "timestamp", LocalDateTime.now().toString()
        ));
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "UP", "service", "analytics-service"));
    }
}
