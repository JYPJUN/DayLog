package com.daylog.announcement.controller;

import com.daylog.announcement.dto.AnnouncementRequest;
import com.daylog.announcement.dto.AnnouncementResponse;
import com.daylog.announcement.service.AnnouncementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/announcements")
public class AnnouncementController {
    private final AnnouncementService announcementService;

    @GetMapping
    public List<AnnouncementResponse.AnnouncementDto> getAllAnnouncement() {
        return announcementService.findAllAnnouncements();
    }

    @PostMapping
    public ResponseEntity<?> createAnnouncement(@RequestBody AnnouncementRequest.AnnouncementDto announcementDto) {
        announcementService.saveAnnouncement(announcementDto);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{announcementId}")
    public AnnouncementResponse.AnnouncementDto getAnnouncementById(@PathVariable Long announcementId) {
        return announcementService.findAnnouncementById(announcementId);
    }

    @PatchMapping("/{announcementId}")
    public ResponseEntity<?> patchAnnouncementById(@PathVariable Long announcementId, @RequestBody AnnouncementRequest.AnnouncementDto announcementDto) {
        announcementService.updateAnnouncementById(announcementId, announcementDto);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{announcementId}")
    public ResponseEntity<?> deleteAnnouncementById(@PathVariable Long announcementId) {
        announcementService.deleteAnnouncementById(announcementId);
        return ResponseEntity.ok().build();
    }

}

