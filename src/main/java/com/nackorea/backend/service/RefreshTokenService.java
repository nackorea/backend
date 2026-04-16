package com.nackorea.backend.service;

import com.nackorea.backend.entity.RefreshToken;
import com.nackorea.backend.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class RefreshTokenService {

    private final RefreshTokenRepository refreshTokenRepository;

    @Value("${jwt.refresh-expiration}")
    private long refreshExpiration;

    public record RotateResult(String email, String newToken) {}

    public String create(String email) {
        refreshTokenRepository.deleteByEmail(email);
        String token = UUID.randomUUID().toString();
        LocalDateTime expiresAt = LocalDateTime.now().plus(Duration.ofMillis(refreshExpiration));
        refreshTokenRepository.save(RefreshToken.builder()
                .token(token)
                .email(email)
                .expiresAt(expiresAt)
                .build());
        return token;
    }

    public RotateResult rotate(String oldToken) {
        RefreshToken stored = refreshTokenRepository.findByToken(oldToken)
                .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 Refresh Token입니다."));

        if (stored.getExpiresAt().isBefore(LocalDateTime.now())) {
            refreshTokenRepository.delete(stored);
            throw new IllegalArgumentException("만료된 Refresh Token입니다. 다시 로그인해주세요.");
        }

        String email = stored.getEmail();
        refreshTokenRepository.delete(stored);
        return new RotateResult(email, create(email));
    }

    public void deleteByEmail(String email) {
        refreshTokenRepository.deleteByEmail(email);
    }
}
