package com.agenthire.interview.controller;

import com.agenthire.interview.entity.*;
import com.agenthire.interview.repository.InterviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/interviews")
@RequiredArgsConstructor
public class InterviewController {

    private final InterviewRepository interviewRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @PostMapping
    public ResponseEntity<Interview> scheduleInterview(@RequestBody Map<String, Object> data) {
        Interview interview = Interview.builder()
                .applicationId(((Number) data.get("applicationId")).longValue())
                .candidateId(((Number) data.get("candidateId")).longValue())
                .recruiterId(((Number) data.get("recruiterId")).longValue())
                .jobId(((Number) data.get("jobId")).longValue())
                .interviewType(InterviewType.valueOf(
                        data.getOrDefault("interviewType", "TECHNICAL").toString().toUpperCase()))
                .meetingLink((String) data.get("meetingLink"))
                .durationMinutes(((Number) data.getOrDefault("durationMinutes", 60)).intValue())
                .scheduledAt(LocalDateTime.parse(data.get("scheduledAt").toString()))
                .status(InterviewStatus.SCHEDULED)
                .build();

        Interview saved = interviewRepository.save(interview);

        try {
            kafkaTemplate.send("interview-events", String.valueOf(saved.getId()),
                    Map.of("eventType", "INTERVIEW_SCHEDULED", "interviewId", saved.getId(),
                           "candidateId", saved.getCandidateId(), "timestamp", LocalDateTime.now().toString()));
        } catch (Exception e) { /* non-critical */ }

        return ResponseEntity.status(201).body(saved);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Interview> getInterview(@PathVariable Long id) {
        return interviewRepository.findById(id).map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/candidate/{candidateId}")
    public ResponseEntity<List<Interview>> getByCandidateId(@PathVariable Long candidateId) {
        return ResponseEntity.ok(interviewRepository.findByCandidateId(candidateId));
    }

    @GetMapping("/recruiter/{recruiterId}")
    public ResponseEntity<List<Interview>> getByRecruiterId(@PathVariable Long recruiterId) {
        return ResponseEntity.ok(interviewRepository.findByRecruiterId(recruiterId));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Interview> updateStatus(@PathVariable Long id, @RequestBody Map<String, Object> data) {
        return interviewRepository.findById(id).map(interview -> {
            interview.setStatus(InterviewStatus.valueOf(data.get("status").toString().toUpperCase()));
            if (data.get("feedback") != null) interview.setFeedback((String) data.get("feedback"));
            if (data.get("overallScore") != null)
                interview.setOverallScore(((Number) data.get("overallScore")).intValue());
            return ResponseEntity.ok(interviewRepository.save(interview));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> cancelInterview(@PathVariable Long id) {
        interviewRepository.findById(id).ifPresent(interview -> {
            interview.setStatus(InterviewStatus.CANCELLED);
            interviewRepository.save(interview);
        });
        return ResponseEntity.noContent().build();
    }
}
