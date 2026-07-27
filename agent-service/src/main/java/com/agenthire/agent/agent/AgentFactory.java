package com.agenthire.agent.agent;

import com.agenthire.agent.exception.AgentNotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Factory Pattern implementation for creating/retrieving Agent instances.
 * All Agent beans are auto-discovered via Spring DI and registered by type.
 */
@Component("agentStrategyFactory")
@Slf4j
public class AgentFactory {

    private final Map<AgentType, Agent> agentRegistry;

    public AgentFactory(List<Agent> agents) {
        this.agentRegistry = agents.stream()
                .collect(Collectors.toMap(Agent::getType, Function.identity()));
        log.info("AgentFactory initialized with {} agents: {}", agents.size(),
                agents.stream().map(a -> a.getType().name()).collect(Collectors.joining(", ")));
    }

    public Agent getAgent(AgentType type) {
        Agent agent = agentRegistry.get(type);
        if (agent == null) {
            throw new AgentNotFoundException("No agent registered for type: " + type);
        }
        return agent;
    }

    public List<AgentType> getAvailableAgentTypes() {
        return List.copyOf(agentRegistry.keySet());
    }

    public boolean isAgentAvailable(AgentType type) {
        return agentRegistry.containsKey(type);
    }
}

