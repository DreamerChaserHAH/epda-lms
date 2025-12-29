package com.htetaung.lms.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.Date;

@Getter
@Setter
@Entity
@Table(name = "Attendance", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"class_id", "student_id", "attendance_date"})
})
public class Attendance implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "attendance_id")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "class_id", nullable = false)
    private ClassEntity classEntity;

    @ManyToOne(optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @Temporal(TemporalType.DATE)
    @Column(name = "attendance_date", nullable = false)
    private Date attendanceDate;

    @Column(name = "status", nullable = false, length = 20)
    private String status; // PRESENT, ABSENT, LATE, EXCUSED

    @ManyToOne(optional = true)
    @JoinColumn(name = "marked_by_id", nullable = true)
    private User markedBy;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "marked_at", nullable = false)
    private Date markedAt;

    @Column(columnDefinition = "TEXT")
    private String notes;

    public Attendance() {
    }

    public Attendance(ClassEntity classEntity, User student, Date attendanceDate, String status, User markedBy) {
        this.classEntity = classEntity;
        this.student = student;
        this.attendanceDate = attendanceDate;
        this.status = status;
        this.markedBy = markedBy;
    }

    @PrePersist
    protected void onCreate() {
        if (markedAt == null) {
            markedAt = new Date();
        }
        if (status == null) {
            status = "ABSENT";
        }
    }
}

