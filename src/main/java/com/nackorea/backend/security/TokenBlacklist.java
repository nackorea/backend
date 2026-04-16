package com.nackorea.backend.security;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.concurrent.ConcurrentHashMap;

@Component
@RequiredArgsConstructor
public class TokenBlacklist {

    private final ConcurrentHashMap<String, Long> blacklist = new ConcurrentHashMap<>();
    private final JwtTokenProvider jwtTokenProvider;

    public void add(String token) {
        long expiryMs = jwtTokenProvider.getExpiration(token).getTime();
        blacklist.put(token, expiryMs);
        evictExpired();
    }

    public boolean isBlacklisted(String token) {
        Long expiry = blacklist.get(token);
        if (expiry == null) return false;
        if (System.currentTimeMillis() > expiry) {
            blacklist.remove(token);
            return false;
        }
        return true;
    }

    private void evictExpired() {
        long now = System.currentTimeMillis();
        blacklist.entrySet().removeIf(e -> e.getValue() < now);
    }
}
