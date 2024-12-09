package com.daylog.hold.service;

import com.daylog.couple.entity.Couple;
import com.daylog.couple.service.CoupleService;
import com.daylog.hold.dto.HolderRequest;
import com.daylog.hold.entity.Hold;
import com.daylog.hold.repository.HoldRepository;
import com.daylog.pet.entity.Pet;
import com.daylog.pet.service.PetService;
import com.daylog.user.entity.Status;
import com.daylog.user.entity.User;
import com.daylog.user.service.UserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class HoldServiceImpl implements HoldService {
    private final HoldRepository holdRepository;
    private final UserService userService;
    private final CoupleService coupleService;
    private final PetService petService;

    @Override
    @Transactional
    public void sendRequest(Long userId, HolderRequest.CoupleCodeDto userDto) {
        User sender = userService.getUserByUserId(userId);
        User receiver = userService.getUserByCoupleCode(userDto.getCoupleCode());

        Hold hold = Hold.builder()
                .sender(sender)
                .receiver(receiver)
                .build();
        holdRepository.save(hold);
        userService.updateUser(sender, Status.PENDING);

        if (holdRepository.existsBySenderAndReceiver(receiver, sender)) {
            Pet pet = petService.createPetAndReturn();
            Couple couple = coupleService.createCoupleAndReturn(receiver, sender, pet);
            userService.updateUser(sender, receiver, couple.getId(), Status.ACTIVE);
            deleteData(receiver, sender);
        }
    }

    private void deleteData(User receiver, User sender) {
        holdRepository.delete(holdRepository.findByReceiverId(receiver.getId()));
        holdRepository.delete(holdRepository.findByReceiverId(sender.getId()));
    }
}
