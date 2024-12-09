package com.daylog.hold.service;

import com.daylog.hold.dto.HolderRequest;

public interface HoldService {
    void sendRequest(Long userId, HolderRequest.CoupleCodeDto userDto);
}
