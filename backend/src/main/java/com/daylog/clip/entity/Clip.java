package com.daylog.clip.entity;

import com.daylog.clip.dto.ClipResponseDto;
import com.daylog.couple.entity.Couple;
import com.daylog.mediafile.dto.MediaFileResponseDto;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(name = "clips")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Clip {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "couple_id")
    private Couple couple;

    @CreationTimestamp
    @Column(nullable = false)
    private String date;

    @Column(length = 255, nullable = false)
    private String clipVideoPath;

    public void changeClipVideoPath(String clipVideoPath) {
        this.clipVideoPath = clipVideoPath;
    }

    public ClipResponseDto toDto() {
        return ClipResponseDto.builder()
                .id(this.id)
                .filePath(this.clipVideoPath)
                .date(this.date)
                .build();
    }
}