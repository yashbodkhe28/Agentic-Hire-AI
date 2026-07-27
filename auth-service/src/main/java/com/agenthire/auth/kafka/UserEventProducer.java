package com.agenthire.auth.kafka;

import com.agenthire.auth.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Component
@RequiredArgsConstructor
@Slf4j
public class UserEventProducer {

    private static final String TOPIC = "user-events";
    private final KafkaTemplate<String, Object> kafkaTemplate;

    public void publishUserRegistered(User user) {
        publishEvent("USER_REGISTERED", user);
    }

    public void publishUserLoggedIn(User user) {
        publishEvent("USER_LOGGED_IN", user);
    }

    public void publishUserLoggedOut(User user) {
        publishEvent("USER_LOGGED_OUT", user);
    }

    private void publishEvent(String eventType, User user) {
        Map<String, Object> event = Map.of(
                "eventType", eventType,
                "userId", user.getId(),
                "email", user.getEmail(),
                "role", user.getRole().getName().name(),
                "firstName", user.getFirstName(),
                "lastName", user.getLastName(),
                "timestamp", LocalDateTime.now().toString()
        );

        CompletableFuture<SendResult<String, Object>> future =
                kafkaTemplate.send(TOPIC, String.valueOf(user.getId()), event);

        future.whenComplete((result, ex) -> {
            if (ex != null) {
                log.error("Failed to publish {} event for user {}: {}", eventType, user.getId(), ex.getMessage());
            } else {
                log.debug("Published {} event for user {} to partition {}",
                        eventType, user.getId(), result.getRecordMetadata().partition());
            }
        });
    }
}
