package com.daylog.couple.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

public class CoupleRequest {

    @Getter
    @Setter
    public static class DateDto {
        private Date relationshipStartDate;
    }
}
