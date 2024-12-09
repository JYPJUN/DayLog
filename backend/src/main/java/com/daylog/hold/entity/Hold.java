package com.daylog.hold.entity;

import com.daylog.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "holds")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Hold {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "sender_id", nullable = false, unique = true)
    private User sender;

    @OneToOne
    @JoinColumn(name = "receiver_id", nullable = false, unique = true)
    private User receiver;
}