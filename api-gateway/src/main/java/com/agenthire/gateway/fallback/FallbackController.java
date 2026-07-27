package com.agenthire.gateway.fallback;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @RequestMapping("/auth")
    public Mono<ResponseEntity<Map<String, Object>>> authFallback() {
        return buildFallback("auth-service", "Authentication service is temporarily unavailable");
    }

    @RequestMapping("/candidate")
    public Mono<ResponseEntity<Map<String, Object>>> candidateFallback() {
        return buildFallback("candidate-service", "Candidate service is temporarily unavailable");
    }

    @RequestMapping("/recruiter")
    public Mono<ResponseEntity<Map<String, Object>>> recruiterFallback() {
        return buildFallback("recruiter-service", "Recruiter service is temporarily unavailable");
    }

    @RequestMapping("/interview")
    public Mono<ResponseEntity<Map<String, Object>>> interviewFallback() {
        return buildFallback("interview-service", "Interview service is temporarily unavailable");
    }

    @RequestMapping("/agent")
    public Mono<ResponseEntity<Map<String, Object>>> agentFallback() {
        return buildFallback("agent-service", "AI Agent service is temporarily unavailable");
    }

    @RequestMapping("/notification")
    public Mono<ResponseEntity<Map<String, Object>>> notificationFallback() {
        return buildFallback("notification-service", "Notification service is temporarily unavailable");
    }

    @RequestMapping("/analytics")
    public Mono<ResponseEntity<Map<String, Object>>> analyticsFallback() {
        return buildFallback("analytics-service", "Analytics service is temporarily unavailable");
    }

    private Mono<ResponseEntity<Map<String, Object>>> buildFallback(String service, String message) {
        return Mono.just(ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(Map.of(
                        "success", false,
                        "message", message,
                        "service", service,
                        "timestamp", LocalDateTime.now().toString(),
                        "status", 503
                )));
    }
}
