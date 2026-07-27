package com.agenthire.agent.framework;

import com.agenthire.agent.dto.AgentRequest;
import com.agenthire.agent.entity.AgentReport;
import com.agenthire.agent.enums.AgentType;

/**
 * Strategy interface for all AI agents.
 * Each agent implementation encapsulates a specific AI capability
 * with its own LLM prompts, input processing, and output formatting.
 */
public interface Agent {

    /**
     * Returns the type identifier for this agent.
     */
    AgentType getType();

    /**
     * Executes the agent's core logic against the given request.
     *
     * @param request the agent request containing payload and context
     * @return an AgentReport with the analysis results
     */
    AgentReport execute(AgentRequest request);

    /**
     * Returns the human-readable name of this agent.
     */
    String getName();

    /**
     * Returns a description of what this agent does.
     */
    String getDescription();
}
