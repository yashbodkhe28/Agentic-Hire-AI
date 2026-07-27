package com.agenthire.candidate.repository;

import com.agenthire.candidate.entity.CandidateCertification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CandidateCertificationRepository extends JpaRepository<CandidateCertification, Long> {
    List<CandidateCertification> findByCandidateId(Long candidateId);
}
