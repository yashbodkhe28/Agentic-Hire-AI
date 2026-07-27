package com.agenthire.agent.framework;

import com.agenthire.agent.enums.AgentType;
import com.agenthire.agent.exception.AgentNotFoundException;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Factory for resolving Agent implementations by AgentType.
 * Uses Spring's dependency injection to collect all Agent beans,
 * then maps them by their AgentType for O(1) lookup.
 */
@Component("frameworkAgentFactory")
@RequiredArgsConstructor
@Slf4j
public class AgentFactory {

    private final List<Agent> agents;
    private Map<AgentType, Agent> agentMap;

    @PostConstruct
    public void init() {
        agentMap = agents.stream()
                .collect(Collectors.toMap(Agent::getType, Function.identity()));
        log.info("AgentFactory initialized with {} agents: {}",
                agentMap.size(),
                agentMap.keySet().stream().map(Enum::name).collect(Collectors.joining(", ")));
    }

    /**
     * Resolves an Agent by its type.
     *
     * @param type the agent type to look up
     * @return the corresponding Agent implementation
     * @throws AgentNotFoundException if no agent is registered for the given type
     */
    public Agent getAgent(AgentType type) {
        Agent agent = agentMap.get(type);
        if (agent == null) {
            throw new AgentNotFoundException("No agent registered for type: " + type);
        }
        return agent;
    }

    /**
     * Returns all registered agent types.
     */
    public Set<AgentType> getAvailableTypes() {
        return Collections.unmodifiableSet(agentMap.keySet());
    }

    /**
     * Returns all registered agents.
     */
    public Collection<Agent> getAllAgents() {
        return Collections.unmodifiableCollection(agentMap.values());
    }
}

