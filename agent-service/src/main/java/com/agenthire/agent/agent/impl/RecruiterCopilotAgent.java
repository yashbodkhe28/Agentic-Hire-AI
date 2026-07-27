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

/**
 * AGENT 6: Recruiter Copilot Agent
 * AI assistant for recruiters — helps write job descriptions, compose candidate outreach emails,
 * draft rejection emails, and provides hiring strategy advice.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RecruiterCopilotAgent implements Agent {

    private final LlmProvider llmProvider;
    private final AgentReportRepository reportRepository;

    private static final String SYSTEM_PROMPT = """
            You are an expert AI Recruiter Copilot assistant designed to assist HR professionals and recruiters.
            You help with all aspects of the recruitment process:
            - Writing compelling, inclusive job descriptions
            - Crafting personalized candidate outreach messages
            - Composing professional rejection emails with feedback
            - Providing hiring strategy advice and market insights
            - Drafting interview invitations and scheduling messages
            
            Always be professional, empathetic, and inclusive in all communications.
            For job descriptions, follow modern best practices: use gender-neutral language, 
            avoid excessive requirements, highlight growth opportunities.
            
            Response must be valid JSON with this exact structure:
            {
              "taskType": "JOB_DESCRIPTION | OUTREACH_EMAIL | REJECTION_EMAIL | INTERVIEW_INVITE | STRATEGY_ADVICE",
              "content": {
                "subject": "string (for emails)",
                "body": "Full content here...",
                "toneAnalysis": "professional, empathetic, engaging",
                "inclusivityScore": 92
              },
              "alternatives": [
                "Alternative version 1...",
                "Alternative version 2..."
              ],
              "seoKeywords": ["Java Developer", "Remote Work", "Spring Boot"],
              "estimatedReachScore": 85,
              "improvementSuggestions": [
                "Consider adding more specific growth opportunities",
                "Salary range transparency will increase applications by ~30%"
              ]
            }
            """;

    @Override
    public AgentType getType() { return AgentType.RECRUITER_COPILOT; }

    @Override
    public String getName() { return "Recruiter Copilot Agent"; }

    @Override
    public String getDescription() {
        return "AI assistant for recruiters — writes job descriptions, outreach emails, rejection letters, and provides strategy advice";
    }

    @Override
    public AgentReport execute(AgentRequest request) {
        String taskType = (String) request.getPayload().getOrDefault("taskType", "JOB_DESCRIPTION");
        String context = (String) request.getPayload().getOrDefault("context", "");
        String additionalInstructions = (String) request.getPayload().getOrDefault("instructions", "");

        String userPrompt = String.format("""
                Task Type: %s
                
                Context:
                %s
                
                Additional Instructions: %s
                
                Please create professional, engaging content for the above task.
                Follow all best practices for modern recruitment communications.
                Be inclusive, compelling, and respectful in all content.
                """, taskType, context, additionalInstructions);

        log.info("Executing RecruiterCopilotAgent task: {} for reference: {}/{}", 
                taskType, request.getReferenceType(), request.getReferenceId());

        String result = llmProvider.chat(SYSTEM_PROMPT, userPrompt, 0.75);

        AgentReport report = AgentReport.builder()
                .agentType(AgentType.RECRUITER_COPILOT.name())
                .referenceType(request.getReferenceType())
                .referenceId(request.getReferenceId())
                .reportJson(result)
                .recommendation(taskType + "_GENERATED")
                .build();

        return reportRepository.save(report);
    }
}
