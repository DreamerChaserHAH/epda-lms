package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.AcademicLeader;

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

    public AcademicLeaderDTO(AcademicLeader academicLeader){
        this.userId = academicLeader.getUserId();
        this.fullname = academicLeader.getFullName();
        this.numberOfLecturerInCharge = 0L;
    }
}
