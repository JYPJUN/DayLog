package com.daylog.notification.service;

import com.daylog.notification.dto.NotificationResponseDto;
import com.google.firebase.messaging.FirebaseMessagingException;

import java.util.List;

public interface NotificationService {
    void sendPushNotification(Long userId, Long coupleId, String body, String type, Long itemId) throws FirebaseMessagingException;

    void sendPushNotification(Long userId, Long coupleId, String body, String type) throws FirebaseMessagingException;

    List<NotificationResponseDto> getNotifications(Long userId, Long coupleId);

    Long getNoReadCount(Long userId, Long coupleId);
}
