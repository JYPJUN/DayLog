package com.daylog.diary.dto;

import lombok.*;

@Getter
@Setter
@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class DiaryRequestDto {
    private String title;
    private String artImagePath;
    private String content;
    private String date;
}
