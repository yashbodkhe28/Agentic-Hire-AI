package com.agenthire.agent.framework;

import com.agenthire.agent.dto.AgentRequest;
import com.agenthire.agent.entity.AgentReport;
import com.agenthire.agent.enums.AgentType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import java.util.concurrent.CompletableFuture;

/**
 * Context class for the Strategy pattern.
 * Delegates execution to the appropriate Agent resolved via AgentFactory.
 * Supports both synchronous and asynchronous execution modes.
 */
@Component("frameworkAgentContext")
@RequiredArgsConstructor
@Slf4j
public class AgentContext {

    private final AgentFactory agentFactory;

    /**
     * Executes an agent synchronously.
     *
     * @param type    the type of agent to execute
     * @param request the request payload
     * @return the generated agent report
     */
    public AgentReport executeAgent(AgentType type, AgentRequest request) {
        log.info("Executing agent [{}] for reference {}/{}",
                type, request.getReferenceType(), request.getReferenceId());

        Agent agent = agentFactory.getAgent(type);
        long startTime = System.currentTimeMillis();

        try {
            AgentReport report = agent.execute(request);
            long elapsed = System.currentTimeMillis() - startTime;
            log.info("Agent [{}] completed in {}ms with score: {}",
                    type, elapsed, report.getScore());
            return report;
        } catch (Exception e) {
            long elapsed = System.currentTimeMillis() - startTime;
            log.error("Agent [{}] failed after {}ms: {}", type, elapsed, e.getMessage(), e);
            throw e;
        }
    }

    /**
     * Executes an agent asynchronously.
     *
     * @param type    the type of agent to execute
     * @param request the request payload
     * @return a CompletableFuture wrapping the generated agent report
     */
    @Async
    public CompletableFuture<AgentReport> executeAgentAsync(AgentType type, AgentRequest request) {
        log.info("Async execution started for agent [{}]", type);
        try {
            AgentReport report = executeAgent(type, request);
            return CompletableFuture.completedFuture(report);
        } catch (Exception e) {
            CompletableFuture<AgentReport> future = new CompletableFuture<>();
            future.completeExceptionally(e);
            return future;
        }
    }
}

