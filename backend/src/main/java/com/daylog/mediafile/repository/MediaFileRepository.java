package com.daylog.mediafile.repository;

import com.daylog.couple.entity.Couple;
import com.daylog.mediafile.entity.MediaFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface MediaFileRepository extends JpaRepository<MediaFile, Long> {
    @Query("SELECT m FROM MediaFile m WHERE m.couple.id = :coupleId AND m.date = :date")
    List<MediaFile> findAllByCoupleIdAndDate(@Param("coupleId") Long coupleId, @Param("date") String date);

    List<MediaFile> findByCoupleAndDateBetween(Couple couple, String date, String date2);

    @Query("SELECT mf FROM MediaFile mf WHERE mf.couple.id = :coupleId AND SUBSTRING(mf.date, 1, 4) = :year AND SUBSTRING(mf.date, 6, 2) = :month")
    List<MediaFile> findByCoupleIdAndYearAndMonth(@Param("coupleId") Long coupleId, @Param("year") String year, @Param("month") String month);
}
