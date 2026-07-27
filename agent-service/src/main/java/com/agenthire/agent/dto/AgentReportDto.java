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
public class AgentReportDto {

    private Long id;
    private String agentType;
    private String referenceType;
    private Long referenceId;

    @JsonRawValue
    private String reportJson;

    private BigDecimal score;
    private String recommendation;
    private LocalDateTime createdAt;
}
