package com.agenthire.notification.kafka;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Kafka consumer that listens to all domain events and sends email notifications.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationEventConsumer {

    private final JavaMailSender mailSender;

    @KafkaListener(topics = "user-events", groupId = "notification-group")
    public void handleUserEvent(Map<String, Object> event) {
        log.info("Received user event: {}", event.get("eventType"));
        String eventType = (String) event.get("eventType");
        String email = (String) event.get("email");

        if ("USER_REGISTERED".equals(eventType) && email != null) {
            sendEmail(email,
                    "Welcome to AgentHire AI! 🎉",
                    "Hello " + event.get("firstName") + ",\n\n" +
                    "Welcome to AgentHire AI — the next-generation AI-powered recruitment platform!\n\n" +
                    "Your account has been created successfully.\n\n" +
                    "Get started:\n" +
                    "• Complete your profile\n" +
                    "• Upload your resume for AI analysis\n" +
                    "• Explore job opportunities\n\n" +
                    "Best regards,\nAgentHire AI Team");
        }
    }

    @KafkaListener(topics = "application-events", groupId = "notification-group")
    public void handleApplicationEvent(Map<String, Object> event) {
        log.info("Received application event: {}", event.get("eventType"));
        String eventType = (String) event.get("eventType");

        if ("APPLICATION_SUBMITTED".equals(eventType)) {
            log.info("Application {} submitted for job {}", event.get("applicationId"), event.get("jobId"));
            // In real scenario, fetch candidate email from Feign client and send email
        }

        if ("APPLICATION_STATUS_CHANGED".equals(eventType)) {
            String newStatus = (String) event.get("status");
            log.info("Application {} status changed to {}", event.get("applicationId"), newStatus);
        }
    }

    @KafkaListener(topics = "interview-events", groupId = "notification-group")
    public void handleInterviewEvent(Map<String, Object> event) {
        log.info("Received interview event: {}", event.get("eventType"));
        String eventType = (String) event.get("eventType");

        if ("INTERVIEW_SCHEDULED".equals(eventType)) {
            log.info("Interview {} scheduled for candidate {}", event.get("interviewId"), event.get("candidateId"));
            // In real scenario, fetch emails and send calendar invite
        }
    }

    @KafkaListener(topics = "resume-events", groupId = "notification-group")
    public void handleResumeEvent(Map<String, Object> event) {
        log.info("Received resume event: {} for candidate {}", event.get("eventType"), event.get("userId"));
    }

    private void sendEmail(String to, String subject, String body) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom("noreply@agenthire.ai");
            message.setTo(to);
            message.setSubject(subject);
            message.setText(body);
            mailSender.send(message);
            log.info("Email sent to: {}", to);
        } catch (Exception e) {
            log.error("Failed to send email to {}: {}", to, e.getMessage());
        }
    }
}
