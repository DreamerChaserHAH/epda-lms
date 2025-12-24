package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.Gender;
import com.htetaung.lms.models.enums.UserRole;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@Entity
@Table(name="AcademicLeader")
@PrimaryKeyJoinColumn(name="user_id")
public class AcademicLeader extends Staff{

    @Column(name="programme_id", nullable=false)
    private Long programmeId;

    public AcademicLeader(){
        setRole(UserRole.ACADEMIC_LEADER);
    }

    public AcademicLeader(
            String username,
            String full_name,
            Date dateOfBirth,
            String ic,
            String email,
            String phoneNumber,
            String address,
            String passwordHash,
            java.util.Optional<User> createdBy,
            Gender gender,
            Long department,
            Long programmeId
    ) {
        super(
                username,
                full_name,
                dateOfBirth,
                ic,
                email,
                phoneNumber,
                address,
                passwordHash,
                createdBy,
                UserRole.ACADEMIC_LEADER,
                gender,
                department
        );
        this.programmeId = programmeId;
    }

    public AcademicLeader(User user, Long department, Long programmeId){
        super(user, department);
        user.setRole(UserRole.ACADEMIC_LEADER);
        this.programmeId = programmeId;
    }

    public Long getProgrammeId() {
        return programmeId;
    }

    public void setProgrammeId(Long programmeId) {
        this.programmeId = programmeId;
    }
}
