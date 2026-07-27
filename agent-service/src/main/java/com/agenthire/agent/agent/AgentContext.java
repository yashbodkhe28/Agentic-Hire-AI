package com.agenthire.agent.agent;

import com.agenthire.agent.dto.AgentRequest;
import com.agenthire.agent.entity.AgentReport;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

/**
 * AgentContext — Context class for Strategy Pattern.
 * Delegates execution to the appropriate Agent strategy via AgentFactory.
 */
@Service("agentExecutionContext")
@RequiredArgsConstructor
@Slf4j
public class AgentContext {

    private final AgentFactory agentFactory;

    public AgentReport executeAgent(AgentType type, AgentRequest request) {
        log.info("Executing agent: {} for reference: {}/{}", type, request.getReferenceType(), request.getReferenceId());
        Agent agent = agentFactory.getAgent(type);
        long start = System.currentTimeMillis();
        AgentReport report = agent.execute(request);
        log.info("Agent {} completed in {}ms", type, System.currentTimeMillis() - start);
        return report;
    }

    public CompletableFuture<AgentReport> executeAgentAsync(AgentType type, AgentRequest request) {
        return CompletableFuture.supplyAsync(() -> executeAgent(type, request));
    }
}
