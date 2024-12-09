package com.daylog.user.dto;

import com.daylog.user.entity.Status;
import com.daylog.user.entity.User;
import lombok.Getter;
import lombok.Setter;

public class UserRequestDto {

    @Getter
    @Setter
    public static class SignUpDto {
        private String email;
        private String password;
        private String name;
        private String phone;

        public User toEntity(String encodedPassword) {
            return User.builder()
                    .email(email)
                    .password(encodedPassword)
                    .name(name)
                    .phone(phone)
                    .coupleId(0L)
                    .profileImagePath("/mnt/users/default.png")
                    .status(Status.INACTIVE)
                    .build();
        }
    }

    @Getter
    @Setter
    public static class SignInDto {
        private String email;
        private String password;
        private String fcmToken;
    }

    @Getter
    @Setter
    public static class PasswordDto {
        private String rawPassword;
        private String newPassword;
    }

    @Getter
    @Setter
    public static class NameDto {
        private String name;
    }
}
