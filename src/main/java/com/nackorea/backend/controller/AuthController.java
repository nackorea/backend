package com.nackorea.backend.controller;

import com.nackorea.backend.dto.*;
import com.nackorea.backend.security.JwtTokenProvider;
import com.nackorea.backend.security.TokenBlacklist;
import com.nackorea.backend.service.MemberService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:5173", allowCredentials = "true")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final MemberService memberService;
    private final TokenBlacklist tokenBlacklist;

    @PostMapping("/register")
    public ResponseEntity<MemberResponseDto> register(@Valid @RequestBody MemberRequestDto dto) {
        return ResponseEntity.ok(memberService.register(dto));
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@Valid @RequestBody LoginRequestDto dto) {
        Authentication auth = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(dto.getEmail(), dto.getPassword()));
        String token = jwtTokenProvider.generateToken(auth.getName());
        MemberResponseDto member = memberService.getMemberByEmail(auth.getName());
        log.info( "이름 :  " + member.getName());
        log.info( "이메일 :  " + member.getEmail());
        log.info( "권한 :  " + member.getRole());
        log.info( "token :  " + token);
        return ResponseEntity.ok(new LoginResponseDto("Bearer", token, member));
    }

    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> logout(HttpServletRequest request) {
        String token = resolveToken(request);
        log.info("logout~~~");
        if (token != null && jwtTokenProvider.validateToken(token)) {
            tokenBlacklist.add(token);
        }
        return ResponseEntity.ok(Map.of("message", "로그아웃 되었습니다."));
    }

    private String resolveToken(HttpServletRequest request) {
        String bearer = request.getHeader("Authorization");
        return (bearer != null && bearer.startsWith("Bearer "))
                ? bearer.substring(7) : null;
    }
}
