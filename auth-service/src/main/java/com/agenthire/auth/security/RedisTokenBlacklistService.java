package com.agenthire.auth.security;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class RedisTokenBlacklistService {

    private static final String BLACKLIST_PREFIX = "blacklist:token:";
    private final StringRedisTemplate redisTemplate;

    public void blacklistToken(String token, long ttlMs) {
        try {
            String key = BLACKLIST_PREFIX + token;
            redisTemplate.opsForValue().set(key, "blacklisted", ttlMs, TimeUnit.MILLISECONDS);
            log.debug("Token blacklisted successfully");
        } catch (Exception e) {
            log.error("Failed to blacklist token in Redis: {}", e.getMessage());
        }
    }

    public boolean isBlacklisted(String token) {
        try {
            String key = BLACKLIST_PREFIX + token;
            return Boolean.TRUE.equals(redisTemplate.hasKey(key));
        } catch (Exception e) {
            log.error("Failed to check token blacklist in Redis: {}", e.getMessage());
            return false; // Fail open to avoid blocking legitimate requests on Redis failure
        }
    }
}
