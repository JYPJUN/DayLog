package com.daylog.mediafile.service;

import com.daylog.couple.entity.Couple;
import com.daylog.couple.repository.CoupleRepository;
import com.daylog.mediafile.dto.MediaFileResponseDto;
import com.daylog.mediafile.entity.MediaFile;
import com.daylog.mediafile.repository.MediaFileRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class MediaFileService {

    private final MediaFileRepository mediaFileRepository;
    private final CoupleRepository coupleRepository;
    private static final Logger logger = LoggerFactory.getLogger(MediaFileService.class);
    private static final String rootDir = "/mnt/mediafiles/";

    public void saveMediaFiles(List<MultipartFile> mediaFiles, String date, Long coupleId) throws IOException {
        String uploadDir = rootDir + coupleId + "/" + date + "/";
        File uploadDirFile = new File(uploadDir);

        //해당 디렉토리 없으면 만들어줌.
        if (!uploadDirFile.exists()) {
            boolean dirsCreated = uploadDirFile.mkdirs();
        }

        for (MultipartFile multipartFile : mediaFiles) {
            File dest = new File(uploadDir + multipartFile.getOriginalFilename());
            multipartFile.transferTo(dest);
            mediaFileRepository.save(MediaFile.builder()
                    .couple(findCoupleById(coupleId))
                    .filePath(uploadDir + multipartFile.getOriginalFilename())
                    .date(date)
                    .build());
        }
    }

    public List<MediaFileResponseDto> getMediaFiles(Long coupleId, String date) {
        List<MediaFile> mediaFiles = mediaFileRepository.findAllByCoupleIdAndDate(coupleId, date);

        //커플 유효성 검사
        for (MediaFile mediaFile : mediaFiles) {
            if (!mediaFile.getCouple().getId().equals(coupleId)) {
                throw new IllegalStateException("파일 읽기에 대한 권한이 없습니다.");
            }
        }

        return mediaFiles.stream()
                .map(MediaFile::toDto)
                .collect(Collectors.toList());
    }

    public void updateMediaFIle(MultipartFile updateFile, Long coupleId, Long fileId) {
        MediaFile findMediaFile = mediaFileRepository.findById(fileId).orElseThrow(() -> new RuntimeException("파일을 찾을 수 없습니다"));

        //커플 유효성 검사
        if (findMediaFile.getCouple().getId().equals(coupleId)) {
            String filePath = findMediaFile.getFilePath();
            System.out.println(filePath);
            try {
                //삭제 먼저
                Files.deleteIfExists(Paths.get(filePath));

                //그다음 파일 추가
                String uploadDir = extractPath(filePath);
                String newFilePath = uploadDir + updateFile.getOriginalFilename();
                File dest = new File(newFilePath);
                updateFile.transferTo(dest);

                findMediaFile.setFilePath(newFilePath);
                //DB 업데이트
                mediaFileRepository.save(findMediaFile);
            } catch (IOException e) {
                logger.error("Failed to delete file: " + filePath, e);
                throw new IllegalStateException("파일 삭제에 실패했습니다.");
            }
        } else {
            throw new IllegalStateException("파일 수정에 대한 권한이 없습니다");
        }
    }

    public void deleteMediaFile(Long coupleId, Long fileId) {
        MediaFile findMediaFile = mediaFileRepository.findById(fileId).orElseThrow(() -> new IllegalStateException("파일을 찾을 수 없습니다."));
        if (findMediaFile.getCouple().getId().equals(coupleId)) {
            String filePath = findMediaFile.getFilePath();
            try {
                Files.deleteIfExists(Paths.get(filePath));
            } catch (IOException e) {
                logger.error("Failed to delete file: " + filePath, e);
                throw new RuntimeException("파일 삭제에 실패했습니다.");
            }
            mediaFileRepository.deleteById(fileId);
        } else {
            throw new IllegalStateException("해당 파일에 대한 삭제 권한이 없습니다");
        }
    }

    private Couple findCoupleById(Long coupleId) {
        return coupleRepository.findById(coupleId).orElse(null);
    }

    //루트 디렉토리 찾는 메서드
    private String extractPath(String fullPath) {
        int lastSlashIndex = fullPath.lastIndexOf('/');
        if (lastSlashIndex == -1) {
            return null;  // 슬래시가 없으면 null 반환
        }
        return fullPath.substring(0, lastSlashIndex + 1);
    }

    public List<MediaFileResponseDto> getMediaFiles(Long coupleId, int year, int month) {
        Couple couple = coupleRepository.findById(coupleId)
                .orElseThrow(() -> new EntityNotFoundException("Couple not found with id " + coupleId));

        String startDateString = String.format("%04d-%02d-01", year, month);
        LocalDate startDate = LocalDate.parse(startDateString);
        LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());
        String endDateString = endDate.toString();

        List<MediaFile> mediaFiles = mediaFileRepository.findByCoupleAndDateBetween(couple, startDateString, endDateString);

        return mediaFiles.stream()
                .map(MediaFile::toDto)
                .collect(Collectors.toList());
    }
}
