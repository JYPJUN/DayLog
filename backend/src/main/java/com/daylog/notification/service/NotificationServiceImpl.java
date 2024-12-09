package com.daylog.notification.service;

import com.daylog.couple.entity.Couple;
import com.daylog.couple.repository.CoupleRepository;
import com.daylog.notification.dto.NotificationResponseDto;
import com.daylog.notification.repository.NotificationRepository;
import com.daylog.user.entity.User;
import com.daylog.user.service.UserService;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {
    private final NotificationRepository notificationRepository;
    private final UserService userService;
    private final CoupleRepository coupleRepository;

    @Override
    public void sendPushNotification(Long userId, Long coupleId, String body, String type, Long itemId) throws FirebaseMessagingException {
        Couple couple = coupleRepository.findById(coupleId).orElseThrow(() -> new IllegalArgumentException("커플을 찾을 수 없습니다."));

        String token;
        if (couple.getUser1().getId().equals(userId)) {
            token = couple.getUser2().getFcmToken();
        } else {
            token = couple.getUser1().getFcmToken();
        }

        if (!type.equals("call") || token == null || token.isEmpty()) {
            User user = userService.getUserByUserId(userId);
            notificationRepository.save(com.daylog.notification.entity.Notification.toEntity(couple, user, body, itemId, type));
            return;
        }

        User user = userService.getUserByUserId(userId);
        Message message = Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                        .setTitle("DayLog")
                        .setBody(user.getName() + body)
                        .build())
                .putData("type", type)
                .putData("itemId", String.valueOf(itemId))
                .build();

        String response = FirebaseMessaging.getInstance().send(message);
        System.out.println("Successfully sent message: " + response);

        if (type.equals("call")) {
            return;
        }

        notificationRepository.save(com.daylog.notification.entity.Notification.toEntity(couple, user, body, itemId, type));
    }


    @Override
    public void sendPushNotification(Long userId, Long coupleId, String body, String type) throws FirebaseMessagingException {
        Couple couple = coupleRepository.findById(coupleId).orElseThrow(() -> new IllegalArgumentException("커플을 찾을 수 없습니다."));

        String token;
        if (couple.getUser1().getId().equals(userId)) {
            token = couple.getUser2().getFcmToken();
        } else {
            token = couple.getUser1().getFcmToken();
        }

        User user = userService.getUserByUserId(userId);
        Message message = Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                        .setTitle("DayLog")
                        .setBody(body)
                        .build())
                .putData("type", type)
                .putData("itemId", String.valueOf(0))
                .build();

        String response = FirebaseMessaging.getInstance().send(message);
        System.out.println("Successfully sent message: " + response);
    }

    @Override
    public List<NotificationResponseDto> getNotifications(Long userId, Long coupleId) {
        return notificationRepository.findAllByCoupleId(coupleId).stream()
                .sorted(Comparator.comparing(com.daylog.notification.entity.Notification::getCreatedAt).reversed())
                .map(notification -> {
                    NotificationResponseDto dto = NotificationResponseDto.toDto(notification, !notification.getUser().getId().equals(userId) && !notification.isRead());
                    if (!notification.getUser().getId().equals(userId) && !notification.isRead()) {
                        notification.changeReadStatus();
                        notificationRepository.save(notification);
                    }
                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Override
    public Long getNoReadCount(Long userId, Long coupleId) {
        return notificationRepository.findAllByCoupleId(coupleId).stream()
                .filter(notification -> !notification.getUser().getId().equals(userId) && !notification.isRead())
                .count();
    }
}
