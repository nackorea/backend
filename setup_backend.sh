#!/bin/bash

BASE=/Users/kb01-alexkr9173/WORK/NAC_KOREA/backend
PKG=src/main/java/com/nackorea/backend

echo "📁 디렉토리 생성 중..."
mkdir -p $BASE/{$PKG/{config,controller,dto,entity,exception,repository,security,service},src/test/java/com/nackorea/backend,src/main/resources}

cd $BASE

# ─────────────────────────────────────────────
# settings.gradle
# ─────────────────────────────────────────────
cat > settings.gradle << 'EOF'
rootProject.name = 'backend'
EOF

# ─────────────────────────────────────────────
# build.gradle
# ─────────────────────────────────────────────
cat > build.gradle << 'EOF'
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.3.5'
    id 'io.spring.dependency-management' version '1.1.6'
}

group = 'com.nackorea'
version = '0.0.1-SNAPSHOT'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

configurations {
    compileOnly { extendsFrom annotationProcessor }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    runtimeOnly 'com.mysql:mysql-connector-j'
    implementation 'io.jsonwebtoken:jjwt-api:0.12.6'
    runtimeOnly  'io.jsonwebtoken:jjwt-impl:0.12.6'
    runtimeOnly  'io.jsonwebtoken:jjwt-jackson:0.12.6'
    compileOnly  'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
}

tasks.named('test') { useJUnitPlatform() }
EOF

# ─────────────────────────────────────────────
# application.yml
# ─────────────────────────────────────────────
cat > src/main/resources/application.yml << 'EOF'
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/nac_korea?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Seoul&characterEncoding=UTF-8
    username: nac_korea
    password: nac_korea1234
    driver-class-name: com.mysql.cj.jdbc.Driver

  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQLDialect
        format_sql: true

jwt:
  secret: nac-korea-secret-key-must-be-at-least-256bits-long-for-hs256
  expiration: 86400000

logging:
  level:
    com.nackorea: DEBUG
EOF

# ─────────────────────────────────────────────
# BackendApplication.java
# ─────────────────────────────────────────────
cat > $PKG/BackendApplication.java << 'EOF'
package com.nackorea.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackendApplication {
    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }
}
EOF

# ─────────────────────────────────────────────
# entity/Member.java
# ─────────────────────────────────────────────
cat > $PKG/entity/Member.java << 'EOF'
package com.nackorea.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "members")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
@EntityListeners(AuditingEntityListener.class)
public class Member {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 100)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(length = 20)
    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Role role = Role.USER;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Status status = Status.ACTIVE;

    @CreatedDate @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    public enum Role   { USER, ADMIN }
    public enum Status { ACTIVE, WITHDRAWN }
}
EOF

# ─────────────────────────────────────────────
# repository/MemberRepository.java
# ─────────────────────────────────────────────
cat > $PKG/repository/MemberRepository.java << 'EOF'
package com.nackorea.backend.repository;

import com.nackorea.backend.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {
    Optional<Member> findByEmail(String email);
    boolean existsByEmail(String email);
}
EOF

# ─────────────────────────────────────────────
# dto/MemberRequestDto.java
# ─────────────────────────────────────────────
cat > $PKG/dto/MemberRequestDto.java << 'EOF'
package com.nackorea.backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class MemberRequestDto {

    @NotBlank(message = "이메일은 필수입니다.")
    @Email(message = "올바른 이메일 형식이 아닙니다.")
    private String email;

    @Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다.")
    private String password;

    @NotBlank(message = "이름은 필수입니다.")
    private String name;

    private String phone;
}
EOF

# ─────────────────────────────────────────────
# dto/MemberResponseDto.java
# ─────────────────────────────────────────────
cat > $PKG/dto/MemberResponseDto.java << 'EOF'
package com.nackorea.backend.dto;

import com.nackorea.backend.entity.Member;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter @Builder
public class MemberResponseDto {
    private Long id;
    private String email;
    private String name;
    private String phone;
    private String role;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static MemberResponseDto from(Member m) {
        return MemberResponseDto.builder()
                .id(m.getId())
                .email(m.getEmail())
                .name(m.getName())
                .phone(m.getPhone())
                .role(m.getRole().name())
                .status(m.getStatus().name())
                .createdAt(m.getCreatedAt())
                .updatedAt(m.getUpdatedAt())
                .build();
    }
}
EOF

# ─────────────────────────────────────────────
# dto/LoginRequestDto.java
# ─────────────────────────────────────────────
cat > $PKG/dto/LoginRequestDto.java << 'EOF'
package com.nackorea.backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class LoginRequestDto {

    @NotBlank @Email
    private String email;

    @NotBlank
    private String password;
}
EOF

# ─────────────────────────────────────────────
# dto/LoginResponseDto.java
# ─────────────────────────────────────────────
cat > $PKG/dto/LoginResponseDto.java << 'EOF'
package com.nackorea.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter @AllArgsConstructor
public class LoginResponseDto {
    private String tokenType;
    private String accessToken;
    private MemberResponseDto member;
}
EOF

# ─────────────────────────────────────────────
# security/JwtTokenProvider.java
# ─────────────────────────────────────────────
cat > $PKG/security/JwtTokenProvider.java << 'EOF'
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

    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            log.warn("Invalid JWT: {}", e.getMessage());
            return false;
        }
    }
}
EOF

# ─────────────────────────────────────────────
# security/UserDetailsServiceImpl.java
# ─────────────────────────────────────────────
cat > $PKG/security/UserDetailsServiceImpl.java << 'EOF'
package com.nackorea.backend.security;

import com.nackorea.backend.entity.Member;
import com.nackorea.backend.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Member member = memberRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("사용자 없음: " + email));
        return new User(member.getEmail(), member.getPassword(),
                List.of(new SimpleGrantedAuthority("ROLE_" + member.getRole().name())));
    }
}
EOF

# ─────────────────────────────────────────────
# security/JwtAuthenticationFilter.java
# ─────────────────────────────────────────────
cat > $PKG/security/JwtAuthenticationFilter.java << 'EOF'
package com.nackorea.backend.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserDetailsServiceImpl userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest req,
                                    HttpServletResponse res,
                                    FilterChain chain)
            throws ServletException, IOException {

        String token = resolveToken(req);
        if (StringUtils.hasText(token) && jwtTokenProvider.validateToken(token)) {
            String email = jwtTokenProvider.getEmailFromToken(token);
            UserDetails ud = userDetailsService.loadUserByUsername(email);
            var auth = new UsernamePasswordAuthenticationToken(ud, null, ud.getAuthorities());
            auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));
            SecurityContextHolder.getContext().setAuthentication(auth);
        }
        chain.doFilter(req, res);
    }

    private String resolveToken(HttpServletRequest req) {
        String bearer = req.getHeader("Authorization");
        return (StringUtils.hasText(bearer) && bearer.startsWith("Bearer "))
                ? bearer.substring(7) : null;
    }
}
EOF

# ─────────────────────────────────────────────
# config/SecurityConfig.java
# ─────────────────────────────────────────────
cat > $PKG/config/SecurityConfig.java << 'EOF'
package com.nackorea.backend.config;

import com.nackorea.backend.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.*;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.*;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableJpaAuditing
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(c -> c.configurationSource(corsConfigurationSource()))
            .csrf(c -> c.disable())
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(a -> a
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/members").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(); }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration c) throws Exception {
        return c.getAuthenticationManager();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration cfg = new CorsConfiguration();
        cfg.setAllowedOrigins(List.of("http://localhost:3000"));
        cfg.setAllowedMethods(List.of("GET","POST","PUT","DELETE","OPTIONS"));
        cfg.setAllowedHeaders(List.of("*"));
        cfg.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource src = new UrlBasedCorsConfigurationSource();
        src.registerCorsConfiguration("/**", cfg);
        return src;
    }
}
EOF

# ─────────────────────────────────────────────
# service/MemberService.java
# ─────────────────────────────────────────────
cat > $PKG/service/MemberService.java << 'EOF'
package com.nackorea.backend.service;

import com.nackorea.backend.dto.MemberRequestDto;
import com.nackorea.backend.dto.MemberResponseDto;
import com.nackorea.backend.entity.Member;
import com.nackorea.backend.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public MemberResponseDto register(MemberRequestDto dto) {
        if (memberRepository.existsByEmail(dto.getEmail()))
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        Member member = Member.builder()
                .email(dto.getEmail())
                .password(passwordEncoder.encode(dto.getPassword()))
                .name(dto.getName())
                .phone(dto.getPhone())
                .build();
        return MemberResponseDto.from(memberRepository.save(member));
    }

    public List<MemberResponseDto> getMembers() {
        return memberRepository.findAll().stream()
                .filter(m -> m.getStatus() == Member.Status.ACTIVE)
                .map(MemberResponseDto::from)
                .toList();
    }

    public MemberResponseDto getMember(Long id) {
        return MemberResponseDto.from(findActiveById(id));
    }

    public MemberResponseDto getMemberByEmail(String email) {
        Member m = memberRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
        return MemberResponseDto.from(m);
    }

    @Transactional
    public MemberResponseDto updateMember(Long id, MemberRequestDto dto) {
        Member member = findActiveById(id);
        member.setName(dto.getName());
        member.setPhone(dto.getPhone());
        if (dto.getPassword() != null && !dto.getPassword().isBlank())
            member.setPassword(passwordEncoder.encode(dto.getPassword()));
        return MemberResponseDto.from(member);
    }

    @Transactional
    public void withdraw(Long id) {
        findActiveById(id).setStatus(Member.Status.WITHDRAWN);
    }

    private Member findActiveById(Long id) {
        return memberRepository.findById(id)
                .filter(m -> m.getStatus() == Member.Status.ACTIVE)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 회원입니다."));
    }
}
EOF

# ─────────────────────────────────────────────
# controller/AuthController.java
# ─────────────────────────────────────────────
cat > $PKG/controller/AuthController.java << 'EOF'
package com.nackorea.backend.controller;

import com.nackorea.backend.dto.*;
import com.nackorea.backend.security.JwtTokenProvider;
import com.nackorea.backend.service.MemberService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final MemberService memberService;

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
        return ResponseEntity.ok(new LoginResponseDto("Bearer", token, member));
    }
}
EOF

# ─────────────────────────────────────────────
# controller/MemberController.java
# ─────────────────────────────────────────────
cat > $PKG/controller/MemberController.java << 'EOF'
package com.nackorea.backend.controller;

import com.nackorea.backend.dto.*;
import com.nackorea.backend.service.MemberService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/members")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @GetMapping
    public ResponseEntity<List<MemberResponseDto>> getMembers() {
        return ResponseEntity.ok(memberService.getMembers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<MemberResponseDto> getMember(@PathVariable Long id) {
        return ResponseEntity.ok(memberService.getMember(id));
    }

    @GetMapping("/me")
    public ResponseEntity<MemberResponseDto> getMe(@AuthenticationPrincipal UserDetails ud) {
        return ResponseEntity.ok(memberService.getMemberByEmail(ud.getUsername()));
    }

    @PutMapping("/{id}")
    public ResponseEntity<MemberResponseDto> updateMember(@PathVariable Long id,
                                                          @Valid @RequestBody MemberRequestDto dto) {
        return ResponseEntity.ok(memberService.updateMember(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> withdraw(@PathVariable Long id) {
        memberService.withdraw(id);
        return ResponseEntity.noContent().build();
    }
}
EOF

# ─────────────────────────────────────────────
# exception/GlobalExceptionHandler.java
# ─────────────────────────────────────────────
cat > $PKG/exception/GlobalExceptionHandler.java << 'EOF'
package com.nackorea.backend.exception;

import org.springframework.http.*;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String,String>> handleIllegal(IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<Map<String,String>> handleBadCredentials(BadCredentialsException e) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("message", "이메일 또는 비밀번호가 올바르지 않습니다."));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map<String,String>> handleAccessDenied(AccessDeniedException e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(Map.of("message", "접근 권한이 없습니다."));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String,String>> handleValidation(MethodArgumentNotValidException e) {
        Map<String,String> errors = e.getBindingResult().getFieldErrors().stream()
                .collect(Collectors.toMap(FieldError::getField, FieldError::getDefaultMessage));
        return ResponseEntity.badRequest().body(errors);
    }
}
EOF

# ─────────────────────────────────────────────
# gradlew 권한 설정 (이미 있으면 skip)
# ─────────────────────────────────────────────
if [ -f "$BASE/gradlew" ]; then
    chmod +x $BASE/gradlew
fi

echo ""
echo "✅ 모든 파일 생성 완료!"
echo ""
echo "▶ 실행 방법:"
echo "   cd $BASE"
echo "   ./gradlew bootRun"
echo ""
echo "※ gradlew가 없으면 아래 명령으로 Gradle Wrapper를 먼저 생성하세요:"
echo "   cd $BASE && gradle wrapper --gradle-version 8.10"
