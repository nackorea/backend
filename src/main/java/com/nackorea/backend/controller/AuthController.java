package com.nackorea.backend.controller;

import com.nackorea.backend.dto.*;
import com.nackorea.backend.security.JwtTokenProvider;
import com.nackorea.backend.security.TokenBlacklist;
import com.nackorea.backend.service.MemberService;
import com.nackorea.backend.service.RefreshTokenService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final MemberService memberService;
    private final TokenBlacklist tokenBlacklist;
    private final RefreshTokenService refreshTokenService;

    @PostMapping("/register")
    public ResponseEntity<MemberResponseDto> register(@Valid @RequestBody MemberRequestDto dto) {
        return ResponseEntity.ok(memberService.register(dto));
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@Valid @RequestBody LoginRequestDto dto) {
        Authentication auth = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(dto.getEmail(), dto.getPassword()));

        String email = auth.getName();
        String accessToken = jwtTokenProvider.generateToken(email);
        String refreshToken = refreshTokenService.create(email);
        MemberResponseDto member = memberService.getMemberByEmail(email);

        log.info("로그인 - 이름: {}, 이메일: {}, 권한: {}", member.getName(), email, member.getRole());
        return ResponseEntity.ok(new LoginResponseDto("Bearer", accessToken, refreshToken, member));
    }

    @PostMapping("/refresh")
    public ResponseEntity<Map<String, String>> refresh(@Valid @RequestBody RefreshRequestDto dto) {
        RefreshTokenService.RotateResult result = refreshTokenService.rotate(dto.getRefreshToken());
        String newAccessToken = jwtTokenProvider.generateToken(result.email());
        return ResponseEntity.ok(Map.of(
                "accessToken", newAccessToken,
                "refreshToken", result.newToken()
        ));
    }

    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> logout(HttpServletRequest request) {
        String token = jwtTokenProvider.resolveToken(request);
        log.info("로그아웃");
        if (token != null && jwtTokenProvider.validateToken(token)) {
            tokenBlacklist.add(token);
            refreshTokenService.deleteByEmail(jwtTokenProvider.getEmailFromToken(token));
        }
        return ResponseEntity.ok(Map.of("message", "로그아웃 되었습니다."));
    }
}
