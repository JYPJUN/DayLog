package com.daylog.schedule.service;

import com.daylog.schedule.dto.ScheduleRequest;
import com.daylog.schedule.dto.ScheduleResponse;
import com.google.firebase.messaging.FirebaseMessagingException;

import java.util.List;
import java.util.Map;

public interface ScheduleService {
    void saveSchedule(Long userId, Long coupleId, ScheduleRequest.ScheduleDto scheduleDto) throws FirebaseMessagingException;

    ScheduleResponse.ScheduleDto searchScheduleById(Long userId, Long coupleId, Long scheduleId);

    void updateSchedule(Long userId, Long coupleId, Long scheduleId, ScheduleRequest.ScheduleDto scheduleDto);

    void deleteSchedule(Long coupleId, Long scheduleId);

    List<ScheduleResponse.ScheduleDto> searchScheduleByYearAndMonth(Long userId, Long coupleId, int year, int month);
}
