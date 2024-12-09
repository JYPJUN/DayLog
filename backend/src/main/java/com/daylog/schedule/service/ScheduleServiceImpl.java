package com.daylog.schedule.service;

import com.daylog.couple.entity.Couple;
import com.daylog.couple.repository.CoupleRepository;
import com.daylog.notification.service.NotificationService;
import com.daylog.schedule.dto.ScheduleRequest;
import com.daylog.schedule.dto.ScheduleResponse;
import com.daylog.schedule.entity.Schedule;
import com.daylog.schedule.entity.ScheduleType;
import com.daylog.schedule.repository.ScheduleRepository;
import com.daylog.user.entity.User;
import com.daylog.user.repository.UserRepository;
import com.google.firebase.messaging.FirebaseMessagingException;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class ScheduleServiceImpl implements ScheduleService {
    private final ScheduleRepository scheduleRepository;
    private final CoupleRepository coupleRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    @Override
    public void saveSchedule(Long userId, Long coupleId, ScheduleRequest.ScheduleDto scheduleDto) throws FirebaseMessagingException {
        Couple couple = findCoupleById(coupleId);
        User user = findOwner(userId, couple, scheduleDto);
        Schedule schedule = scheduleDto.toEntity(couple, user);
        validateSchedule(schedule);
        scheduleRepository.save(schedule);

        notificationService.sendPushNotification(userId, coupleId, "님이 새로운 일정을 추가하였습니다.", "schedule", 0L);
    }

    @Override
    public ScheduleResponse.ScheduleDto searchScheduleById(Long userId, Long coupleId, Long scheduleId) {
        Schedule schedule = findScheduleById(scheduleId);
        verifyCoupleOwnership(coupleId, schedule);
        boolean isMine = schedule.getUser().getId().equals(userId);
        return ScheduleResponse.ScheduleDto.toDto(schedule, isMine);
    }

    // schedule.update(scheduleDto), schedule.updateUser(user); 수정 방법이 적절한지?
    @Override
    public void updateSchedule(Long userId, Long coupleId, Long scheduleId, ScheduleRequest.ScheduleDto scheduleDto) {
        Schedule schedule = findScheduleById(scheduleId);
        verifyCoupleOwnership(coupleId, schedule);
        schedule.update(scheduleDto);
        validateSchedule(schedule);

        if (scheduleDto.getIsMine() != null) {
            Long newOwnerId = findNewOwnerId(userId, coupleId, scheduleDto);
            if (!schedule.getUser().getId().equals(newOwnerId)) {
                schedule.updateUser(findUserById(newOwnerId));
            }
        }

        scheduleRepository.save(schedule);
    }

    @Override
    public void deleteSchedule(Long coupleId, Long scheduleId) {
        Schedule schedule = findScheduleById(scheduleId);
        verifyCoupleOwnership(coupleId, schedule);
        scheduleRepository.delete(schedule);
    }

    @Override
    public List<ScheduleResponse.ScheduleDto> searchScheduleByYearAndMonth(Long userId, Long coupleId, int year, int month) {
        LocalDateTime[] startAndEndOfMonth = findStartAndEndOfMonth(year, month);
        List<Schedule> scheduleList = searchScheduleByYearAndMonth(coupleId, startAndEndOfMonth);
        return makeScheduleDtoList(userId, scheduleList);
    }

    private LocalDateTime[] findStartAndEndOfMonth(int year, int month) {
        LocalDateTime startOfMonth = LocalDateTime.of(year, month, 1, 0, 0);
        LocalDateTime endOfMonth = LocalDateTime.of(year, month,
                startOfMonth.toLocalDate().with(TemporalAdjusters.lastDayOfMonth()).getDayOfMonth(),
                23, 59, 59, 999999999);

        return new LocalDateTime[]{startOfMonth, endOfMonth};
    }

    private List<Schedule> searchScheduleByYearAndMonth(long coupleId, LocalDateTime[] startAndEndOfMonth) {
        return scheduleRepository.findSchedulesInMonth(coupleId, startAndEndOfMonth[0], startAndEndOfMonth[1]);
    }

    private List<ScheduleResponse.ScheduleDto> makeScheduleDtoList(long userId, List<Schedule> scheduleList) {
        List<ScheduleResponse.ScheduleDto> scheduleDtoList = new ArrayList<>();

        for (Schedule schedule : scheduleList) {
            scheduleDtoList.add(ScheduleResponse.ScheduleDto.toDto(schedule, schedule.getUser().getId().equals(userId)));
        }

        return scheduleDtoList;
    }


    private void validateSchedule(Schedule schedule) {
        if (schedule.getStartDate().isAfter(schedule.getEndDate())) {
            throw new RuntimeException("시작시간보다 종료시간이 빠릅니다.");
        }
        if (schedule.getContent() == null || schedule.getContent().isEmpty()) {
            throw new RuntimeException("내용은 비워둘 수 없습니다.");
        }
        if (schedule.getContent().length() > 50) {
            throw new RuntimeException("내용은 50자를 초과할 수 없습니다.");
        }
    }

    private Schedule findScheduleById(Long scheduleId) {
        return scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new EntityNotFoundException("해당 일정이 존재하지 않습니다."));
    }

    private void verifyCoupleOwnership(Long coupleId, Schedule schedule) {
        if (!schedule.getCouple().getId().equals(coupleId)) {
            // 적절한 예외 클래스 지정 필요
            throw new RuntimeException("해당 일정은 해당 커플의 일정이 아닙니다.");
        }
    }

    private Long findNewOwnerId(Long userId, Long coupleId, ScheduleRequest.ScheduleDto scheduleDto) {
        return scheduleDto.getIsMine() ? userId : findPartnerUserId(userId, findCoupleById(coupleId));
    }

    private Couple findCoupleById(Long coupleId) {
        return coupleRepository.findById(coupleId)
                .orElseThrow(() -> new EntityNotFoundException("해당 커플이 존재하지 않습니다."));
    }

    private User findOwner(Long userId, Couple couple, ScheduleRequest.ScheduleDto scheduleDto) {
        if (scheduleDto.getType() == ScheduleType.PERSONAL && scheduleDto.getIsMine() != null && !scheduleDto.getIsMine()) {
            return findUserById(findPartnerUserId(userId, couple));
        } else {
            return findUserById(userId);
        }
    }

    private User findUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("해당 유저가 존재하지 않습니다."));
    }

    private long findPartnerUserId(Long userId, Couple couple) {
        return couple.getUser1().getId().equals(userId)
                ? couple.getUser2().getId()
                : couple.getUser1().getId();
    }
}
