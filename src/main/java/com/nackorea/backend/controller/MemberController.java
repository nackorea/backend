package com.nackorea.backend.controller;

import com.nackorea.backend.dto.*;
import com.nackorea.backend.service.MemberService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
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

    @PutMapping("/me")
    public ResponseEntity<MemberResponseDto> updateMe(@AuthenticationPrincipal UserDetails ud,
                                                      @Valid @RequestBody MemberUpdateDto dto) {
        log.info("me ~~~~");
        return ResponseEntity.ok(memberService.updateMe(ud.getUsername(), dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<MemberResponseDto> updateMember(@PathVariable Long id,
                                                          @Valid @RequestBody MemberRequestDto dto) {
        return ResponseEntity.ok(memberService.updateMember(id, dto));
    }

    @DeleteMapping("/me")
    public ResponseEntity<Void> withdrawMe(@AuthenticationPrincipal UserDetails ud) {
        memberService.withdrawByEmail(ud.getUsername());
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> withdraw(@PathVariable Long id) {
        memberService.withdraw(id);
        return ResponseEntity.noContent().build();
    }
}
