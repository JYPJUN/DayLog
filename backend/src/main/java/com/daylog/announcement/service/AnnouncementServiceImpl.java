package com.daylog.announcement.service;

import com.daylog.announcement.dto.AnnouncementRequest;
import com.daylog.announcement.dto.AnnouncementResponse;
import com.daylog.announcement.entity.Announcement;
import com.daylog.announcement.repository.AnnouncementRepository;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class AnnouncementServiceImpl implements AnnouncementService {
    private final AnnouncementRepository announcementRepository;

    @Override
    public List<AnnouncementResponse.AnnouncementDto> findAllAnnouncements() {
        return announcementRepository.findAll().stream()
                .map(AnnouncementResponse.AnnouncementDto::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public void saveAnnouncement(AnnouncementRequest.AnnouncementDto announcementDto) {
        announcementRepository.save(announcementDto.toEntity());
    }

    @Override
    public AnnouncementResponse.AnnouncementDto findAnnouncementById(Long announcementId) {
        Announcement announcement = announcementRepository.findById(announcementId)
                .orElseThrow(() -> new EntityNotFoundException("해당 공지를 찾을 수 없습니다."));
        return AnnouncementResponse.AnnouncementDto.toDto(announcement);
    }

    @Override
    public void updateAnnouncementById(Long announcementId, AnnouncementRequest.AnnouncementDto announcementDto) {
        Announcement announcement = announcementRepository.findById(announcementId)
                .orElseThrow(() -> new EntityNotFoundException("해당 공지를 찾을 수 없습니다."));

        String writer = (announcementDto.getWriter() != null) ? announcementDto.getWriter() : announcement.getWriter();
        String title = (announcementDto.getTitle() != null) ? announcementDto.getTitle() : announcement.getTitle();
        String content = (announcementDto.getContent() != null) ? announcementDto.getContent() : announcement.getContent();

        Announcement updatedAnnouncement = Announcement.builder()
                .id(announcementId)
                .writer(writer)
                .title(title)
                .content(content)
                .createdAt(announcement.getCreatedAt())
                .build();
        announcementRepository.save(updatedAnnouncement);
    }

    @Override
    public void deleteAnnouncementById(Long announcementId) {
        if (!announcementRepository.existsById(announcementId)) {
            throw new EntityNotFoundException("해당 공지를 찾을 수 없습니다.");
        }
        announcementRepository.deleteById(announcementId);
    }
}
