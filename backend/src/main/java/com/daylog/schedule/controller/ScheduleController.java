package com.daylog.schedule.controller;

import com.daylog.global.annotation.CoupleId;
import com.daylog.global.annotation.UserId;
import com.daylog.schedule.dto.ScheduleRequest;
import com.daylog.schedule.dto.ScheduleResponse;
import com.daylog.schedule.service.ScheduleService;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/schedules")
public class ScheduleController {
    private final ScheduleService scheduleService;

    @PostMapping
    public ResponseEntity<?> createSchedule(@UserId Long userId, @CoupleId long coupleId, @RequestBody ScheduleRequest.ScheduleDto scheduleDto) throws FirebaseMessagingException {
        scheduleService.saveSchedule(userId, coupleId, scheduleDto);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{scheduleId}")
    public ScheduleResponse.ScheduleDto getScheduleById(@UserId Long userId, @CoupleId long coupleId, @PathVariable Long scheduleId) {
        return scheduleService.searchScheduleById(userId, coupleId, scheduleId);
    }

    @PatchMapping("/{scheduleId}")
    public ResponseEntity<?> patchScheduleById(@UserId Long userId, @CoupleId long coupleId, @PathVariable Long scheduleId, @RequestBody ScheduleRequest.ScheduleDto scheduleDto) {
        scheduleService.updateSchedule(userId, coupleId, scheduleId, scheduleDto);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{scheduleId}")
    public ResponseEntity<?> deleteScheduleById(@CoupleId long coupleId, @PathVariable Long scheduleId) {
        scheduleService.deleteSchedule(coupleId, scheduleId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/search")
    public List<ScheduleResponse.ScheduleDto> getScheduleMapByYearAndMonth(@UserId Long userId, @CoupleId long coupleId, @RequestParam int year, @RequestParam int month) {
        return scheduleService.searchScheduleByYearAndMonth(userId, coupleId, year, month);
    }

}

