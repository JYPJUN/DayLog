package com.daylog.user.service;

import com.daylog.global.jwt.JwtToken;
import com.daylog.user.dto.UserRequestDto;
import com.daylog.user.dto.UserResponseDto;
import com.daylog.user.entity.Status;
import com.daylog.user.entity.User;
import jakarta.transaction.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface UserService {
    void signUp(UserRequestDto.SignUpDto signUpDto);

    JwtToken login(UserRequestDto.SignInDto signInDto);

    UserResponseDto.DuplicateDto checkDuplicateEmail(String email);

    UserResponseDto.DuplicateDto checkDuplicatePhone(String phone);

    UserResponseDto.UserDto getUser(Long userId);

    UserResponseDto.DuplicateDto checkDuplicatePassword(Long userId, UserRequestDto.PasswordDto passwordDto);

    void updatePassword(Long userId, UserRequestDto.PasswordDto passwordDto);

    void updateName(Long userId, UserRequestDto.NameDto nameDto);

    void removeUser(Long userId);

    void updateProfileImage(Long userId, MultipartFile file) throws IOException;

    User getUserByUserId(Long userId);

    @Transactional
    void updateUser(User user1, User user2, Long coupleId, Status status);

    User getUserByCoupleCode(String coupleCode);

    void updateUser(User user, Status status);

    void updateUserStatus(Long userId);

    JwtToken getNewJwtToken(Long userId);

    void logout(Long userId);
}