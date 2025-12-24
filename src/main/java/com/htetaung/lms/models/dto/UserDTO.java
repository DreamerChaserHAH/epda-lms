package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.enums.UserRole;

import java.util.Date;

public class UserDTO {
    public Long userId;
    public String username;
    public String fullName;
    public UserRole role;
    public Date registeredOn;

    public UserDTO(Long userId, String username, String fullName, UserRole role, Date registeredOn) {
        this.userId = userId;
        this.username = username;
        this.fullName = fullName;
        this.role = role;
        this.registeredOn = registeredOn;
    }
}
