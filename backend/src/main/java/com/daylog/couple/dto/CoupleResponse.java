package com.daylog.couple.dto;

import com.daylog.couple.entity.Couple;
import com.daylog.pet.entity.Pet;
import com.daylog.user.entity.User;
import lombok.Builder;
import lombok.Getter;

import java.util.Date;

public class CoupleResponse {

    @Getter
    @Builder
    public static class CoupleDto {
        private String backgroundImagePath;
        private Date relationshipStartDate;
        private Long user1Id;
        private String user1Name;
        private String user1ProfileImagePath;
        private Long user2Id;
        private String user2Name;
        private String user2ProfileImagePath;
        private Pet pet;

        public static CoupleResponse.CoupleDto toDto(Couple couple, User user1, User user2) {
            return CoupleDto.builder()
                    .backgroundImagePath(couple.getBackgroundImagePath())
                    .relationshipStartDate(couple.getRelationshipStartDate())
                    .user1Id(user1.getId())
                    .user1Name(user1.getName())
                    .user1ProfileImagePath(user1.getProfileImagePath())
                    .user2Id(user2.getId())
                    .user2Name(user2.getName())
                    .user2ProfileImagePath(user2.getProfileImagePath())
                    .pet(couple.getPet())
                    .build();
        }
    }
}
