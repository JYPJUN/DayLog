package com.daylog.schedule.entity;

import com.daylog.couple.entity.Couple;
import com.daylog.schedule.dto.ScheduleRequest;
import com.daylog.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Date;

@Entity
@Table(name = "schedules")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Schedule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "couple_id")
    private Couple couple;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ScheduleType type;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(length = 255, nullable = false)
    private String content;

    //startDate와 endDate의 날짜는 같음
    @Temporal(TemporalType.TIMESTAMP)
    @Column(nullable = false, updatable = true)
    private LocalDateTime startDate; // 날짜+시간(hour) 조합

    @Temporal(TemporalType.TIMESTAMP)
    @Column(nullable = false, updatable = true)
    private LocalDateTime endDate; // 날짜+시간(hour) 조합

    public void update(ScheduleRequest.ScheduleDto scheduleDto) {
        if(scheduleDto.getType() != null) {
            this.type = scheduleDto.getType();
        }
        if (scheduleDto.getContent() != null) {
            this.content = scheduleDto.getContent();
        }
        updateDateAndTime(scheduleDto.getDate(), scheduleDto.getStartTime(), scheduleDto.getEndTime());
    }

    private void updateDateAndTime(LocalDate newDate, Integer newStartTime, Integer newEndTime) {
        if (newDate != null) {
            startDate = LocalDateTime.of(newDate, startDate.toLocalTime());
            endDate = LocalDateTime.of(newDate, endDate.toLocalTime());
            if(newStartTime != null) {
                startDate = LocalDateTime.of(newDate, LocalTime.of(newStartTime, 0));
            }
            if(newEndTime != null) {
                endDate = LocalDateTime.of(newDate, LocalTime.of(newEndTime, 0));
            }
        } else {
            if(newStartTime != null) {
                startDate = LocalDateTime.of(startDate.toLocalDate(), LocalTime.of(newStartTime, 0));
            }
            if(newEndTime != null) {
                endDate = LocalDateTime.of(endDate.toLocalDate(), LocalTime.of(newEndTime, 0));
            }
        }
    }

    public void updateUser(User user) {
        this.user = user;
    }

}