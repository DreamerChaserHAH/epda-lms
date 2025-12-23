package com.htetaung.lms.entity;

import jakarta.persistence.*;

import java.util.Optional;
import java.util.UUID;

@Entity
@PrimaryKeyJoinColumn(name="user_id")
@Table(name="Student")
public class Student extends User {

    @Column(name = "student_id", unique = true, nullable = false)
    private String studentId;

    @Column(name="programme_id", nullable=false)
    private Long programmeId;

    public Student(){

    }

    public Student(String username, String full_name, String passwordHash, Optional<User> createdBy) {
        super(
            username,
            full_name,
            passwordHash,
            createdBy,
            Role.STUDENT
        );
        this.studentId = UUID.randomUUID().toString();
        this.programmeId = 0L;
    }

    public String getStudentID() {
        return studentId;
    }

    public Long getProgrammeId(){
        return programmeId;
    }

    public void setProgrammeId(Long programmeId){
        this.programmeId = programmeId;
    }
}
