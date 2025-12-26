package com.htetaung.lms.models.dto;

public class StudentDTO {
    public Long userId;
    public String fullname;
    public String email;
    public String phoneNumber;

    public StudentDTO(Long userId, String fullname, String email, String phoneNumber){
        this.userId = userId;
        this.fullname = fullname;
        this.email = email;
        this.phoneNumber = phoneNumber;
    }
}
