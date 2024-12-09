package com.daylog.announcement.dto;

import com.daylog.announcement.entity.Announcement;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.Date;

public class AnnouncementResponse {

    @Getter
    @Setter
    @Builder
    public static class AnnouncementDto {
        private Long id;
        private String writer;
        private String title;
        private String content;
        private Date createdAt;

        public static AnnouncementDto toDto(Announcement announcement) {
            return AnnouncementDto.builder()
                    .id(announcement.getId())
                    .writer(announcement.getWriter())
                    .title(announcement.getTitle())
                    .content(announcement.getContent())
                    .createdAt(announcement.getCreatedAt())
                    .build();
        }
    }
}
