package com.daylog.announcement.service;

import com.daylog.announcement.dto.AnnouncementRequest;
import com.daylog.announcement.dto.AnnouncementResponse;
import java.util.List;

public interface AnnouncementService {
    List<AnnouncementResponse.AnnouncementDto> findAllAnnouncements();

    void saveAnnouncement(AnnouncementRequest.AnnouncementDto announcementDto);

    AnnouncementResponse.AnnouncementDto findAnnouncementById(Long announcementId);

    void updateAnnouncementById(Long announcementId, AnnouncementRequest.AnnouncementDto announcementDto);

    void deleteAnnouncementById(Long announcementId);

}
