package com.daylog.schedule.repository;

import com.daylog.schedule.dto.ScheduleResponse;
import com.daylog.schedule.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    @Query("SELECT s FROM Schedule s WHERE s.couple.id = :coupleId AND s.startDate <= :endOfMonth AND s.endDate >= :startOfMonth ORDER BY s.startDate ASC, s.endDate ASC")
    List<Schedule> findSchedulesInMonth(
            @Param("coupleId") long coupleId,
            @Param("startOfMonth") LocalDateTime startOfMonth,
            @Param("endOfMonth") LocalDateTime endOfMonth
    );


}