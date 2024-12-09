package com.daylog.global.jwt;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Builder
@Data
@AllArgsConstructor
public class JwtToken {
    private String grantType; //Jwt에 대한 인증 방식 => Bearer
    private String accessToken;
    private String refreshToken;
}