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


// 커밋 되나
