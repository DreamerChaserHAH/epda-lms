package com.htetaung.lms.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.Date;

@Getter
@Setter
@Entity
@Table(name = "AssessmentSubmission")
public class AssessmentSubmission implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "submission_id")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "assessment_id", nullable = false)
    private Assessment assessment;

    @ManyToOne(optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @Column(name = "submission_content", columnDefinition = "TEXT")
    private String submissionContent;

    @Column(name = "file_name")
    private String fileName;

    @Column(name = "file_path")
    private String filePath;

    @Column(name = "marks")
    private Double marks;

    @Column(name = "max_marks")
    private Double maxMarks;

    @Column(name = "feedback", columnDefinition = "TEXT")
    private String feedback;

    @ManyToOne(optional = true)
    @JoinColumn(name = "graded_by_id", nullable = true)
    private User gradedBy;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "submitted_at", nullable = false)
    private Date submittedAt;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "graded_at")
    private Date gradedAt;

    @Column(name = "status", length = 20)
    private String status = "SUBMITTED"; // SUBMITTED, GRADED, RETURNED

    public AssessmentSubmission() {
    }

    public AssessmentSubmission(Assessment assessment, User student, String submissionContent) {
        this.assessment = assessment;
        this.student = student;
        this.submissionContent = submissionContent;
        this.submittedAt = new Date();
        this.status = "SUBMITTED";
    }

    @PrePersist
    protected void onCreate() {
        if (submittedAt == null) {
            submittedAt = new Date();
        }
        if (status == null) {
            status = "SUBMITTED";
        }
    }
}

