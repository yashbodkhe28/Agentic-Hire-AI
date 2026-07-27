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
 * AGENT 1: Resume Analyzer Agent
 * Analyzes candidate resumes, extracts skills, projects, certifications,
 * calculates skill scores, and generates candidate summaries.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ResumeAnalyzerAgent implements Agent {

    private final LlmProvider llmProvider;
    private final AgentReportRepository reportRepository;

    private static final String SYSTEM_PROMPT = """
            You are an expert AI resume analyzer with 15+ years of experience in technical recruitment.
            Your job is to perform a comprehensive analysis of resumes for software engineering roles.
            
            Analyze the provided resume and extract structured information. You must respond ONLY with valid JSON.
            
            Your analysis should include:
            1. Technical Skills Detection: Identify all programming languages, frameworks, tools, databases, cloud platforms
            2. Project Analysis: Extract notable projects with tech stack and impact
            3. Certifications: List all professional certifications
            4. Experience Evaluation: Assess years of experience, roles, and career progression
            5. Skill Score Calculation: Rate overall technical competency from 0-100
            6. Gap Analysis: Identify missing skills if job requirements are provided
            
            Response must be valid JSON with this exact structure:
            {
              "candidateName": "string",
              "overallScore": 85,
              "summary": "Professional summary in 2-3 sentences",
              "experienceYears": 5.5,
              "currentRole": "string",
              "skills": {
                "languages": ["Java", "Python"],
                "frameworks": ["Spring Boot", "React"],
                "databases": ["MySQL", "Redis"],
                "cloud": ["AWS", "Docker"],
                "tools": ["Git", "Jenkins"],
                "other": []
              },
              "projects": [
                {
                  "name": "string",
                  "description": "string",
                  "techStack": ["Java", "Spring Boot"],
                  "impact": "string"
                }
              ],
              "certifications": [
                {
                  "name": "string",
                  "issuer": "string",
                  "year": 2023
                }
              ],
              "education": [
                {
                  "degree": "string",
                  "institution": "string",
                  "year": 2019,
                  "gpa": "3.8"
                }
              ],
              "strengths": ["Strong system design skills", "Excellent Java expertise"],
              "weaknesses": ["Limited cloud experience", "No mobile development"],
              "missingSkills": ["Kubernetes", "GraphQL"],
              "matchScore": 78,
              "hiringSentiment": "STRONG_POSITIVE",
              "recommendations": ["Strengthen cloud skills", "Add system design projects"]
            }
            """;

    @Override
    public AgentType getType() {
        return AgentType.RESUME_ANALYZER;
    }

    @Override
    public String getName() {
        return "Resume Analyzer Agent";
    }

    @Override
    public String getDescription() {
        return "Analyzes resumes, extracts skills, detects projects, calculates skill scores, and generates candidate summaries";
    }

    @Override
    public AgentReport execute(AgentRequest request) {
        String resumeContent = (String) request.getPayload().getOrDefault("resumeContent", "");
        String jobRequirements = (String) request.getPayload().getOrDefault("jobRequirements", "Not specified");

        String userPrompt = String.format("""
                Please analyze the following resume:
                
                ===RESUME START===
                %s
                ===RESUME END===
                
                Job Requirements (if any): %s
                
                Provide a comprehensive analysis in the exact JSON format specified.
                """, resumeContent, jobRequirements);

        log.info("Executing ResumeAnalyzerAgent for reference: {}/{}", request.getReferenceType(), request.getReferenceId());

        String result = llmProvider.chat(SYSTEM_PROMPT, userPrompt, 0.3); // Low temperature for consistent scoring

        AgentReport report = AgentReport.builder()
                .agentType(AgentType.RESUME_ANALYZER.name())
                .referenceType(request.getReferenceType())
                .referenceId(request.getReferenceId())
                .reportJson(result)
                .build();

        // Try to extract score from JSON
        try {
            if (result.contains("\"overallScore\"")) {
                String scoreStr = result.replaceAll(".*\"overallScore\":\\s*(\\d+).*", "$1");
                report.setScore(new BigDecimal(scoreStr.trim().split("\n")[0].replaceAll("[^0-9]", "")));
            }
            if (result.contains("\"hiringSentiment\"")) {
                String sentiment = result.replaceAll(".*\"hiringSentiment\":\\s*\"([^\"]+)\".*", "$1");
                report.setRecommendation(sentiment.trim().split("\n")[0]);
            }
        } catch (Exception e) {
            log.warn("Could not extract score/recommendation from agent response: {}", e.getMessage());
        }

        return reportRepository.save(report);
    }
}
