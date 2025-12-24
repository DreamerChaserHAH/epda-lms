package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.enums.Gender;
import com.htetaung.lms.models.enums.UserRole;

import java.util.Date;

public class UserDTO {
    public Long userId;
    public String username;
    public String fullName;
    public Date dateOfBirth;
    public String ic;
    public String email;
    public String phoneNumber;
    public String address;
    public UserRole role;
    public Gender gender;
    public Date registeredOn;

    public UserDTO(
            Long userId,
            String username,
            String fullName,
            Date dateOfBirth,
            String ic,
            String email,
            String phoneNumber,
            String address,
            UserRole role,
            Date registeredOn,
            Gender gender
    ) {
        this.userId = userId;
        this.username = username;
        this.fullName = fullName;
        this.dateOfBirth = dateOfBirth;
        this.ic = ic;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.role = role;
        this.gender = gender;
        this.registeredOn = registeredOn;
    }
}
