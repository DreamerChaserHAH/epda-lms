package com.htetaung.lms.entity;

import jakarta.persistence.*;

import java.util.Optional;

@Entity
@Table(name="Lecturer")
@PrimaryKeyJoinColumn(name="user_id")
public class Lecturer extends Staff{
    @ManyToOne(optional = true)
    @JoinColumn(name = "academic_leader_in_charge", nullable = true, updatable = false)
    private AcademicLeader academicLeader;

    public Lecturer(){

    }

    public Lecturer(String username, String full_name, String passwordHash, Optional<User> createdBy, Long department, AcademicLeader academicLeader) {
        super(
                username,
                full_name,
                passwordHash,
                createdBy,
                Role.LECTURER,
                department
        );
        this.academicLeader = academicLeader;
    }

}
