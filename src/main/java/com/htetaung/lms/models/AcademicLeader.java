package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.UserRole;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

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

    public AcademicLeader(String username, String full_name, String passwordHash, java.util.Optional<User> createdBy, Long department, Long programmeId) {
        super(
                username,
                full_name,
                passwordHash,
                createdBy,
                UserRole.ACADEMIC_LEADER,
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
