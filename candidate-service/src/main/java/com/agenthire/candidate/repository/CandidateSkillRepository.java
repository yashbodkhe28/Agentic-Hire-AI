package com.agenthire.candidate.repository;

import com.agenthire.candidate.entity.CandidateSkill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CandidateSkillRepository extends JpaRepository<CandidateSkill, Long> {
    List<CandidateSkill> findByCandidateId(Long candidateId);
    void deleteByCandidateIdAndId(Long candidateId, Long skillId);
}
