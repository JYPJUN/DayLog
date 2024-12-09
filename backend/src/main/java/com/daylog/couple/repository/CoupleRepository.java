package com.daylog.couple.repository;

import com.daylog.couple.entity.Couple;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CoupleRepository extends JpaRepository<Couple, Long> {
    Optional<Couple> findCoupleIdByUser1Id(Long userId);

    Optional<Couple> findCoupleIdByUser2Id(Long userId);
}
