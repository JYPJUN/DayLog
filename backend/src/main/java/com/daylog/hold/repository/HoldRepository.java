package com.daylog.hold.repository;

import com.daylog.hold.entity.Hold;
import com.daylog.user.entity.User;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HoldRepository extends JpaRepository<Hold, Long> {
    boolean existsBySenderAndReceiver(User sender, User receiver);

    Hold findByReceiverId(Long id);

    void deleteBySenderIdOrReceiverId(Long senderId, Long receiverId);
}
