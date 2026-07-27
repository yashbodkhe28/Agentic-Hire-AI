package com.agenthire.agent.dto;

import com.agenthire.agent.agent.AgentType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentRequest {
    private AgentType agentType;
    private Map<String, Object> payload;
    private String referenceType;
    private Long referenceId;
}
