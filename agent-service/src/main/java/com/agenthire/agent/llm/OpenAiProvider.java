package com.agenthire.agent.llm;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * Adapter implementation for OpenAI API.
 * @Primary — used when multiple LlmProvider beans are present.
 * Falls back to realistic mock responses when no valid API key is configured.
 */
@Service
@Primary
@Slf4j
public class OpenAiProvider implements LlmProvider {

    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

    @Value("${ai.openai.api-key:your-openai-api-key}")
    private String apiKey;

    @Value("${ai.openai.model:gpt-4}")
    private String model;

    @Value("${ai.openai.api-url:https://api.openai.com/v1/chat/completions}")
    private String apiUrl;

    private final ObjectMapper objectMapper;
    private final OkHttpClient httpClient;

    public OpenAiProvider(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.httpClient = new OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(60, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .build();
    }

    /** Returns true when no real API key has been configured. */
    private boolean isMockMode() {
        return apiKey == null
                || apiKey.isBlank()
                || apiKey.equals("your-openai-api-key")
                || apiKey.startsWith("YOUR_")
                || apiKey.startsWith("sk-your")
                || apiKey.equals("PLACEHOLDER");
    }

    /** Generates a realistic mock response based on the prompt content. */
    private String mockResponse(String systemPrompt, String userPrompt) {
        String combined = (systemPrompt + " " + userPrompt).toLowerCase();

        // Check most specific signals FIRST to avoid false positives
        if (combined.contains("generate") && (combined.contains("interview question") || combined.contains("question set") || combined.contains("question count") || combined.contains("questioncount"))) {
            return "## Interview Question Set\n\n" +
                   "### Technical Questions\n" +
                   "**Q1.** Explain the core difference between `ArrayList` and `LinkedList` in Java. When would you prefer one over the other?\n" +
                   "_Expected: O(1) access vs O(n) access, cache locality, insertion/deletion tradeoffs_\n\n" +
                   "**Q2.** How does Spring Boot auto-configuration work? Walk me through what happens at startup.\n" +
                   "_Expected: @EnableAutoConfiguration, spring.factories, conditional annotations_\n\n" +
                   "**Q3.** Describe the CAP theorem and how it applies to a distributed database design.\n" +
                   "_Expected: Consistency, Availability, Partition Tolerance — choose 2_\n\n" +
                   "**Q4.** What is a database index and how does it improve query performance? What are the tradeoffs?\n" +
                   "_Expected: B-tree structure, faster reads, slower writes, storage overhead_\n\n" +
                   "**Q5.** How would you implement rate limiting in a REST API? Name at least two strategies.\n" +
                   "_Expected: Token bucket, leaky bucket, Redis sliding window, API Gateway throttling_\n\n" +
                   "### System Design Question\n" +
                   "**Q6.** Design a scalable URL shortener (like bit.ly). What components would you include?\n" +
                   "_Key points: Hash function, DB schema, caching layer, redirect service, analytics_\n\n" +
                   "### Behavioral Questions\n" +
                   "**Q7.** Tell me about a time you had to deal with a difficult team member. How did you handle it?\n" +
                   "**Q8.** Describe a project where you made a technical decision you later regretted. What did you learn?\n\n" +
                   "_[Demo mode — configure ai.openai.api-key for live personalized questions]_";
        }

        if (combined.contains("evaluate") && (combined.contains("interview") || combined.contains("answer") || combined.contains("transcript"))) {
            return "## Interview Evaluation Report\n\n" +
                   "**Overall Score: 78/100**\n\n" +
                   "### Category Breakdown\n" +
                   "- Technical Knowledge: 80/100\n" +
                   "- Problem-Solving: 75/100\n" +
                   "- Communication: 82/100\n" +
                   "- Culture Fit: 79/100\n\n" +
                   "### Strengths Observed\n" +
                   "- Clear articulation of technical concepts\n" +
                   "- Good understanding of system design fundamentals\n\n" +
                   "### Areas for Improvement\n" +
                   "- Could elaborate more on edge cases\n" +
                   "- Needs stronger depth in distributed systems\n\n" +
                   "### Recommendation\n" +
                   "**Proceed to final round** — candidate shows strong potential.\n\n" +
                   "_[Demo mode — configure ai.openai.api-key for live evaluation]_";
        }

        if (combined.contains("job description") || combined.contains("write job") || (combined.contains("jd") && combined.contains("generat"))) {
            return "## Job Description\n\n" +
                   "**Senior Software Engineer — Java / Microservices**\n\n" +
                   "We are looking for an experienced Senior Software Engineer to join our growing engineering team. " +
                   "You will design and build scalable, cloud-native microservices that power our AI-driven recruitment platform.\n\n" +
                   "### Responsibilities\n" +
                   "- Architect and implement high-throughput RESTful and event-driven microservices\n" +
                   "- Collaborate with product, data-science, and DevOps teams\n" +
                   "- Drive code quality through reviews, TDD, and CI/CD best practices\n" +
                   "- Mentor junior engineers and contribute to technical roadmap\n\n" +
                   "### Requirements\n" +
                   "- 5+ years of backend development experience (Java / Spring Boot preferred)\n" +
                   "- Strong knowledge of distributed systems, Kafka, Redis, and SQL\n" +
                   "- Experience with Docker, Kubernetes, and cloud platforms (AWS/GCP)\n\n" +
                   "### What We Offer\n" +
                   "Competitive salary · Remote-friendly · Health benefits · Learning budget\n\n" +
                   "_[Demo mode — configure ai.openai.api-key for live AI generation]_";
        }

        if (combined.contains("email") || combined.contains("outreach") || combined.contains("rejection")) {
            return "## Candidate Outreach Email\n\n" +
                   "**Subject:** Exciting Opportunity — Senior Java Engineer at AgentHire AI\n\n" +
                   "Hi [Candidate Name],\n\n" +
                   "I came across your profile and was impressed by your background in Java and microservices architecture. " +
                   "Your experience aligns perfectly with an exciting Senior Engineer role we are hiring for at AgentHire AI.\n\n" +
                   "We are building the next generation of AI-powered recruitment tooling, and we would love to have someone " +
                   "with your expertise on the team.\n\n" +
                   "Would you be open to a quick 20-minute chat this week?\n\n" +
                   "Best regards,\n" +
                   "[Recruiter Name]\n" +
                   "Talent Acquisition · AgentHire AI\n\n" +
                   "_[Demo mode — configure ai.openai.api-key for live AI generation]_";
        }

        if (combined.contains("match") || combined.contains("fit score") || combined.contains("compatibility")) {
            return "## Job Match Analysis\n\n" +
                   "**Compatibility Score: 84%**\n\n" +
                   "### Match Breakdown\n" +
                   "- Technical Skills Match: 88%\n" +
                   "- Experience Level Match: 80%\n" +
                   "- Culture Fit: 85%\n\n" +
                   "### Matched Skills\n" +
                   "`Java` `Spring Boot` `Kafka` `Docker` `REST APIs`\n\n" +
                   "### Missing Skills\n" +
                   "- Kubernetes (Nice to have)\n" +
                   "- Cloud certification (AWS/GCP)\n\n" +
                   "### Recommendation\n" +
                   "**Strong Match** — proceed with technical screening round.\n\n" +
                   "_[Demo mode — configure ai.openai.api-key for live matching]_";
        }

        if (combined.contains("hiring") && combined.contains("recommend")) {
            return "## Hiring Recommendation\n\n" +
                   "**Decision: STRONG HIRE**\n\n" +
                   "### Summary\n" +
                   "Based on all evaluation stages, this candidate demonstrates strong technical aptitude, " +
                   "good cultural alignment, and the experience needed for this role.\n\n" +
                   "### Scores Summary\n" +
                   "- Resume Score: 87/100\n" +
                   "- Job Match: 84%\n" +
                   "- Interview Score: 78/100\n" +
                   "- Overall: 83/100\n\n" +
                   "### Next Steps\n" +
                   "1. Prepare offer letter\n" +
                   "2. Reference check (2 contacts)\n" +
                   "3. Background verification\n\n" +
                   "_[Demo mode — configure ai.openai.api-key for live recommendations]_";
        }

        // Default: Resume analysis (most general case)
        return "## Resume Analysis Report\n\n" +
               "**Overall Score: 87/100**\n\n" +
               "### Strengths Identified\n" +
               "- Strong technical background in Java / Spring Boot ecosystem\n" +
               "- Solid hands-on experience with cloud-native & microservices architecture\n" +
               "- Proficiency in containerisation: Docker, Kubernetes, Docker Compose\n" +
               "- Experience with event-driven systems: Apache Kafka, Redis\n\n" +
               "### Key Skills Extracted\n" +
               "`Java` `Spring Boot` `Spring Cloud` `Kafka` `Redis` `MySQL` `Docker` `Kubernetes` `Microservices`\n\n" +
               "### Gap Analysis\n" +
               "- Consider adding cloud certifications (AWS/GCP/Azure)\n" +
               "- Leadership experience could be highlighted further\n\n" +
               "### Recommendation\n" +
               "**Strong candidate** — well-suited for senior backend or solutions-architect roles. " +
               "Recommend proceeding to technical screening.\n\n" +
               "_[Demo mode — configure ai.openai.api-key for live AI analysis]_";
    }

    @Override
    public String chat(String systemPrompt, String userPrompt) {
        return chat(systemPrompt, userPrompt, 0.7);
    }

    @Override
    public String chat(String systemPrompt, String userPrompt, double temperature) {
        if (isMockMode()) {
            log.warn("OpenAI API key not configured - returning mock response. Set ai.openai.api-key to enable live AI.");
            return mockResponse(systemPrompt, userPrompt);
        }

        try {
            ObjectNode requestBody = objectMapper.createObjectNode();
            requestBody.put("model", model);
            requestBody.put("temperature", temperature);
            requestBody.put("max_tokens", 4096);

            ArrayNode messages = requestBody.putArray("messages");

            ObjectNode systemMsg = messages.addObject();
            systemMsg.put("role", "system");
            systemMsg.put("content", systemPrompt);

            ObjectNode userMsg = messages.addObject();
            userMsg.put("role", "user");
            userMsg.put("content", userPrompt);

            String json = objectMapper.writeValueAsString(requestBody);

            Request request = new Request.Builder()
                    .url(apiUrl)
                    .post(RequestBody.create(json, JSON))
                    .addHeader("Authorization", "Bearer " + apiKey)
                    .addHeader("Content-Type", "application/json")
                    .build();

            try (Response response = httpClient.newCall(request).execute()) {
                if (!response.isSuccessful()) {
                    String errorBody = response.body() != null ? response.body().string() : "No body";
                    log.error("OpenAI API error {}: {}", response.code(), errorBody);
                    throw new RuntimeException("OpenAI API error: " + response.code() + " - " + errorBody);
                }

                String responseBody = response.body().string();
                JsonNode responseJson = objectMapper.readTree(responseBody);
                return responseJson
                        .path("choices")
                        .path(0)
                        .path("message")
                        .path("content")
                        .asText();
            }
        } catch (IOException e) {
            log.error("Failed to call OpenAI API: {}", e.getMessage());
            throw new RuntimeException("Failed to call OpenAI API: " + e.getMessage(), e);
        }
    }

    @Override
    public String getProviderName() {
        return "OpenAI";
    }
}
