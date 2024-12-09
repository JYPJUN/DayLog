package com.daylog.mediafile.controller;

import com.daylog.global.annotation.CoupleId;
import com.daylog.mediafile.dto.MediaFileResponseDto;
import com.daylog.mediafile.service.MediaFileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api")
public class MediaFileController {

    private final MediaFileService mediaFileService;

    @GetMapping("/mediafiles/search")
    public ResponseEntity<List<MediaFileResponseDto>> getMediaFiles(@CoupleId Long coupleId, @RequestParam("year") int year, @RequestParam("month") int month) {
        List<MediaFileResponseDto> mediaFiles = mediaFileService.getMediaFiles(coupleId, year, month);
        return ResponseEntity.ok(mediaFiles);
    }

    // api/mediafiles
    @PostMapping("/mediafiles")
    public ResponseEntity<String> uploadMediaFiles(@CoupleId Long coupleId, @RequestParam List<MultipartFile> multipartFiles, @RequestParam String date) throws IOException {
        mediaFileService.saveMediaFiles(multipartFiles, date, coupleId);
        return ResponseEntity.ok("미디어 파일이 성공적으로 저장되었습니다.");
    }

    // api/mediafiles/1
    @DeleteMapping("/mediafiles/{mediaFileId}")
    public ResponseEntity<String> deleteMediaFile(@PathVariable Long mediaFileId, @CoupleId Long coupleId) {
        mediaFileService.deleteMediaFile(coupleId, mediaFileId);
        return ResponseEntity.ok("미디어 파일이 성공적으로 삭제되었습니다.");
    }
}
