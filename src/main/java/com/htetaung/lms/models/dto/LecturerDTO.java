package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.AcademicLeader;
import com.htetaung.lms.models.Lecturer;

public class LecturerDTO {
    public Long userId;
    public String fullname;
    public Long academicLeaderUserId;

    public LecturerDTO(
            Long userId,
            String fullname,
            Long academicLeaderUserId
    ) {
        this.userId = userId;
        this.fullname = fullname;
        this.academicLeaderUserId = academicLeaderUserId;
    }

    public LecturerDTO(Lecturer lecturer){
        this.userId = lecturer.getUserId();
        this.fullname = lecturer.getFullName();
        this.academicLeaderUserId = lecturer.getAcademicLeader() != null ? lecturer.getAcademicLeader().getUserId() : null;
    }
}
