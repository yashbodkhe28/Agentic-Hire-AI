package com.agenthire.agent.controller;

import com.agenthire.agent.agent.AgentContext;
import com.agenthire.agent.agent.AgentFactory;
import com.agenthire.agent.agent.AgentType;
import com.agenthire.agent.dto.AgentRequest;
import com.agenthire.agent.entity.AgentReport;
import com.agenthire.agent.repository.AgentReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/agents")
@RequiredArgsConstructor
public class AgentController {

    private final AgentContext agentContext;
    private final AgentFactory agentFactory;
    private final AgentReportRepository reportRepository;

    /**
     * Execute a specific agent synchronously
     */
    @PostMapping("/execute/{agentType}")
    public ResponseEntity<Map<String, Object>> executeAgent(
            @PathVariable String agentType,
            @RequestBody AgentRequest request) {
        AgentType type = AgentType.valueOf(agentType.toUpperCase());
        request.setAgentType(type);
        AgentReport report = agentContext.executeAgent(type, request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "reportId", report.getId(),
                "agentType", report.getAgentType(),
                "report", report.getReportJson(),
                "score", report.getScore() != null ? report.getScore() : 0,
                "recommendation", report.getRecommendation() != null ? report.getRecommendation() : "",
                "createdAt", report.getCreatedAt().toString()
        ));
    }

    /**
     * Get available agent types
     */
    @GetMapping("/types")
    public ResponseEntity<Map<String, Object>> getAvailableAgents() {
        List<AgentType> types = agentFactory.getAvailableAgentTypes();
        return ResponseEntity.ok(Map.of(
                "success", true,
                "agents", types,
                "count", types.size()
        ));
    }

    /**
     * Get all reports for a specific reference
     */
    @GetMapping("/reports/{referenceType}/{referenceId}")
    public ResponseEntity<Map<String, Object>> getReports(
            @PathVariable String referenceType,
            @PathVariable Long referenceId) {
        List<AgentReport> reports = reportRepository.findByReferenceTypeAndReferenceId(referenceType, referenceId);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "reports", reports,
                "count", reports.size()
        ));
    }

    /**
     * Get a specific report by ID
     */
    @GetMapping("/reports/{reportId}")
    public ResponseEntity<AgentReport> getReport(@PathVariable Long reportId) {
        return reportRepository.findById(reportId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Analyze resume — specialized endpoint
     */
    @PostMapping("/analyze-resume")
    public ResponseEntity<Map<String, Object>> analyzeResume(
            @RequestBody Map<String, Object> payload) {
        AgentRequest request = AgentRequest.builder()
                .agentType(AgentType.RESUME_ANALYZER)
                .payload(payload)
                .referenceType("RESUME")
                .referenceId(((Number) payload.getOrDefault("resumeId", 0)).longValue())
                .build();
        AgentReport report = agentContext.executeAgent(AgentType.RESUME_ANALYZER, request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "reportId", report.getId(),
                "analysis", report.getReportJson(),
                "score", report.getScore() != null ? report.getScore() : 0
        ));
    }

    /**
     * Generate interview questions — specialized endpoint
     */
    @PostMapping("/generate-questions")
    public ResponseEntity<Map<String, Object>> generateInterviewQuestions(
            @RequestBody Map<String, Object> payload) {
        AgentRequest request = AgentRequest.builder()
                .agentType(AgentType.INTERVIEW_QUESTION_GENERATOR)
                .payload(payload)
                .referenceType("INTERVIEW")
                .referenceId(((Number) payload.getOrDefault("interviewId", 0)).longValue())
                .build();
        AgentReport report = agentContext.executeAgent(AgentType.INTERVIEW_QUESTION_GENERATOR, request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "reportId", report.getId(),
                "questions", report.getReportJson()
        ));
    }

    /**
     * Recruiter copilot — specialized endpoint
     */
    @PostMapping("/recruiter-copilot")
    public ResponseEntity<Map<String, Object>> recruiterCopilot(
            @RequestBody Map<String, Object> payload) {
        AgentRequest request = AgentRequest.builder()
                .agentType(AgentType.RECRUITER_COPILOT)
                .payload(payload)
                .referenceType("RECRUITER")
                .referenceId(((Number) payload.getOrDefault("recruiterId", 0)).longValue())
                .build();
        AgentReport report = agentContext.executeAgent(AgentType.RECRUITER_COPILOT, request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "reportId", report.getId(),
                "content", report.getReportJson()
        ));
    }
}
