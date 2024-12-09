package com.daylog.clip.service;

import com.daylog.clip.dto.ClipRequestDto;
import com.daylog.clip.dto.ClipResponseDto;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface ClipService {
    void saveClip(ClipRequestDto clipRequestDto);

    List<ClipResponseDto> getClips(Long coupleId, int year, int month);

    void deleteClip(Long coupleId, Long clipId);
}
