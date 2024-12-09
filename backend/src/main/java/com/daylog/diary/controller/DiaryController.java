package com.daylog.diary.controller;

import com.daylog.diary.dto.DiaryRequestDto;
import com.daylog.diary.dto.DiaryResponseDto;
import com.daylog.diary.service.DiaryService;
import com.daylog.global.annotation.CoupleId;
import com.daylog.global.annotation.UserId;
import com.daylog.notification.service.NotificationService;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api")
public class DiaryController {

    private final DiaryService diaryService;

    /*
    추가는 Post로 요청 후 확인하면 /save 엔트포인트로 저장
    수정은 Post로 요청을 보내서 확인 후 Patch
     */

    //텍스트로 일기 요청하기
    @GetMapping("/diaries/generate-image")
    public ResponseEntity<String> requestDiaryByText(@RequestParam("content") String content) {
        return ResponseEntity.ok(diaryService.generateDiaryImage(content));
    }

    //일기 저장
    @PostMapping("/diaries")
    public ResponseEntity<?> requestDiarySave(@RequestBody DiaryRequestDto diaryRequestDto, @UserId Long userId, @CoupleId Long coupleId) throws IOException, FirebaseMessagingException {
        System.out.println("diaryRequestDto.getTitle() = " + diaryRequestDto.getTitle());
        diaryService.saveDiary(diaryRequestDto, userId, coupleId);
        return ResponseEntity.ok(Map.of("message", "Diary saved successfully"));
    }

    //일기 수정
    @PatchMapping("/diaries/{diaryId}")
    public ResponseEntity<String> updateDiary(@RequestBody DiaryRequestDto diaryRequestDto, @PathVariable Long diaryId, @CoupleId Long coupleId) throws IOException {
        diaryService.updateDiary(diaryId, diaryRequestDto, coupleId);
        return ResponseEntity.ok("Diary update successfully");
    }

    @DeleteMapping("/diaries/{diaryId}")
    public ResponseEntity<String> deleteDiary(@PathVariable Long diaryId, @CoupleId Long coupleId) {
        diaryService.deleteDiary(diaryId, coupleId);
        return ResponseEntity.ok("Diary delete successfully");
    }

    //특정 다이어리 제공
    @GetMapping("/diaries/{diaryId}")
    public ResponseEntity<DiaryResponseDto> getDiary(@PathVariable Long diaryId) {
        return ResponseEntity.ok(diaryService.getDiary(diaryId));
    }

    //해당 커플에 대한 모든 다이어리 제공
    @GetMapping("/diaries")
    public ResponseEntity<List<DiaryResponseDto>> getDiaries(@CoupleId Long coupleId) {
        return ResponseEntity.ok(diaryService.getDiaries(coupleId));
    }
}
