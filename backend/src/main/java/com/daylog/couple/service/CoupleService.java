package com.daylog.couple.service;

import com.daylog.couple.dto.CoupleRequest;
import com.daylog.couple.dto.CoupleResponse;
import com.daylog.couple.entity.Couple;
import com.daylog.pet.entity.Pet;
import com.daylog.user.entity.User;
import com.google.firebase.messaging.FirebaseMessagingException;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface CoupleService {
    CoupleResponse.CoupleDto getCoupleDetail(Long userId, Long coupleId);

    void updateProfileImage(Long userId, Long coupleId, MultipartFile file) throws IOException, FirebaseMessagingException;

    void updateRelationshipStartDate(Long coupleId, CoupleRequest.DateDto dateDto);

    void disconnectCouple(Long userId, Long coupleId);

    Couple createCoupleAndReturn(User user1, User user2, Pet pet);

    Couple getCoupleByCoupleId(Long coupleId);
}
