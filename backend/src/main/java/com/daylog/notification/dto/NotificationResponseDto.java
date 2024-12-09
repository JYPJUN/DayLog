package com.daylog.notification.dto;

import com.daylog.notification.entity.Notification;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.text.SimpleDateFormat;

@Builder
@Getter
@Setter
public class NotificationResponseDto {
    private Long id;
    private String profileImage;
    private String title;
    private String content;
    private String createdAt;
    private boolean isNew;

    public static NotificationResponseDto toDto(Notification notification, boolean isNew) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

        return NotificationResponseDto.builder()
                .id(notification.getId())
                .profileImage(notification.getUser().getProfileImagePath())
                .title(notification.getType())
                .content(notification.getUser().getName() + notification.getBody())
                .createdAt(dateFormat.format(notification.getCreatedAt()))
                .isNew(isNew)
                .build();
    }
}

