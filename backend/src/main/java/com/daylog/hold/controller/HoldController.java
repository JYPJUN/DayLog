package com.daylog.hold.controller;

import com.daylog.global.annotation.UserId;
import com.daylog.hold.dto.HolderRequest;
import com.daylog.hold.service.HoldService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/holds")
public class HoldController {
    private final HoldService holdService;

    // 커플 코드 요청
    @PostMapping
    public ResponseEntity<Void> sendRequest(@UserId Long userId, @RequestBody HolderRequest.CoupleCodeDto coupleCodeDto) {
        try {
            holdService.sendRequest(userId, coupleCodeDto);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
