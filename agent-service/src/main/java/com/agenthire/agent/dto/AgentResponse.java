package com.agenthire.agent.dto;

import com.fasterxml.jackson.annotation.JsonRawValue;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentResponse {

    private Long id;
    private String agentType;

    @JsonRawValue
    private String reportJson;

    private BigDecimal score;
    private String recommendation;
    private LocalDateTime createdAt;
}
