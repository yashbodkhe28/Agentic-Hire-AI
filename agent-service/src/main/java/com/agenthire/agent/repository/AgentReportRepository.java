package com.agenthire.agent.repository;

import com.agenthire.agent.entity.AgentReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AgentReportRepository extends JpaRepository<AgentReport, Long> {
    List<AgentReport> findByReferenceTypeAndReferenceId(String referenceType, Long referenceId);
    Optional<AgentReport> findByAgentTypeAndReferenceTypeAndReferenceId(String agentType, String referenceType, Long referenceId);
    List<AgentReport> findByAgentTypeOrderByCreatedAtDesc(String agentType);
}
