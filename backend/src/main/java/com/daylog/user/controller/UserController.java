package com.daylog.user.controller;

import com.daylog.global.annotation.CoupleId;
import com.daylog.global.annotation.UserId;
import com.daylog.global.jwt.JwtToken;
import com.daylog.user.dto.UserRequestDto;
import com.daylog.user.dto.UserResponseDto;
import com.daylog.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<Void> signUp(@RequestBody UserRequestDto.SignUpDto signUpDto) {
        try {
            userService.signUp(signUpDto);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // 로그인
    @PostMapping("/login")
    public ResponseEntity<JwtToken> login(@RequestBody UserRequestDto.SignInDto signInDto) {
        try {
            JwtToken jwtToken = userService.login(signInDto);
            return ResponseEntity.ok(jwtToken);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // 중복 이메일 검증
    @GetMapping("/check-duplicate/email")
    public ResponseEntity<UserResponseDto.DuplicateDto> checkDuplicateEmail(@RequestParam String email) {
        return ResponseEntity.ok(userService.checkDuplicateEmail(email));
    }

    // 중복 전화번호 검증
    @GetMapping("/check-duplicate/phone")
    public ResponseEntity<UserResponseDto.DuplicateDto> checkDuplicatePhone(@RequestParam String phone) {
        return ResponseEntity.ok(userService.checkDuplicatePhone(phone));
    }

    // 회원 정보 조회
    @GetMapping
    public ResponseEntity<UserResponseDto.UserDto> getUser(@UserId Long userId) {
        try {
            return ResponseEntity.ok(userService.getUser(userId));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // 비밀번호 일치하는지 확인
    @PostMapping("/check-duplicate/password")
    public ResponseEntity<UserResponseDto.DuplicateDto> checkDuplicatePassword(@UserId Long userId, @RequestBody UserRequestDto.PasswordDto passwordDto) {
        return ResponseEntity.ok(userService.checkDuplicatePassword(userId, passwordDto));
    }

    // 비밀번호 변경
    @PatchMapping("/update/password")
    public ResponseEntity<Void> updatePassword(@UserId Long userId, @RequestBody UserRequestDto.PasswordDto passwordDto) {
        try {
            userService.updatePassword(userId, passwordDto);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // 닉네임 변경
    @PatchMapping("/update/name")
    public ResponseEntity<Void> updateName(@UserId Long userId, @RequestBody UserRequestDto.NameDto nameDto) {
        try {
            userService.updateName(userId, nameDto);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // 회원 탈퇴
    @DeleteMapping
    public ResponseEntity<Void> removeUser(@UserId Long userId) {
        try {
            userService.removeUser(userId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // 회원 프로필 이미지 변경
    @PatchMapping("/update/profile-image")
    public ResponseEntity<Void> updateProfileImage(@UserId Long userId, @RequestParam("image") MultipartFile file) throws IOException {
        userService.updateProfileImage(userId, file);
        return ResponseEntity.ok().build();
    }

    // 유저 상태 변경
    @PatchMapping("/update/user-status")
    public ResponseEntity<Void> updateStatus(@UserId Long userId) {
        userService.updateUserStatus(userId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/token")
    public ResponseEntity<JwtToken> getNewJwtToken(@UserId Long userId) {
        JwtToken jwtToken = userService.getNewJwtToken(userId);
        return ResponseEntity.ok(jwtToken);
    }

    //로그아웃
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@UserId Long userId) {
        userService.logout(userId);
        return ResponseEntity.ok().build();
    }
}