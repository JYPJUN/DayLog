package com.daylog.notification.repository;

import com.daylog.notification.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findAllByCoupleId(Long coupleId);
}
