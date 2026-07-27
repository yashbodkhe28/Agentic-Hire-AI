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
 * AGENT 2: Job Matching Agent
 * Compares candidate profiles with job requirements, calculates compatibility scores,
 * recommends jobs, and generates hiring probability assessments.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class JobMatchingAgent implements Agent {

    private final LlmProvider llmProvider;
    private final AgentReportRepository reportRepository;

    private static final String SYSTEM_PROMPT = """
            You are an expert AI job matching specialist with deep knowledge of the software engineering job market.
            Your role is to objectively assess the compatibility between candidates and job openings.
            
            Analyze the candidate profile against job requirements and provide a detailed matching assessment.
            Consider: technical skills alignment, experience level fit, industry knowledge, soft skills, career trajectory.
            
            Response must be valid JSON with this exact structure:
            {
              "overallMatchPercentage": 78,
              "hiringProbability": 0.72,
              "skillsMatch": {
                "matchedSkills": ["Java", "Spring Boot", "MySQL"],
                "missingRequiredSkills": ["Kubernetes"],
                "missingNiceToHaveSkills": ["GraphQL"],
                "extraSkills": ["Python", "AWS"]
              },
              "experienceMatch": {
                "requiredYears": 5,
                "candidateYears": 4.5,
                "levelFit": "GOOD",
                "comment": "Slightly below required but strong trajectory"
              },
              "strengthsForRole": ["Strong Java expertise", "Relevant domain experience"],
              "weaknessesForRole": ["Limited cloud experience"],
              "skillGapAnalysis": {
                "criticalGaps": ["Kubernetes"],
                "moderateGaps": ["GraphQL", "Terraform"],
                "timeToClose": "3-6 months with focused learning"
              },
              "recommendation": "SHORTLIST",
              "reasoning": "Detailed reasoning for the recommendation...",
              "interviewRecommendations": [
                "Focus on system design round",
                "Assess cloud knowledge depth"
              ],
              "salaryFit": {
                "expectedSalary": 120000,
                "jobRangeMin": 110000,
                "jobRangeMax": 140000,
                "assessment": "WITHIN_RANGE"
              }
            }
            """;

    @Override
    public AgentType getType() { return AgentType.JOB_MATCHER; }

    @Override
    public String getName() { return "Job Matching Agent"; }

    @Override
    public String getDescription() {
        return "Compares candidate profiles with job requirements and calculates compatibility scores";
    }

    @Override
    public AgentReport execute(AgentRequest request) {
        String candidateProfile = (String) request.getPayload().getOrDefault("candidateProfile", "{}");
        String jobRequirements = (String) request.getPayload().getOrDefault("jobRequirements", "{}");
        String jobTitle = (String) request.getPayload().getOrDefault("jobTitle", "Software Engineer");

        String userPrompt = String.format("""
                Match the following candidate against the job requirements:
                
                JOB TITLE: %s
                
                JOB REQUIREMENTS:
                %s
                
                CANDIDATE PROFILE:
                %s
                
                Provide a detailed matching analysis in the exact JSON format specified.
                Be objective and data-driven in your assessment.
                """, jobTitle, jobRequirements, candidateProfile);

        log.info("Executing JobMatchingAgent for reference: {}/{}", request.getReferenceType(), request.getReferenceId());

        String result = llmProvider.chat(SYSTEM_PROMPT, userPrompt, 0.4);

        AgentReport report = AgentReport.builder()
                .agentType(AgentType.JOB_MATCHER.name())
                .referenceType(request.getReferenceType())
                .referenceId(request.getReferenceId())
                .reportJson(result)
                .build();

        try {
            if (result.contains("\"overallMatchPercentage\"")) {
                String scoreStr = result.replaceAll(".*\"overallMatchPercentage\":\\s*(\\d+).*", "$1").trim().split("\n")[0];
                report.setScore(new BigDecimal(scoreStr.replaceAll("[^0-9]", "")));
            }
            if (result.contains("\"recommendation\"")) {
                String rec = result.replaceAll(".*\"recommendation\":\\s*\"([^\"]+)\".*", "$1").trim().split("\n")[0];
                report.setRecommendation(rec);
            }
        } catch (Exception e) {
            log.warn("Could not extract score from JobMatchingAgent response: {}", e.getMessage());
        }

        return reportRepository.save(report);
    }
}
