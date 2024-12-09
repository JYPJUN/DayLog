package com.daylog.schedule.dto;

import com.daylog.schedule.entity.Schedule;
import com.daylog.schedule.entity.ScheduleType;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Date;

public class ScheduleResponse {

    @Getter
    @Setter
    @Builder
    public static class ScheduleDto {
        private Long id;
        private ScheduleType type;
        private Boolean isMine;
        private String content;
        private LocalDate date;
        private int startTime;
        private int endTime;

        public static ScheduleDto toDto(Schedule schedule, boolean isMine) {
            return ScheduleDto.builder()
                    .id(schedule.getId())
                    .type(schedule.getType())
                    .isMine(isMine)
                    .content(schedule.getContent())
                    .date(schedule.getStartDate().toLocalDate())
                    .startTime(schedule.getStartDate().getHour())
                    .endTime(schedule.getEndDate().getHour())
                    .build();
        }
    }
}
