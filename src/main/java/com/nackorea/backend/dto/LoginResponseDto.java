package com.nackorea.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LoginResponseDto {
    private String tokenType;
    private String accessToken;
    private String refreshToken;
    private MemberResponseDto member;
}
