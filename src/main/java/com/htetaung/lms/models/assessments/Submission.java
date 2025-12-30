package com.htetaung.lms.models.assessments;

import com.htetaung.lms.models.Grading;
import com.htetaung.lms.models.Student;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
@Table(name = "Submission")
public class Submission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="submission_id")
    private Long submission_id;

    @OneToOne(cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    @JoinColumn(name = "feedback_id")
    private Feedback feedback;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student submittedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assessment_id", nullable = false)
    private Assessment assessment;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Date createdAt;


    public Submission(Feedback feedback, Student submittedBy) {
        this.submission_id = submission_id;
        this.feedback = feedback;
        this.submittedBy = submittedBy;
    }

    public Submission(Feedback feedback, Student submittedBy, Assessment assessment) {
        this.feedback = feedback;
        this.submittedBy = submittedBy;
        this.assessment = assessment;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
    }
}
