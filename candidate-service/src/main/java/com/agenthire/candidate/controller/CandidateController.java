package com.agenthire.candidate.controller;

import com.agenthire.candidate.entity.*;
import com.agenthire.candidate.service.CandidateService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/candidates")
@RequiredArgsConstructor
public class CandidateController {

    private final CandidateService candidateService;

    @Value("${file.upload-dir:./uploads/resumes}")
    private String uploadDir;

    // ---- Candidate Profile ----
    @GetMapping("/{id}")
    public ResponseEntity<Candidate> getById(@PathVariable Long id) {
        return ResponseEntity.ok(candidateService.getCandidateById(id));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Candidate> getByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(candidateService.getCandidateByUserId(userId));
    }

    @PostMapping("/user/{userId}")
    public ResponseEntity<Candidate> create(@PathVariable Long userId, @RequestBody Map<String, Object> data) {
        return ResponseEntity.status(201).body(candidateService.createCandidate(userId, data));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Candidate> update(@PathVariable Long id, @RequestBody Map<String, Object> data) {
        return ResponseEntity.ok(candidateService.updateCandidate(id, data));
    }

    // ---- Skills ----
    @GetMapping("/{candidateId}/skills")
    public ResponseEntity<List<CandidateSkill>> getSkills(@PathVariable Long candidateId) {
        return ResponseEntity.ok(candidateService.getSkills(candidateId));
    }

    @PostMapping("/{candidateId}/skills")
    public ResponseEntity<CandidateSkill> addSkill(@PathVariable Long candidateId, @RequestBody Map<String, Object> data) {
        return ResponseEntity.status(201).body(candidateService.addSkill(candidateId, data));
    }

    @DeleteMapping("/{candidateId}/skills/{skillId}")
    public ResponseEntity<Void> deleteSkill(@PathVariable Long candidateId, @PathVariable Long skillId) {
        candidateService.deleteSkill(candidateId, skillId);
        return ResponseEntity.noContent().build();
    }

    // ---- Certifications ----
    @GetMapping("/{candidateId}/certifications")
    public ResponseEntity<List<CandidateCertification>> getCertifications(@PathVariable Long candidateId) {
        return ResponseEntity.ok(candidateService.getCertifications(candidateId));
    }

    @PostMapping("/{candidateId}/certifications")
    public ResponseEntity<CandidateCertification> addCertification(
            @PathVariable Long candidateId, @RequestBody Map<String, Object> data) {
        return ResponseEntity.status(201).body(candidateService.addCertification(candidateId, data));
    }

    @DeleteMapping("/{candidateId}/certifications/{certId}")
    public ResponseEntity<Void> deleteCertification(@PathVariable Long candidateId, @PathVariable Long certId) {
        candidateService.deleteCertification(candidateId, certId);
        return ResponseEntity.noContent().build();
    }

    // ---- Resumes ----
    @PostMapping("/{candidateId}/resumes/upload")
    public ResponseEntity<Resume> uploadResume(
            @PathVariable Long candidateId,
            @RequestParam("file") MultipartFile file) throws IOException {
        return ResponseEntity.status(201).body(candidateService.uploadResume(candidateId, file, uploadDir));
    }

    @GetMapping("/{candidateId}/resumes")
    public ResponseEntity<List<Resume>> getResumes(@PathVariable Long candidateId) {
        return ResponseEntity.ok(candidateService.getResumes(candidateId));
    }

    @PutMapping("/{candidateId}/resumes/{resumeId}/primary")
    public ResponseEntity<Void> setPrimary(@PathVariable Long candidateId, @PathVariable Long resumeId) {
        candidateService.setPrimaryResume(candidateId, resumeId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{candidateId}/resumes/{resumeId}")
    public ResponseEntity<Void> deleteResume(@PathVariable Long candidateId, @PathVariable Long resumeId) {
        candidateService.deleteResume(candidateId, resumeId);
        return ResponseEntity.noContent().build();
    }
}
