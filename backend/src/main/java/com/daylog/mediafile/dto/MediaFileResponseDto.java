package com.daylog.mediafile.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class MediaFileResponseDto {
    private Long id;
    private String filePath;
    private String date;
}
