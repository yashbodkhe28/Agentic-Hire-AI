package com.agenthire.recruiter.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "job_skills")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class JobSkill {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "job_id", nullable = false)
    private Job job;

    @Column(name = "skill_name", nullable = false, length = 100)
    private String skillName;

    @Column(name = "is_required") @Builder.Default
    private Boolean isRequired = true;

    @Column(name = "min_proficiency", length = 20)
    private String minProficiency;
}
