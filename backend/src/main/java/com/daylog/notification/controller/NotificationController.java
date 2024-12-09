package com.daylog.notification.controller;

import com.daylog.global.annotation.CoupleId;
import com.daylog.global.annotation.UserId;
import com.daylog.notification.dto.NotificationResponseDto;
import com.daylog.notification.service.NotificationService;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {
    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<List<NotificationResponseDto>> getNotifications(@UserId Long userId, @CoupleId Long coupleId) {
        return ResponseEntity.ok(notificationService.getNotifications(userId, coupleId));
    }

    @GetMapping("/count")
    public ResponseEntity<Long> getNoReadCount(@UserId Long userId, @CoupleId Long coupleId) {
        return ResponseEntity.ok(notificationService.getNoReadCount(userId, coupleId));
    }

    @PostMapping("/call")
    public ResponseEntity<Void> sendCallNotification(@UserId Long userId, @CoupleId Long coupleId) throws FirebaseMessagingException {
        notificationService.sendPushNotification(userId, coupleId, "영상통화가 시작됐어요!", "call");
        return ResponseEntity.ok().build();
    }
}
