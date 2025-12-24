package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.Gender;
import com.htetaung.lms.models.enums.UserRole;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;
import java.util.Optional;
import java.util.UUID;

@Getter
@Setter
@Entity
@PrimaryKeyJoinColumn(name="user_id")
@Table(name="Student")
public class Student extends User {

    @Column(name = "student_id", unique = true, nullable = false)
    private String studentId;

    @Column(name="programme_id", nullable=false)
    private Long programmeId;

    public Student(){
        super();
        this.studentId = UUID.randomUUID().toString();
        this.setRole(UserRole.STUDENT);
    }

    public Student(
            String username,
            String full_name,
            Date dateOfBirth,
            String ic,
            String email,
            String phoneNumber,
            String address,
            String passwordHash,
            Optional<User> createdBy,
            Gender gender
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
            UserRole.STUDENT,
                gender
        );
        this.studentId = UUID.randomUUID().toString();
        this.programmeId = 0L;
    }

    public Student(User user, Long programmeId){
        super(user);
        user.setRole(UserRole.STUDENT);
        this.studentId = UUID.randomUUID().toString();
        this.programmeId = programmeId;
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
