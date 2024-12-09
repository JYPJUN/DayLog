package com.daylog.schedule.dto;

import com.daylog.couple.entity.Couple;
import com.daylog.schedule.entity.Schedule;
import com.daylog.schedule.entity.ScheduleType;
import com.daylog.user.entity.User;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class ScheduleRequest {

    @Getter
    @Setter
    public static class ScheduleDto {
        private Long id;
        private ScheduleType type;
        private Boolean isMine;
        private String content;
        private LocalDate date;
        private Integer startTime;
        private Integer endTime;

        public Schedule toEntity(Couple couple, User user) {
            LocalDateTime startDateTime = LocalDateTime.of(date, LocalTime.of(startTime, 0));
            LocalDateTime endDateTime = LocalDateTime.of(date, LocalTime.of(endTime, 0));
            return Schedule.builder()
                    .id(id)
                    .couple(couple)
                    .type(type)
                    .user(user)
                    .content(content)
                    .startDate(startDateTime)
                    .endDate(endDateTime)
                    .build();
        }
    }
}
