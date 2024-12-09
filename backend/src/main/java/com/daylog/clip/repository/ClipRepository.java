package com.daylog.clip.repository;

import com.daylog.clip.entity.Clip;
import com.daylog.couple.entity.Couple;
import com.daylog.mediafile.entity.MediaFile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ClipRepository extends JpaRepository<Clip, Long> {
    List<Clip> findByCoupleAndDateBetween(Couple couple, String startDateString, String endDateString);
}
