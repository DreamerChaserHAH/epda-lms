package com.htetaung.lms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;

@Entity
@Table(name="AcademicLeader")
@PrimaryKeyJoinColumn(name="user_id")
public class AcademicLeader extends Staff{

    @Column(name="programme_id", nullable=false)
    private Long programmeId;

    public AcademicLeader(){

    }

    public AcademicLeader(String username, String full_name, String passwordHash, java.util.Optional<User> createdBy, Long department, Long programmeId) {
        super(
                username,
                full_name,
                passwordHash,
                createdBy,
                Role.ACADEMIC_LEADER,
                department
        );
        this.programmeId = programmeId;
    }

    public Long getProgrammeId() {
        return programmeId;
    }

    public void setProgrammeId(Long programmeId) {
        this.programmeId = programmeId;
    }
}
