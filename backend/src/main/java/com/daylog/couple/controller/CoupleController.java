package com.daylog.couple.controller;

import com.daylog.couple.dto.CoupleRequest;
import com.daylog.couple.dto.CoupleResponse;
import com.daylog.couple.service.CoupleService;
import com.daylog.global.annotation.CoupleId;
import com.daylog.global.annotation.UserId;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Slf4j
@RestController
@RequestMapping("/api/couples")
@RequiredArgsConstructor
public class CoupleController {
    private final CoupleService coupleService;

    // 커플 정보 조회 (펫 포함)
    @GetMapping
    public ResponseEntity<CoupleResponse.CoupleDto> getCoupleDetail(@UserId Long userId, @CoupleId Long coupleId) {
        return ResponseEntity.ok(coupleService.getCoupleDetail(userId, coupleId));
    }

    // 커플 배경 수정
    @PatchMapping("/update/background-image")
    public ResponseEntity<Void> updateBackgroundImage(@UserId Long userId, @CoupleId Long coupleId, @RequestParam("image") MultipartFile file) throws IOException, FirebaseMessagingException {
        coupleService.updateProfileImage(userId, coupleId, file);
        return ResponseEntity.ok().build();
    }

    // 기념일 수정
    @PatchMapping("/update/relationship-start-date")
    public ResponseEntity<Void> updateRelationshipStartDate(@CoupleId Long coupleId, @RequestBody CoupleRequest.DateDto dateDto) {
        coupleService.updateRelationshipStartDate(coupleId, dateDto);
        return ResponseEntity.ok().build();
    }

    // 커플 연동 해제
    @DeleteMapping
    public ResponseEntity<Void> disconnectCouple(@UserId Long userId, @CoupleId Long coupleId) {
        coupleService.disconnectCouple(userId, coupleId);
        return ResponseEntity.ok().build();
    }
}
