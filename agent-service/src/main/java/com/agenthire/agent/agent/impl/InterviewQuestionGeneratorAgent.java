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
 * AGENT 3: Interview Question Generator Agent
 * Generates personalized, role-specific interview questions based on
 * the candidate's profile and job requirements.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class InterviewQuestionGeneratorAgent implements Agent {

    private final LlmProvider llmProvider;
    private final AgentReportRepository reportRepository;

    private static final String SYSTEM_PROMPT = """
            You are an expert AI technical interviewer and assessment specialist.
            Your role is to generate comprehensive, relevant interview questions tailored to the specific candidate and role.
            
            Generate questions across multiple dimensions:
            1. Technical Knowledge: Core concepts, algorithms, data structures
            2. Practical Experience: Scenario-based, situational questions
            3. System Design: Architecture, scalability, design patterns
            4. Problem-Solving: Coding challenges, debugging scenarios
            5. Behavioral/HR: Culture fit, teamwork, leadership
            6. Role-Specific: Domain expertise for the particular role
            
            Response must be valid JSON with this exact structure:
            {
              "roleTitle": "Senior Java Developer",
              "difficulty": "MID_TO_SENIOR",
              "estimatedDuration": "90 minutes",
              "questions": {
                "technical": [
                  {
                    "id": 1,
                    "question": "Explain the difference between HashMap and ConcurrentHashMap",
                    "expectedAnswer": "Detailed expected answer key points...",
                    "difficulty": "MEDIUM",
                    "topic": "Java Concurrency",
                    "followUps": ["How would you handle thread safety at scale?"],
                    "timeAllocation": "5 minutes"
                  }
                ],
                "systemDesign": [
                  {
                    "id": 6,
                    "question": "Design a distributed job scheduling system for 1M concurrent users",
                    "keyPoints": ["Scalability", "Fault tolerance", "State management"],
                    "difficulty": "HARD",
                    "timeAllocation": "20 minutes"
                  }
                ],
                "problemSolving": [
                  {
                    "id": 11,
                    "question": "Implement a thread-safe LRU cache",
                    "hints": ["Consider using LinkedHashMap", "Think about synchronization"],
                    "solutionApproach": "Use ConcurrentLinkedDeque with synchronized methods...",
                    "timeAllocation": "25 minutes"
                  }
                ],
                "behavioral": [
                  {
                    "id": 16,
                    "question": "Tell me about a time you had to refactor a critical production system",
                    "starMethod": true,
                    "evaluationCriteria": ["Problem identification", "Risk mitigation", "Communication"]
                  }
                ]
              },
              "evaluationRubric": {
                "technical": 40,
                "systemDesign": 25,
                "problemSolving": 20,
                "behavioral": 15
              },
              "redFlags": ["Inability to explain thread safety", "No unit testing knowledge"],
              "greenFlags": ["Mentions monitoring and observability", "Discusses tradeoffs proactively"]
            }
            """;

    @Override
    public AgentType getType() { return AgentType.INTERVIEW_QUESTION_GENERATOR; }

    @Override
    public String getName() { return "Interview Question Generator Agent"; }

    @Override
    public String getDescription() {
        return "Generates personalized technical and behavioral interview questions based on candidate profile and role";
    }

    @Override
    public AgentReport execute(AgentRequest request) {
        String candidateSkills = (String) request.getPayload().getOrDefault("candidateSkills", "");
        String jobTitle = (String) request.getPayload().getOrDefault("jobTitle", "Software Engineer");
        String jobRequirements = (String) request.getPayload().getOrDefault("jobRequirements", "");
        String experienceLevel = (String) request.getPayload().getOrDefault("experienceLevel", "MID");
        int questionCount = (int) request.getPayload().getOrDefault("questionCount", 20);

        String userPrompt = String.format("""
                Generate %d interview questions for the following interview:
                
                ROLE: %s
                EXPERIENCE LEVEL: %s
                
                JOB REQUIREMENTS:
                %s
                
                CANDIDATE SKILLS (for personalization):
                %s
                
                Generate a comprehensive question set tailored to this specific candidate and role.
                Ensure questions are progressive in difficulty and cover all required competencies.
                Provide expected answer key points for technical questions.
                """, questionCount, jobTitle, experienceLevel, jobRequirements, candidateSkills);

        log.info("Executing InterviewQuestionGeneratorAgent for reference: {}/{}", request.getReferenceType(), request.getReferenceId());

        String result = llmProvider.chat(SYSTEM_PROMPT, userPrompt, 0.8); // Higher temperature for creativity

        AgentReport report = AgentReport.builder()
                .agentType(AgentType.INTERVIEW_QUESTION_GENERATOR.name())
                .referenceType(request.getReferenceType())
                .referenceId(request.getReferenceId())
                .reportJson(result)
                .recommendation("Questions Generated")
                .build();

        return reportRepository.save(report);
    }
}
