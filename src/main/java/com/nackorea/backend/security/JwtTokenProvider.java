package com.nackorea.backend.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Slf4j
@Component
public class JwtTokenProvider {

    private final SecretKey secretKey;
    private final long expiration;

    public JwtTokenProvider(@Value("${jwt.secret}") String secret,
                            @Value("${jwt.expiration}") long expiration) {
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expiration = expiration;
    }

    public String generateToken(String email) {
        Date now = new Date();
        return Jwts.builder()
                .subject(email)
                .issuedAt(now)
                .expiration(new Date(now.getTime() + expiration))
                .signWith(secretKey)
                .compact();
    }

    public String getEmailFromToken(String token) {
        return Jwts.parser().verifyWith(secretKey).build()
                .parseSignedClaims(token).getPayload().getSubject();
    }

//    public boolean validateToken(String token) {
//        try {
//            Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token);
//            return true;
//        } catch (JwtException | IllegalArgumentException e) {
//            log.warn("Invalid JWT: {}", e.getMessage());
//            return false;
//        }
//    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token);
            return true;
        } catch (ExpiredJwtException e) {
            log.warn("만료된 JWT: {}", e.getMessage());
            throw e; // Filter에서 catch할 수 있도록 예외를 그대로 던짐
        } catch (JwtException | IllegalArgumentException e) {
            log.warn("유효하지 않은 JWT: {}", e.getMessage());
            return false;
        }
    }
}
