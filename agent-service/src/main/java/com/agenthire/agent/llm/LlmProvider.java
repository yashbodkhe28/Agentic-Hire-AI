package com.agenthire.agent.llm;

public interface LlmProvider {
    String chat(String systemPrompt, String userPrompt);
    String chat(String systemPrompt, String userPrompt, double temperature);
    String getProviderName();
}
