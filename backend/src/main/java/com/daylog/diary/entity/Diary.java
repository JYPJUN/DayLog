package com.daylog.diary.entity;

import com.daylog.couple.entity.Couple;
import com.daylog.diary.dto.DiaryResponseDto;
import com.daylog.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.Date;

@Entity
@Table(name = "diaries")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
@ToString
public class Diary {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "couple_id")
    private Couple couple;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String artImagePath;

    @Column(nullable = false)
    private String date;

    private String convertFileToBase64(String filePath) {
        try {
            Path path = Paths.get(filePath);
            byte[] fileBytes = Files.readAllBytes(path);
            return Base64.getEncoder().encodeToString(fileBytes);
        } catch (IOException e) {
            throw new RuntimeException("파일 변환 중 오류 발생", e);
        }
    }

//    private MultipartFile convertFileToMultipartFile(String filePath) {
//        try {
//            File file = new File(filePath);
//            InputStream input = new FileInputStream(file);
//            return new MockMultipartFile(file.getName(), file.getName(), "image/png", input);
//        } catch (IOException e) {
//            throw new RuntimeException("파일 변환 중 오류 발생", e);
//        }
//    }
}
