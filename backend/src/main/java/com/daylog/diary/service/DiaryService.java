package com.daylog.diary.service;

import com.daylog.couple.entity.Couple;
import com.daylog.couple.repository.CoupleRepository;
import com.daylog.diary.dto.DiaryRequestDto;
import com.daylog.diary.dto.DiaryResponseDto;
import com.daylog.diary.entity.Diary;
import com.daylog.diary.repository.DiaryRepository;
import com.daylog.notification.service.NotificationService;
import com.daylog.user.entity.User;
import com.daylog.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.google.firebase.messaging.FirebaseMessagingException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class DiaryService {
    private final DiaryRepository diaryRepository;
    private final UserRepository userRepository;
    private final CoupleRepository coupleRepository;
    private final NotificationService notificationService;
    private static final String rootDir = "/mnt/diaries/";

    public String generateDiaryImage(String text) {
        RestTemplate restTemplate = new RestTemplate();
//                "Create an illustration with soft facial features and captivating eyes that draw in the viewer. " +
//                        "The contrast between the fantastical characters and the more traditional color schemes and elements " +
//                        "provides an interesting narrative quality to the work. The style should incorporate painting realism, " +
//                        "photorealism, and fantasy digital art, based on the following text: \"%s\".",
        // 프롬프트 설정
        //"we are all Korean." +
        String prompt = text + "A cartoon-style illustration of a cute, youthful couple with a Korean-inspired aesthetic, featuring soft pastel tones and a charming, romantic atmosphere.";

        // 요청 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(API_KEY);

        // 요청 본문 설정
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode requestBody = mapper.createObjectNode();
        requestBody.put("prompt", prompt);
        requestBody.put("n", 1);  // 생성할 이미지 수
        requestBody.put("size", "1024x1024");  // 이미지 크기
        requestBody.put("model", "dall-e-3");  // DALL-E 3 모델 사용

        HttpEntity<String> entity;
        try {
            entity = new HttpEntity<>(mapper.writeValueAsString(requestBody), headers);
        } catch (Exception e) {
            throw new RuntimeException("Failed to create request body", e);
        }

        // DALL·E API 호출
        ResponseEntity<String> response = restTemplate.exchange(DALL_E_API_URL, HttpMethod.POST, entity, String.class);

        // 응답 처리
        if (response.getStatusCode() == HttpStatus.OK) {
            try {
                ObjectNode responseJson = mapper.readValue(response.getBody(), ObjectNode.class);
                String imageUrl = responseJson.get("data").get(0).get("url").asText();
                return imageUrl;
            } catch (Exception e) {
                throw new RuntimeException("Failed to parse response", e);
            }
        } else {
            throw new RuntimeException("Failed to generate image: " + response.getStatusCode());
        }
    }

    public void saveDiary(DiaryRequestDto dto, Long userId, Long coupleId) throws IOException, FirebaseMessagingException {
        String uploadDir = rootDir + coupleId + "/" + dto.getDate() + "/";
        File uploadDirFile = new File(uploadDir);

        // 해당 디렉토리가 없으면 생성
        if (!uploadDirFile.exists()) {
            boolean dirsCreated = uploadDirFile.mkdirs();
        }

        // URL로부터 이미지를 파일로 변환하여 저장
        File file = urlConvertToFile(dto.getArtImagePath(), uploadDir);

        Diary diary = Diary.builder()
                .title(dto.getTitle())
                .couple(createCouple(coupleId))
                .user(createUser(userId))
                .content(dto.getContent())
                .date(dto.getDate())
                .artImagePath(file.getAbsolutePath()) // 저장된 파일의 경로를 사용
                .build();

        Diary saveDiary = diaryRepository.save(diary);
        Long itemId = saveDiary.getId();
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("사용자 정보를 찾을 수 없습니다."));
        notificationService.sendPushNotification(userId, coupleId, "님이 새로운 그림일기를 작성하였습니다.", "diary", itemId);
    }

    public File urlConvertToFile(String imageUrl, String destinationDir) throws IOException {
        URL url = new URL(imageUrl);
        String fileName = Paths.get(url.getPath()).getFileName().toString();
        File destinationFile = new File(destinationDir + fileName);

        try (InputStream in = url.openStream()) {
            Files.copy(in, destinationFile.toPath()); // 디렉토리에 파일을 저장하는 코드
        }

        return destinationFile;
    }

    public void updateDiary(Long id, DiaryRequestDto dto, Long coupleId) throws IOException {
        Diary findDiary = diaryRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Invalid diary ID"));
        //권한 체크
        if (!findDiary.getCouple().getId().equals(coupleId)) {
            throw new IllegalArgumentException("일기 수정에 대한 권한이 없습니다.");
        }

        // 해당 디렉토리가 없으면 생성

        String artImagePath = findDiary.getArtImagePath();
        if (!findDiary.getArtImagePath().equals(dto.getArtImagePath())) { //만약 그림 다르면 FilePath 다시 설정
            String uploadDir = rootDir + coupleId + "/" + dto.getDate() + "/";

            File uploadDirFile = new File(uploadDir);

            // 해당 디렉토리가 없으면 생성
            if (!uploadDirFile.exists()) {
                boolean dirsCreated = uploadDirFile.mkdirs();
            }

            File file = urlConvertToFile(dto.getArtImagePath(), uploadDir);
            artImagePath = file.getAbsolutePath();
        }

        Diary updatedDiary = Diary.builder()
                .id(findDiary.getId())
                .title(dto.getTitle())
                .content(dto.getContent())
                .artImagePath(artImagePath)
                .user(findDiary.getUser())
                .couple(findDiary.getCouple())
                .date(findDiary.getDate())
                .build();

        diaryRepository.save(updatedDiary);
    }

    public List<DiaryResponseDto> getDiaries(Long coupleId) {
        return diaryRepository.findAllByCoupleId(coupleId, Sort.by(Sort.Direction.DESC, "date")
                        .and(Sort.by(Sort.Direction.DESC, "id")))
                .stream()
                .map(DiaryResponseDto::toDto)
                .collect(Collectors.toList());
    }


    public void deleteDiary(Long diaryId, Long coupleId) {
        Diary findDiary = diaryRepository.findById(diaryId).orElseThrow(() -> new IllegalStateException("파일을 찾을 수 없습니다."));

        if (!findDiary.getCouple().getId().equals(coupleId)) {
            throw new IllegalStateException("해당 파일 삭제에 대한 권한이 없습니다.");
        }

        String filePath = findDiary.getArtImagePath();
        try {
            Files.deleteIfExists(Paths.get(filePath));
            diaryRepository.deleteById(diaryId);
        } catch (IOException e) {
            throw new RuntimeException("파일 삭제에 실패했습니다.");
        }
    }

    public DiaryResponseDto getDiary(@RequestParam Long diaryId) {
        Diary diary = diaryRepository.findById(diaryId).orElseThrow(() -> new IllegalArgumentException("해당 파일이 없습니다."));
        return DiaryResponseDto.toDto(diary);
    }

    private User createUser(Long userId) {
        return userRepository.findById(userId).orElse(null);
    }

    private Couple createCouple(Long coupleId) {
        return coupleRepository.findById(coupleId).orElse(null);
    }
}
