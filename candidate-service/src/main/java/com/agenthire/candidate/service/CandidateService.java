package com.agenthire.candidate.service;

import com.agenthire.candidate.entity.*;
import com.agenthire.candidate.exception.ResourceNotFoundException;
import com.agenthire.candidate.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class CandidateService {

    private final CandidateRepository candidateRepository;
    private final CandidateSkillRepository skillRepository;
    private final CandidateCertificationRepository certificationRepository;
    private final ResumeRepository resumeRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    // =========== CANDIDATE CRUD ===========

    @Cacheable(value = "candidates", key = "#id")
    @Transactional(readOnly = true)
    public Candidate getCandidateById(Long id) {
        return candidateRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Candidate not found: " + id));
    }

    @Transactional(readOnly = true)
    public Candidate getCandidateByUserId(Long userId) {
        return candidateRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Candidate profile not found for userId: " + userId));
    }

    public Candidate createCandidate(Long userId, Map<String, Object> data) {
        if (candidateRepository.existsByUserId(userId)) {
            throw new IllegalStateException("Candidate profile already exists for userId: " + userId);
        }
        Candidate candidate = Candidate.builder()
                .userId(userId)
                .headline((String) data.get("headline"))
                .summary((String) data.get("summary"))
                .location((String) data.get("location"))
                .linkedinUrl((String) data.get("linkedinUrl"))
                .githubUrl((String) data.get("githubUrl"))
                .portfolioUrl((String) data.get("portfolioUrl"))
                .build();
        if (data.get("experienceYears") != null)
            candidate.setExperienceYears(new BigDecimal(data.get("experienceYears").toString()));
        if (data.get("expectedSalary") != null)
            candidate.setExpectedSalary(new BigDecimal(data.get("expectedSalary").toString()));
        Candidate saved = candidateRepository.save(candidate);
        publishEvent("candidate-events", "CANDIDATE_CREATED", saved.getId(), userId);
        return saved;
    }

    @CacheEvict(value = "candidates", key = "#id")
    public Candidate updateCandidate(Long id, Map<String, Object> data) {
        Candidate candidate = getCandidateById(id);
        if (data.get("headline") != null) candidate.setHeadline((String) data.get("headline"));
        if (data.get("summary") != null) candidate.setSummary((String) data.get("summary"));
        if (data.get("location") != null) candidate.setLocation((String) data.get("location"));
        if (data.get("linkedinUrl") != null) candidate.setLinkedinUrl((String) data.get("linkedinUrl"));
        if (data.get("githubUrl") != null) candidate.setGithubUrl((String) data.get("githubUrl"));
        if (data.get("currentCompany") != null) candidate.setCurrentCompany((String) data.get("currentCompany"));
        if (data.get("currentRole") != null) candidate.setCurrentRole((String) data.get("currentRole"));
        if (data.get("experienceYears") != null)
            candidate.setExperienceYears(new BigDecimal(data.get("experienceYears").toString()));
        if (data.get("expectedSalary") != null)
            candidate.setExpectedSalary(new BigDecimal(data.get("expectedSalary").toString()));
        return candidateRepository.save(candidate);
    }

    // =========== SKILLS ===========

    public CandidateSkill addSkill(Long candidateId, Map<String, Object> data) {
        Candidate candidate = getCandidateById(candidateId);
        CandidateSkill skill = CandidateSkill.builder()
                .candidate(candidate)
                .skillName((String) data.get("skillName"))
                .proficiencyLevel(ProficiencyLevel.valueOf(
                        data.getOrDefault("proficiencyLevel", "INTERMEDIATE").toString().toUpperCase()))
                .build();
        if (data.get("yearsOfExperience") != null)
            skill.setYearsOfExperience(new BigDecimal(data.get("yearsOfExperience").toString()));
        return skillRepository.save(skill);
    }

    public List<CandidateSkill> getSkills(Long candidateId) {
        return skillRepository.findByCandidateId(candidateId);
    }

    public void deleteSkill(Long candidateId, Long skillId) {
        skillRepository.deleteByCandidateIdAndId(candidateId, skillId);
    }

    // =========== CERTIFICATIONS ===========

    public CandidateCertification addCertification(Long candidateId, Map<String, Object> data) {
        Candidate candidate = getCandidateById(candidateId);
        CandidateCertification cert = CandidateCertification.builder()
                .candidate(candidate)
                .name((String) data.get("name"))
                .issuingOrg((String) data.get("issuingOrg"))
                .credentialUrl((String) data.get("credentialUrl"))
                .build();
        if (data.get("issueDate") != null) cert.setIssueDate(LocalDate.parse(data.get("issueDate").toString()));
        if (data.get("expiryDate") != null) cert.setExpiryDate(LocalDate.parse(data.get("expiryDate").toString()));
        return certificationRepository.save(cert);
    }

    public List<CandidateCertification> getCertifications(Long candidateId) {
        return certificationRepository.findByCandidateId(candidateId);
    }

    public void deleteCertification(Long candidateId, Long certId) {
        certificationRepository.deleteById(certId);
    }

    // =========== RESUMES ===========

    public Resume uploadResume(Long candidateId, MultipartFile file, String uploadDir) throws IOException {
        Candidate candidate = getCandidateById(candidateId);

        // Save file to disk
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) Files.createDirectories(uploadPath);

        String uniqueFileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
        Path filePath = uploadPath.resolve(uniqueFileName);
        Files.copy(file.getInputStream(), filePath);

        // First resume is primary by default
        boolean isFirst = resumeRepository.findByCandidateId(candidateId).isEmpty();

        Resume resume = Resume.builder()
                .candidate(candidate)
                .fileName(file.getOriginalFilename())
                .filePath(filePath.toString())
                .fileType(file.getContentType())
                .fileSize(file.getSize())
                .isPrimary(isFirst)
                .build();
        Resume saved = resumeRepository.save(resume);

        // Publish Kafka event for AI processing
        publishEvent("resume-events", "RESUME_UPLOADED",
                saved.getId(), candidateId);

        return saved;
    }

    public List<Resume> getResumes(Long candidateId) {
        return resumeRepository.findByCandidateId(candidateId);
    }

    public void setPrimaryResume(Long candidateId, Long resumeId) {
        // Unset all primary flags first
        resumeRepository.findByCandidateId(candidateId).forEach(r -> {
            r.setIsPrimary(false);
            resumeRepository.save(r);
        });
        // Set the selected one as primary
        Resume resume = resumeRepository.findById(resumeId)
                .orElseThrow(() -> new ResourceNotFoundException("Resume not found: " + resumeId));
        resume.setIsPrimary(true);
        resumeRepository.save(resume);
    }

    public void deleteResume(Long candidateId, Long resumeId) {
        resumeRepository.deleteByCandidateIdAndId(candidateId, resumeId);
    }

    private void publishEvent(String topic, String eventType, Long id, Long userId) {
        try {
            kafkaTemplate.send(topic, String.valueOf(id), Map.of(
                    "eventType", eventType,
                    "id", id,
                    "userId", userId,
                    "timestamp", LocalDateTime.now().toString()
            ));
        } catch (Exception e) {
            log.warn("Failed to publish Kafka event {}: {}", eventType, e.getMessage());
        }
    }
}
