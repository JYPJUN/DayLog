package com.daylog.notification.entity;

import com.daylog.couple.entity.Couple;
import com.daylog.user.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.util.Date;

@Entity
@Table(name = "notifications")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "couple_id")
    private Couple couple;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column
    private String body;

    @Column
    private boolean isRead;

    @Column
    @CreationTimestamp
    private Date createdAt;

    @Column
    private Long itemId;

    @Column
    private String type;

    public static Notification toEntity(Couple couple, User user, String body, Long itemId, String type) {
        return Notification.builder()
                .couple(couple)
                .user(user)
                .body(body)
                .isRead(false)
                .itemId(itemId)
                .type(type)
                .build();
    }

    public void changeReadStatus() {
        this.isRead = true;
    }
}
