package com.htetaung.lms.models.dto;

public class AcademicLeaderDTO {
    public Long userId;
    public String fullname;
    public Long numberOfLecturerInCharge;

    public AcademicLeaderDTO(
            Long userId,
            String fullname,
            Long numberOfLecturerInCharge
    ) {
        this.userId = userId;
        this.fullname = fullname;
        this.numberOfLecturerInCharge = numberOfLecturerInCharge;
    }
}
