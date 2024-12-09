package com.daylog.clip.controller;

import com.daylog.clip.dto.ClipRequestDto;
import com.daylog.clip.dto.ClipResponseDto;
import com.daylog.clip.service.ClipService;
import com.daylog.global.annotation.CoupleId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/clips")
@RequiredArgsConstructor
public class ClipController {
    private final ClipService clipService;

    @PostMapping
    public void saveClip(@RequestBody ClipRequestDto clipRequestDto) {
        clipService.saveClip(clipRequestDto);
    }

    @GetMapping
    public ResponseEntity<List<ClipResponseDto>> getClips(@CoupleId Long coupleId, @RequestParam("year") int year, @RequestParam("month") int month) {
        return ResponseEntity.ok(clipService.getClips(coupleId, year, month));
    }

    @DeleteMapping("/{clipId}")
    public void deleteClip(@CoupleId Long coupleId, @PathVariable Long clipId) {
        clipService.deleteClip(coupleId, clipId);
    }
}
