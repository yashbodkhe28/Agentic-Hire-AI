package com.agenthire.agent.agent;

import com.agenthire.agent.dto.AgentRequest;
import com.agenthire.agent.entity.AgentReport;

public interface Agent {
    AgentType getType();
    String getName();
    String getDescription();
    AgentReport execute(AgentRequest request);
}
