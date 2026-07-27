package com.agenthire.agent.agent.impl;

import com.agenthire.agent.agent.Agent;
import com.agenthire.agent.agent.AgentType;
import com.agenthire.agent.dto.AgentRequest;
import com.agenthire.agent.entity.AgentReport;
import com.agenthire.agent.llm.LlmProvider;
import com.agenthire.agent.repository.AgentReportRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

/**
 * AGENT 5: Hiring Recommender Agent
 * Final stage agent that aggregates all previous analysis (resume, match score, interview scores)
 * and makes the ultimate hiring recommendation.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class HiringRecommenderAgent implements Agent {

    private final LlmProvider llmProvider;
    private final AgentReportRepository reportRepository;

    private static final String SYSTEM_PROMPT = """
            You are an expert AI Hiring Decision Engine with deep experience in talent acquisition.
            Your role is to make the final hiring recommendation based on all available candidate data.
            
            You will receive:
            - Resume analysis results
            - Job matching scores
            - Interview evaluation scores
            - Behavioral assessment data
            
            Make a data-driven, fair, and objective final hiring decision.
            Consider diversity, potential, and growth trajectory in addition to current skills.
            
            Response must be valid JSON with this exact structure:
            {
              "finalDecision": "HIRE",
              "confidence": 0.87,
              "offerLevel": "SENIOR",
              "suggestedSalary": {
                "min": 120000,
                "max": 140000,
                "recommended": 130000,
                "currency": "USD"
              },
              "scoreSummary": {
                "resumeScore": 82,
                "matchScore": 78,
                "interviewScore": 85,
                "behavioralScore": 88,
                "aggregateScore": 83
              },
              "decisionFactors": {
                "positives": [
                  "Strong technical foundation in required stack",
                  "Excellent communication skills",
                  "Clear career growth trajectory"
                ],
                "negatives": [
                  "Limited cloud infrastructure experience",
                  "No team lead experience"
                ],
                "neutral": [
                  "Years of experience slightly below requirement"
                ]
              },
              "riskAssessment": {
                "technicalRisk": "LOW",
                "culturalRisk": "VERY_LOW",
                "retentionRisk": "MEDIUM",
                "onboardingRisk": "LOW"
              },
              "onboardingPlan": {
                "priorityAreas": ["Cloud infrastructure training", "Team processes"],
                "estimatedRampUpTime": "4-6 weeks",
                "mentorNeeded": true
              },
              "alternativeDecision": "If HIRE rejected, consider for contract position",
              "detailedRationale": "Based on comprehensive analysis...",
              "nextSteps": ["Send offer letter", "Background check", "Reference check"]
            }
            """;

    @Override
    public AgentType getType() { return AgentType.HIRING_RECOMMENDER; }

    @Override
    public String getName() { return "Hiring Recommender Agent"; }

    @Override
    public String getDescription() {
        return "Aggregates all candidate data and generates the final hiring decision with offer recommendations";
    }

    @Override
    public AgentReport execute(AgentRequest request) {
        String resumeAnalysis = (String) request.getPayload().getOrDefault("resumeAnalysis", "{}");
        String matchAnalysis = (String) request.getPayload().getOrDefault("matchAnalysis", "{}");
        String interviewEvaluation = (String) request.getPayload().getOrDefault("interviewEvaluation", "{}");
        String jobTitle = (String) request.getPayload().getOrDefault("jobTitle", "Software Engineer");
        String salaryRange = (String) request.getPayload().getOrDefault("salaryRange", "Not specified");

        String userPrompt = String.format("""
                Make a final hiring decision for the position: %s
                Salary Range: %s
                
                RESUME ANALYSIS:
                %s
                
                JOB MATCH ANALYSIS:
                %s
                
                INTERVIEW EVALUATION:
                %s
                
                Based on all available data, provide a comprehensive final hiring recommendation.
                Consider long-term potential, cultural fit, and growth trajectory.
                """, jobTitle, salaryRange, resumeAnalysis, matchAnalysis, interviewEvaluation);

        log.info("Executing HiringRecommenderAgent for reference: {}/{}", request.getReferenceType(), request.getReferenceId());

        String result = llmProvider.chat(SYSTEM_PROMPT, userPrompt, 0.4);

        AgentReport report = AgentReport.builder()
                .agentType(AgentType.HIRING_RECOMMENDER.name())
                .referenceType(request.getReferenceType())
                .referenceId(request.getReferenceId())
                .reportJson(result)
                .build();

        try {
            if (result.contains("\"aggregateScore\"")) {
                String scoreStr = result.replaceAll(".*\"aggregateScore\":\\s*(\\d+).*", "$1").trim().split("\n")[0];
                report.setScore(new BigDecimal(scoreStr.replaceAll("[^0-9]", "")));
            }
            if (result.contains("\"finalDecision\"")) {
                String decision = result.replaceAll(".*\"finalDecision\":\\s*\"([^\"]+)\".*", "$1").trim().split("\n")[0];
                report.setRecommendation(decision);
            }
        } catch (Exception e) {
            log.warn("Could not extract decision from HiringRecommenderAgent: {}", e.getMessage());
        }

        return reportRepository.save(report);
    }
}
