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



