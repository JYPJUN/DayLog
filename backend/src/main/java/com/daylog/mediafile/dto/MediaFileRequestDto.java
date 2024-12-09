package com.daylog.mediafile.dto;

import lombok.Builder;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

@Data
@Builder
public class MediaFileRequestDto {
    private List<MultipartFile> mediaFiles;
    private String date;
}
