package com.daylog.mediafile.entity;

import com.daylog.mediafile.dto.MediaFileResponseDto;
import com.daylog.couple.entity.Couple;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "mediafiles")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class MediaFile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "couple_id")
    private Couple couple;

    @Column(nullable = false)
    private String filePath;

    @Column(nullable = false)
    private String date;

    public MediaFileResponseDto toDto() {
        return MediaFileResponseDto.builder()
                .id(this.id)
                .filePath(this.filePath)
                .date(this.date)
                .build();
    }
}