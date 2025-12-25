package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.AcademicLeader;

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
}
