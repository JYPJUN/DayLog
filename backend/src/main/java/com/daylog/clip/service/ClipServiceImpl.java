package com.daylog.clip.service;

import com.daylog.clip.dto.ClipRequestDto;
import com.daylog.clip.dto.ClipResponseDto;
import com.daylog.clip.entity.Clip;
import com.daylog.clip.repository.ClipRepository;
import com.daylog.couple.entity.Couple;
import com.daylog.couple.service.CoupleService;
import com.daylog.mediafile.entity.MediaFile;
import com.daylog.mediafile.service.MediaFileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ClipServiceImpl implements ClipService {
    private final ClipRepository clipRepository;
    private final CoupleService coupleService;
    private final String rootDir = "/mnt/";
    private static final Logger logger = LoggerFactory.getLogger(MediaFileService.class);

    @Override
    public void saveClip(ClipRequestDto clipRequestDto) {
        Couple couple = coupleService.getCoupleByCoupleId(clipRequestDto.getCoupleId());
        Clip clip = clipRequestDto.toEntity(couple);
//        clip.changeClipVideoPath(rootDir + clip.getClipVideoPath());
        clip.changeClipVideoPath(clip.getClipVideoPath());
        clipRepository.save(clip);
    }

    @Override
    public List<ClipResponseDto> getClips(Long coupleId, int year, int month) {
        Couple couple = coupleService.getCoupleByCoupleId(coupleId);

        String startDateString = String.format("%04d-%02d-01", year, month);
        LocalDate startDate = LocalDate.parse(startDateString);
        LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());
        String endDateString = endDate.toString();

        return clipRepository.findByCoupleAndDateBetween(couple, startDateString, endDateString).stream()
                .map(Clip::toDto)
                .collect(Collectors.toList());
    }

    public void deleteClip(Long coupleId, Long clipId) {
        Clip clip = clipRepository.findById(clipId).orElseThrow(() -> new IllegalStateException("파일을 찾을 수 없습니다."));
        if (clip.getCouple().getId().equals(coupleId)) {
            String filePath = clip.getClipVideoPath();
            try {
                Files.deleteIfExists(Paths.get(filePath));
            } catch (IOException e) {
                logger.error("Failed to delete file: " + filePath, e);
                throw new RuntimeException("파일 삭제에 실패했습니다.");
            }
            clipRepository.deleteById(clipId);
        } else {
            throw new IllegalStateException("해당 파일에 대한 삭제 권한이 없습니다");
        }
    }
}
