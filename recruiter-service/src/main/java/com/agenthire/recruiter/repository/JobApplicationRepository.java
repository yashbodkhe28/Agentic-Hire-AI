package com.agenthire.recruiter.repository;

import com.agenthire.recruiter.entity.JobApplication;
import com.agenthire.recruiter.entity.ApplicationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface JobApplicationRepository extends JpaRepository<JobApplication, Long> {
    List<JobApplication> findByJobId(Long jobId);
    List<JobApplication> findByCandidateId(Long candidateId);
    Optional<JobApplication> findByCandidateIdAndJobId(Long candidateId, Long jobId);
    List<JobApplication> findByJobIdAndStatus(Long jobId, ApplicationStatus status);
    List<JobApplication> findByStatus(ApplicationStatus status);
    List<JobApplication> findByStatusIn(List<ApplicationStatus> statuses);
    long countByJobId(Long jobId);
    long countByStatus(ApplicationStatus status);

    /** Returns rows of [date_string, count] for the last :days days */
    @Query(value = "SELECT DATE_FORMAT(applied_at, '%Y-%m-%d') as d, COUNT(*) as c " +
                   "FROM job_applications " +
                   "WHERE applied_at >= DATE_SUB(NOW(), INTERVAL :days DAY) " +
                   "GROUP BY d ORDER BY d", nativeQuery = true)
    List<Object[]> countByDateLastNDays(@Param("days") int days);

    /** Status breakdown for funnel chart */
    @Query(value = "SELECT status, COUNT(*) FROM job_applications GROUP BY status", nativeQuery = true)
    List<Object[]> countGroupedByStatus();
}
