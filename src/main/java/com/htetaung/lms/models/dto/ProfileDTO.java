package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.enums.Gender;
import com.htetaung.lms.models.enums.UserRole;

import java.util.Date;

/// There are two types of Profile, Full Profile and View Profile
/// Full Profile is typically only seen by the user themselves
/// View Profile is typically seen by other users
public class ProfileDTO {

    /// Common Fields
    public Long userId;
    public String username;
    public String fullName;
    public String email;
    public String phoneNumber;
    public String address;
    public UserRole role;
    public Gender gender;

    /// Private Fields for Full Profile
    public Date dateOfBirth;
    public String ic;

    public ProfileDTO(
            Long userId,
            String username,
            String fullName,
            String email,
            String phoneNumber,
            String address,
            UserRole role,
            Gender gender
    ) {
        this.userId = userId;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.role = role;
        this.gender = gender;
    }

    public ProfileDTO(
            Long userId,
            String username,
            String fullName,
            String email,
            String phoneNumber,
            String address,
            UserRole role,
            Gender gender,
            Date dateOfBirth,
            String ic
    ) {
        this.userId = userId;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.role = role;
        this.gender = gender;
        this.dateOfBirth = dateOfBirth;
        this.ic = ic;
    }
}
