package com.nackorea.backend.service;

import com.nackorea.backend.dto.MemberRequestDto;
import com.nackorea.backend.dto.MemberResponseDto;
import com.nackorea.backend.dto.MemberUpdateDto;
import com.nackorea.backend.entity.Member;
import com.nackorea.backend.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

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
    public MemberResponseDto updateMe(String email, MemberUpdateDto dto) {
        Member member = memberRepository.findByEmail(email)
                .filter(m -> m.getStatus() == Member.Status.ACTIVE)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 회원입니다."));
        member.setPhone(dto.getPhone());
        if (StringUtils.hasText(dto.getPassword())) {
            member.setPassword(passwordEncoder.encode(dto.getPassword()));
        }
        return MemberResponseDto.from(member);
    }

    @Transactional
    public void withdraw(Long id) {
        findActiveById(id).setStatus(Member.Status.WITHDRAWN);
    }

    @Transactional
    public void withdrawByEmail(String email) {
        memberRepository.findByEmail(email)
                .filter(m -> m.getStatus() == Member.Status.ACTIVE)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 회원입니다."))
                .setStatus(Member.Status.WITHDRAWN);
    }

    private Member findActiveById(Long id) {
        return memberRepository.findById(id)
                .filter(m -> m.getStatus() == Member.Status.ACTIVE)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 회원입니다."));
    }
}
