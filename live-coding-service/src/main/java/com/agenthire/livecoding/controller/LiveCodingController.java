package com.agenthire.livecoding.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Real-time collaborative coding controller using WebSocket/STOMP.
 * Supports multi-user code editing for live interview coding sessions.
 */
@RestController
@Slf4j
@RequiredArgsConstructor
public class LiveCodingController {

    private final SimpMessagingTemplate messagingTemplate;

    // In-memory session storage (use Redis for production multi-node)
    private final ConcurrentHashMap<String, Map<String, Object>> codingSessions = new ConcurrentHashMap<>();

    /**
     * WebSocket: Handle real-time code changes — broadcasts to all session participants
     */
    @MessageMapping("/coding/{sessionId}/code-update")
    public void handleCodeUpdate(
            @DestinationVariable String sessionId,
            @Payload Map<String, Object> update) {

        update.put("timestamp", LocalDateTime.now().toString());
        log.debug("Code update for session: {}", sessionId);

        // Broadcast to all subscribers of this session
        messagingTemplate.convertAndSend("/topic/coding/" + sessionId + "/code", update);

        // Update session state
        codingSessions.computeIfAbsent(sessionId, k -> new ConcurrentHashMap<>())
                .put("lastCode", update.get("code"));
    }

    /**
     * WebSocket: Handle cursor position updates for collaborative editing
     */
    @MessageMapping("/coding/{sessionId}/cursor")
    public void handleCursorUpdate(
            @DestinationVariable String sessionId,
            @Payload Map<String, Object> cursorUpdate) {
        messagingTemplate.convertAndSend("/topic/coding/" + sessionId + "/cursors", cursorUpdate);
    }

    /**
     * WebSocket: Handle chat messages within coding session
     */
    @MessageMapping("/coding/{sessionId}/chat")
    public void handleChatMessage(
            @DestinationVariable String sessionId,
            @Payload Map<String, Object> message) {
        message.put("timestamp", LocalDateTime.now().toString());
        messagingTemplate.convertAndSend("/topic/coding/" + sessionId + "/chat", message);
    }

    /**
     * REST: Create a new coding session
     */
    @PostMapping("/api/coding/sessions")
    public Map<String, Object> createSession(@RequestBody Map<String, Object> data) {
        String sessionId = java.util.UUID.randomUUID().toString();
        Map<String, Object> session = new ConcurrentHashMap<>();
        session.put("sessionId", sessionId);
        session.put("language", data.getOrDefault("language", "java"));
        session.put("starterCode", data.getOrDefault("starterCode", "// Start coding here\n"));
        session.put("problem", data.getOrDefault("problem", ""));
        session.put("interviewId", data.get("interviewId"));
        session.put("createdAt", LocalDateTime.now().toString());
        session.put("status", "ACTIVE");
        codingSessions.put(sessionId, session);
        log.info("Created coding session: {}", sessionId);
        return Map.of("success", true, "session", session, "wsEndpoint", "/ws/coding");
    }

    /**
     * REST: Get session details
     */
    @GetMapping("/api/coding/sessions/{sessionId}")
    public Map<String, Object> getSession(@PathVariable String sessionId) {
        Map<String, Object> session = codingSessions.get(sessionId);
        if (session == null) return Map.of("success", false, "message", "Session not found");
        return Map.of("success", true, "session", session);
    }

    /**
     * REST: Submit code for evaluation
     */
    @PostMapping("/api/coding/sessions/{sessionId}/submit")
    public Map<String, Object> submitCode(
            @PathVariable String sessionId,
            @RequestBody Map<String, Object> submission) {

        Map<String, Object> session = codingSessions.getOrDefault(sessionId, new ConcurrentHashMap<>());
        session.put("submittedCode", submission.get("code"));
        session.put("status", "SUBMITTED");
        session.put("submittedAt", LocalDateTime.now().toString());

        // Notify all participants of submission
        messagingTemplate.convertAndSend("/topic/coding/" + sessionId + "/status",
                Map.of("event", "CODE_SUBMITTED", "sessionId", sessionId,
                       "timestamp", LocalDateTime.now().toString()));

        log.info("Code submitted for session: {}", sessionId);
        return Map.of("success", true, "message", "Code submitted successfully", "sessionId", sessionId);
    }
}
