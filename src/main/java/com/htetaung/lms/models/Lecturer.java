package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.Gender;
import com.htetaung.lms.models.enums.UserRole;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;
import java.util.Optional;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name="Lecturer")
@PrimaryKeyJoinColumn(name="user_id")
public class Lecturer extends Staff{
    @ManyToOne(optional = true)
    @JoinColumn(name = "academic_leader_in_charge", nullable = true, updatable = true)
    private AcademicLeader academicLeader;

    public Lecturer(
            String username,
            String full_name,
            Date dateOfBirth,
            String ic,
            String email,
            String phoneNumber,
            String address,
            String passwordHash,
            Optional<User> createdBy,
            Gender gender,
            Long department,
            AcademicLeader academicLeader
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
                UserRole.LECTURER,
                gender,
                department
        );
        this.academicLeader = academicLeader;
    }

    public Lecturer(User user, Long department, AcademicLeader academicLeader){
        super(user, department);
        user.setRole(UserRole.LECTURER);
        this.academicLeader = academicLeader;
    }

}
