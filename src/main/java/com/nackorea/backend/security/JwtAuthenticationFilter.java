package com.nackorea.backend.security;

import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.DisabledException;
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
    private final TokenBlacklist tokenBlacklist;

    @Override
    protected void doFilterInternal(HttpServletRequest req,
                                    HttpServletResponse res,
                                    FilterChain chain)
            throws ServletException, IOException {

        String token = jwtTokenProvider.resolveToken(req);

        if (StringUtils.hasText(token)) {
            try {
                if (!jwtTokenProvider.validateToken(token)) {
                    res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "유효하지 않은 토큰입니다.");
                    return;
                }

                if (tokenBlacklist.isBlacklisted(token)) {
                    res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "로그아웃된 토큰입니다.");
                    return;
                }

                String email = jwtTokenProvider.getEmailFromToken(token);
                UserDetails ud = userDetailsService.loadUserByUsername(email);
                var auth = new UsernamePasswordAuthenticationToken(ud, null, ud.getAuthorities());
                auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));
                SecurityContextHolder.getContext().setAuthentication(auth);

            } catch (ExpiredJwtException e) {
                res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "만료된 토큰입니다. 다시 로그인해주세요.");
                return;
            } catch (DisabledException e) {
                res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "탈퇴한 회원입니다.");
                return;
            } catch (JwtException e) {
                res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "유효하지 않은 토큰입니다.");
                return;
            }
        }

        chain.doFilter(req, res);
    }
}
