package com.daylog.user.dto;

import com.daylog.user.entity.Status;
import com.daylog.user.entity.User;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Getter;

public class UserResponseDto {

    @Getter
    @Builder
    public static class DuplicateDto {
        @JsonProperty("isDuplicate")
        private boolean duplicate;

        public static DuplicateDto toDto(boolean duplicate) {
            return DuplicateDto.builder()
                    .duplicate(duplicate)
                    .build();
        }
    }

    @Getter
    @Builder
    public static class UserDto {
        private Long userId;
        private Long coupleId;
        private String name;
        private String phone;
        private String profileImagePath;
        private Status status;
        private String coupleCode;

        public static UserDto toDto(User user) {
            return UserDto.builder()
                    .userId(user.getId())
                    .coupleId(user.getCoupleId())
                    .name(user.getName())
                    .phone(user.getPhone())
                    .profileImagePath(user.getProfileImagePath())
                    .status(user.getStatus())
                    .coupleCode(user.getCoupleCode())
                    .build();
        }
    }
}
