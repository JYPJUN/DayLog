package com.daylog.couple.service;

import com.daylog.couple.dto.CoupleRequest;
import com.daylog.couple.dto.CoupleResponse;
import com.daylog.couple.entity.Couple;
import com.daylog.couple.repository.CoupleRepository;
import com.daylog.notification.service.NotificationService;
import com.daylog.pet.entity.Pet;
import com.daylog.user.entity.Status;
import com.daylog.user.entity.User;
import com.daylog.user.service.UserService;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class CoupleServiceImpl implements CoupleService {
    private final CoupleRepository coupleRepository;
    private final UserService userService;
    private final NotificationService notificationService;
    private final String rootDir = "/mnt/couples/";

    @Override
    public CoupleResponse.CoupleDto getCoupleDetail(Long userId, Long coupleId) {
        Couple couple = getCoupleByCoupleId(coupleId);
        User user1 = userService.getUserByUserId(userId);
        User user2 = userService.getUserByUserId(couple.getUser1().getId());
        if (couple.getUser1().getId().equals(userId)) {
            user2 = userService.getUserByUserId(couple.getUser2().getId());
        }
        return CoupleResponse.CoupleDto.toDto(couple, user1, user2);
    }

    @Override
    public void updateProfileImage(Long userId, Long coupleId, MultipartFile file) throws IOException, FirebaseMessagingException {
        Couple couple = getCoupleByCoupleId(coupleId);
        String path = rootDir + coupleId;

        Path directory = Paths.get(path);
        if (!Files.exists(directory)) {
            Files.createDirectories(directory);
        }

        if (!couple.getBackgroundImagePath().equals("/mnt/couples/default.png")) {
            Path oldFilePath = Paths.get(couple.getBackgroundImagePath());
            Files.deleteIfExists(oldFilePath);
        }

        // 파일명을 UUID로 변환
        String originalFilename = file.getOriginalFilename();
        String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String uuidFilename = UUID.randomUUID().toString() + fileExtension;

        String fileName = rootDir + coupleId + "/" + uuidFilename;
        Path filePath = directory.resolve(fileName);

        Files.write(filePath, file.getBytes());

        couple.changeBackgroundImagePath(filePath.toString());
        coupleRepository.save(couple);
        notificationService.sendPushNotification(userId, coupleId, "님이 배경을 수정하였습니다.", "home", 0L);
    }

    @Override
    public void updateRelationshipStartDate(Long coupleId, CoupleRequest.DateDto dateDto) {
        Couple couple = getCoupleByCoupleId(coupleId);
        couple.changeRelationshipStartDate(dateDto.getRelationshipStartDate());
        coupleRepository.save(couple);
    }

    @Override
    public void disconnectCouple(Long userId, Long coupleId) {
        System.out.println("coupleId = " + coupleId);
        Couple couple = getCoupleByCoupleId(coupleId);
        couple.getUser1().changeStatus(Status.INACTIVE);
        couple.getUser2().changeStatus(Status.INACTIVE);
        couple.getUser1().changeCoupleId(0L);
        couple.getUser2().changeCoupleId(0L);
        coupleRepository.save(couple);
        coupleRepository.delete(couple);
    }

    @Override
    public Couple createCoupleAndReturn(User user1, User user2, Pet pet) {
        Couple couple = Couple.builder()
                .user1(user1)
                .user2(user2)
                .backgroundImagePath("/mnt/couples/default.png")
                .pet(pet)
                .build();
        coupleRepository.save(couple);
        return couple;
    }

    @Override
    public Couple getCoupleByCoupleId(Long coupleId) {
        return coupleRepository.findById(coupleId).orElseThrow(() -> new IllegalArgumentException("커플정보를 찾을 수 없습니다."));
    }
}