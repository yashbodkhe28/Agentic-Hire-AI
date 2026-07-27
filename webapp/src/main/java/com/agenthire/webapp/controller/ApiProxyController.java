package com.agenthire.webapp.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;
import org.springframework.boot.web.client.RestTemplateBuilder;

import java.time.Duration;

/**
 * Proxies all /api/** requests internally — eliminates browser CORS entirely.
 * Auth routes go directly to auth-service, everything else via api-gateway.
 */
@RestController
public class ApiProxyController {

    private final RestTemplate restTemplate;

    @Value("${gateway.url:http://api-gateway:8080}")
    private String gatewayUrl;

    @Value("${auth.service.url:http://auth-service:8081}")
    private String authServiceUrl;

    public ApiProxyController() {
        // 15s connect + 30s read timeout to prevent hanging
        this.restTemplate = new RestTemplateBuilder()
                .setConnectTimeout(Duration.ofSeconds(15))
                .setReadTimeout(Duration.ofSeconds(30))
                .build();
    }

    @RequestMapping("/api/**")
    public ResponseEntity<String> proxy(
            HttpServletRequest request,
            @RequestBody(required = false) String body) {

        String path = request.getRequestURI();
        String query = request.getQueryString();

        // Route auth directly to auth-service (skip gateway + Eureka complexity)
        String targetBase = path.startsWith("/api/auth/") ? authServiceUrl : gatewayUrl;
        String targetUrl = targetBase + path + (query != null ? "?" + query : "");

        HttpMethod method = HttpMethod.valueOf(request.getMethod());
        HttpHeaders headers = new HttpHeaders();

        String contentType = request.getHeader(HttpHeaders.CONTENT_TYPE);
        if (contentType != null) headers.setContentType(MediaType.parseMediaType(contentType));

        String auth = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (auth != null) headers.set(HttpHeaders.AUTHORIZATION, auth);

        HttpEntity<String> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<String> response = restTemplate.exchange(targetUrl, method, entity, String.class);
            HttpHeaders responseHeaders = new HttpHeaders();
            MediaType ct = response.getHeaders().getContentType();
            if (ct != null) responseHeaders.setContentType(ct);
            return new ResponseEntity<>(response.getBody(), responseHeaders, response.getStatusCode());
        } catch (HttpStatusCodeException e) {
            return ResponseEntity.status(e.getStatusCode())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(e.getResponseBodyAsString());
        } catch (ResourceAccessException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\":false,\"message\":\"Service unavailable: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\":false,\"message\":\"Proxy error: " + e.getMessage() + "\"}");
        }
    }
}
