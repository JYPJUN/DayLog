package com.daylog.clip.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class ClipResponseDto {
    private Long id;
    private String filePath;
    private String date;
}
