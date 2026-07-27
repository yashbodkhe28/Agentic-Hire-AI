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
 * AGENT 4: Interview Evaluator Agent
 * Evaluates interview responses, scores answers, identifies strengths/weaknesses,
 * and provides structured feedback with pass/fail recommendations.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class InterviewEvaluatorAgent implements Agent {

    private final LlmProvider llmProvider;
    private final AgentReportRepository reportRepository;

    private static final String SYSTEM_PROMPT = """
            You are an expert AI interview evaluator and technical assessor.
            Your role is to objectively evaluate interview responses and provide structured, fair assessments.
            
            Evaluate each answer based on:
            - Accuracy: Is the answer technically correct?
            - Depth: Does the candidate show deep understanding?
            - Communication: Is the explanation clear and structured?
            - Problem-Solving: Did they show good reasoning?
            - Best Practices: Do they mention industry standards?
            
            Response must be valid JSON with this exact structure:
            {
              "interviewId": "string",
              "overallScore": 78,
              "passFailDecision": "PASS",
              "confidence": 0.85,
              "questionEvaluations": [
                {
                  "questionId": 1,
                  "question": "Explain HashMap internals",
                  "candidateAnswer": "string",
                  "score": 85,
                  "maxScore": 100,
                  "feedback": "Good explanation of hash functions, missed collision handling",
                  "keyPointsCovered": ["Hash function", "Array structure"],
                  "keyPointsMissed": ["Collision resolution", "Load factor"],
                  "rating": "GOOD"
                }
              ],
              "categoryScores": {
                "technical": 82,
                "systemDesign": 75,
                "problemSolving": 78,
                "behavioral": 85,
                "communication": 90
              },
              "strengths": ["Excellent communication", "Strong Java fundamentals"],
              "areasForImprovement": ["Needs to improve on distributed systems", "More practice on complexity analysis"],
              "behavioralInsights": {
                "enthusiasm": "HIGH",
                "cultureFit": "GOOD",
                "growthMindset": true
              },
              "detailedFeedback": "The candidate demonstrated...",
              "nextSteps": "PROCEED_TO_HR_ROUND",
              "notes": "Consider for senior position in future"
            }
            """;

    @Override
    public AgentType getType() { return AgentType.INTERVIEW_EVALUATOR; }

    @Override
    public String getName() { return "Interview Evaluator Agent"; }

    @Override
    public String getDescription() {
        return "Evaluates interview responses, scores answers, and generates pass/fail recommendations with detailed feedback";
    }

    @Override
    public AgentReport execute(AgentRequest request) {
        String interviewTranscript = (String) request.getPayload().getOrDefault("interviewTranscript", "");
        String questionsAndAnswers = (String) request.getPayload().getOrDefault("questionsAndAnswers", "[]");
        String jobTitle = (String) request.getPayload().getOrDefault("jobTitle", "Software Engineer");

        String userPrompt = String.format("""
                Evaluate the following interview for the role of %s:
                
                INTERVIEW TRANSCRIPT:
                %s
                
                QUESTIONS AND ANSWERS:
                %s
                
                Provide a comprehensive evaluation of each answer and an overall assessment.
                Be objective, fair, and detailed in your evaluation.
                """, jobTitle, interviewTranscript, questionsAndAnswers);

        log.info("Executing InterviewEvaluatorAgent for reference: {}/{}", request.getReferenceType(), request.getReferenceId());

        String result = llmProvider.chat(SYSTEM_PROMPT, userPrompt, 0.3);

        AgentReport report = AgentReport.builder()
                .agentType(AgentType.INTERVIEW_EVALUATOR.name())
                .referenceType(request.getReferenceType())
                .referenceId(request.getReferenceId())
                .reportJson(result)
                .build();

        try {
            if (result.contains("\"overallScore\"")) {
                String scoreStr = result.replaceAll(".*\"overallScore\":\\s*(\\d+).*", "$1").trim().split("\n")[0];
                report.setScore(new BigDecimal(scoreStr.replaceAll("[^0-9]", "")));
            }
            if (result.contains("\"passFailDecision\"")) {
                String decision = result.replaceAll(".*\"passFailDecision\":\\s*\"([^\"]+)\".*", "$1").trim().split("\n")[0];
                report.setRecommendation(decision);
            }
        } catch (Exception e) {
            log.warn("Could not extract score from InterviewEvaluatorAgent: {}", e.getMessage());
        }

        return reportRepository.save(report);
    }
}
