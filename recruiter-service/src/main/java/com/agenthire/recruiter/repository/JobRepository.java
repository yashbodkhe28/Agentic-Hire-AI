package com.agenthire.recruiter.repository;

import com.agenthire.recruiter.entity.Job;
import com.agenthire.recruiter.entity.JobStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface JobRepository extends JpaRepository<Job, Long> {
    List<Job> findByRecruiterId(Long recruiterId);
    List<Job> findByCompanyId(Long companyId);
    List<Job> findByStatus(JobStatus status);

    @Query("SELECT j FROM Job j WHERE " +
           "(:title IS NULL OR LOWER(j.title) LIKE LOWER(CONCAT('%', :title, '%'))) AND " +
           "(:location IS NULL OR LOWER(j.location) LIKE LOWER(CONCAT('%', :location, '%'))) AND " +
           "(:status IS NULL OR j.status = :status) AND " +
           "(:isRemote IS NULL OR j.isRemote = :isRemote)")
    Page<Job> searchJobs(@Param("title") String title,
                         @Param("location") String location,
                         @Param("status") JobStatus status,
                         @Param("isRemote") Boolean isRemote,
                         Pageable pageable);
}
