package com.daylog.clip.dto;

import com.daylog.clip.entity.Clip;
import com.daylog.couple.entity.Couple;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ClipRequestDto {
    private Long coupleId;
    private String clipVideoPath;

    public Clip toEntity(Couple couple) {
        return Clip.builder()
                .couple(couple)
                .clipVideoPath(clipVideoPath)
                .build();
    }
}
