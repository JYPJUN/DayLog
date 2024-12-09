package com.daylog.announcement.dto;

import com.daylog.announcement.entity.Announcement;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

public class AnnouncementRequest {

    @Getter
    @Setter
    public static class AnnouncementDto {
        private Long id;
        private String writer;
        private String title;
        private String content;
        private Date createdAt;

        public Announcement toEntity() {
            String writer = (this.writer != null) ? this.writer : "관리자";
            return Announcement.builder()
                    .id(id)
                    .writer(writer)
                    .title(title)
                    .content(content)
                    .createdAt(createdAt)
                    .build();
        }
    }
}
