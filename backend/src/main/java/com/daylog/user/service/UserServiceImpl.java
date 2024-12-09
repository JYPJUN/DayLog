package com.daylog.user.service;

import com.daylog.global.jwt.JwtToken;
import com.daylog.global.jwt.JwtTokenProvider;
import com.daylog.hold.repository.HoldRepository;
import com.daylog.user.dto.UserRequestDto;
import com.daylog.user.dto.UserResponseDto;
import com.daylog.user.entity.Status;
import com.daylog.user.entity.User;
import com.daylog.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;

    private final String rootDir = "/mnt/users/";
    private final HoldRepository holdRepository;

    @Override
    public void signUp(UserRequestDto.SignUpDto signUpDto) {
        String encodedPassword = passwordEncoder.encode(signUpDto.getPassword());
        userRepository.save(signUpDto.toEntity(encodedPassword));
    }

    @Override
    @Transactional
    public JwtToken login(UserRequestDto.SignInDto signInDto) {
        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(signInDto.getEmail(), signInDto.getPassword());
        Authentication authentication = authenticationManagerBuilder.getObject().authenticate(authenticationToken);
        User user = userRepository.findByEmail(signInDto.getEmail())
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));
        if (user.getStatus() == Status.DELETED) {
            throw new RuntimeException("탈퇴한 회원입니다.");
        }
        user.changeFcmToken(signInDto.getFcmToken());
        userRepository.save(user);
        return jwtTokenProvider.generateToken(authentication, user.getId(), user.getCoupleId());
    }

    @Override
    public UserResponseDto.DuplicateDto checkDuplicateEmail(String email) {
        return UserResponseDto.DuplicateDto.toDto(userRepository.existsByEmail(email));
    }

    @Override
    public UserResponseDto.DuplicateDto checkDuplicatePhone(String phone) {
        return UserResponseDto.DuplicateDto.toDto(userRepository.existsByPhone(phone));
    }

    @Override
    public UserResponseDto.UserDto getUser(Long userId) {
        User user = getUserByUserId(userId);
        return UserResponseDto.UserDto.toDto(user);
    }

    @Override
    public UserResponseDto.DuplicateDto checkDuplicatePassword(Long userId, UserRequestDto.PasswordDto passwordDto) {
        User findUser = getUserByUserId(userId);
        return UserResponseDto.DuplicateDto.toDto(passwordEncoder.matches(passwordDto.getRawPassword(), findUser.getPassword()));
    }

    @Override
    public void updatePassword(Long userId, UserRequestDto.PasswordDto passwordDto) {
        User user = getUserByUserId(userId);
        user.changePassword(passwordEncoder.encode(passwordDto.getNewPassword()));
        userRepository.save(user);
    }

    @Override
    public void updateName(Long userId, UserRequestDto.NameDto nameDto) {
        User user = getUserByUserId(userId);
        user.changeName(nameDto.getName());
        userRepository.save(user);
    }

    @Override
    public void removeUser(Long userId) {
        User user = getUserByUserId(userId);
        user.changeStatus(Status.DELETED);
        userRepository.save(user);
    }

    @Override
    public void updateProfileImage(Long userId, MultipartFile file) throws IOException {
        User user = getUserByUserId(userId);
        String path = rootDir + userId;

        Path directory = Paths.get(path);
        if (!Files.exists(directory)) {
            Files.createDirectories(directory);
        }

        if (!user.getProfileImagePath().equals("/mnt/users/default.png")) {
            Path oldFilePath = Paths.get(user.getProfileImagePath());
            Files.deleteIfExists(oldFilePath);
        }

        String fileName = rootDir + userId + "/" + file.getOriginalFilename();
        Path filePath = directory.resolve(fileName);

        Files.write(filePath, file.getBytes());

        user.changeProfileImagePath(filePath.toString());
        userRepository.save(user);
    }

    @Override
    public User getUserByUserId(Long userId) {
        return userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    }

    @Override
    public User getUserByCoupleCode(String coupleCode) {
        return userRepository.findByCoupleCode(coupleCode).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    }

    @Override
    public void updateUser(User user, Status status) {
        user.changeStatus(status);
        userRepository.save(user);
    }

    @Override
    public void updateUserStatus(Long userId) {
        User user = getUserByUserId(userId);
        holdRepository.deleteBySenderIdOrReceiverId(userId, userId);
        user.changeStatus(Status.INACTIVE);
    }

    @Override
    public JwtToken getNewJwtToken(Long userId) {
        User user = getUserByUserId(userId);
        return jwtTokenProvider.generateToken(user.getEmail(), userId, user.getCoupleId());
    }

    @Override
    public void logout(Long userId) {
        User user = getUserByUserId(userId);
        user.changeFcmToken("");
        userRepository.save(user);
    }

    @Transactional
    @Override
    public void updateUser(User user1, User user2, Long coupleId, Status status) {
        user1.changeCoupleId(coupleId);
        user1.changeStatus(status);
        user2.changeCoupleId(coupleId);
        user2.changeStatus(status);
        userRepository.save(user1);
        userRepository.save(user2);
    }
}
