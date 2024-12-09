package com.daylog.user.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 35, nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(length = 10, nullable = false)
    private String name;

    @Column(length = 13, nullable = false, unique = true)
    private String phone;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(nullable = false, updatable = false)
    private Date createdAt;

    @Column(nullable = false)
    private String profileImagePath;


    @Column(length = 8, nullable = true, unique = true)
    private String coupleCode;

    @Temporal(TemporalType.DATE)
    @Column
    private Date birthDate;

    @Column(name = "couple_id", nullable = false)
    private Long coupleId;

    @Enumerated(EnumType.STRING)
    @Column
    private Status status;

    @Column
    private String fcmToken;

    @PrePersist
    private void prePersist() {
        if (this.coupleCode == null || this.coupleCode.isEmpty()) {
            this.coupleCode = generateRandomCode();
        }
        if (this.profileImagePath == null || this.profileImagePath.isEmpty()) {
            this.profileImagePath = generateRandomImagePath();
        }
    }

    private static String generateRandomCode() {
        return UUID.randomUUID().toString().substring(0, 8);
    }

    private static String generateRandomImagePath() {
        return "images/" + UUID.randomUUID().toString() + ".jpg";
    }

    public void changePassword(String encodedPassword) {
        this.password = encodedPassword;
    }

    public void changeName(String name) {
        this.name = name;
    }

    public void changeCoupleId(Long coupleId) {
        this.coupleId = coupleId;
    }


    public void changeProfileImagePath(String profileImagePath) {
        this.profileImagePath = profileImagePath;
    }

    public void changeStatus(Status status) {
        this.status = status;
    }

    public void changeFcmToken(String fcmToken) {
        this.fcmToken = fcmToken;
    }

    //현재 플랫폼에서는 권한 필요 없음!
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }

    @Override
    public String getUsername() {
        return email;
    }


}
