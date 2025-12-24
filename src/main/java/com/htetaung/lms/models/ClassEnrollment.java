package com.htetaung.lms.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.Date;

@Getter
@Setter
@Entity
@Table(name = "ClassEnrollment", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"class_id", "student_id"})
})
public class ClassEnrollment implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "enrollment_id")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "class_id", nullable = false)
    private ClassEntity classEntity;

    @ManyToOne(optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "enrolled_at", nullable = false, updatable = false)
    private Date enrolledAt;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    public ClassEnrollment() {
    }

    public ClassEnrollment(ClassEntity classEntity, User student) {
        this.classEntity = classEntity;
        this.student = student;
        this.isActive = true;
    }

    @PrePersist
    protected void onCreate() {
        enrolledAt = new Date();
        if (isActive == null) {
            isActive = true;
        }
    }
}

