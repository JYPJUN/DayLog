package com.daylog.diary.dto;

import com.daylog.diary.entity.Diary;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DiaryResponseDto {
//    private Long id;
//    private String name;
//    private String title;
//    private String content;
//    private String file; // Base64 인코딩된 파일 데이터
//    private String date;

    private Long id;
    private String name;
    private String title;
    private String content;
    private String artImagePath;
    private String date;

    public static DiaryResponseDto toDto(Diary diary) {
        return DiaryResponseDto.builder()
                .id(diary.getId())
                .name(diary.getUser().getName())
                .title(diary.getTitle())
                .content(diary.getContent())
                .artImagePath(diary.getArtImagePath())
                .date(diary.getDate())
                .build();
    }
}
