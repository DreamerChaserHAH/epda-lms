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
@Table(name = "QuizQuestion")
public class QuizQuestion implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "question_id")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "assessment_id", nullable = false)
    private Assessment assessment;

    @NotNull
    @Column(nullable = false, columnDefinition = "TEXT")
    private String questionText;

    @NotNull
    @Column(name = "option_a", nullable = false, columnDefinition = "TEXT")
    private String optionA;

    @NotNull
    @Column(name = "option_b", nullable = false, columnDefinition = "TEXT")
    private String optionB;

    @Column(name = "option_c", columnDefinition = "TEXT")
    private String optionC;

    @Column(name = "option_d", columnDefinition = "TEXT")
    private String optionD;

    @NotNull
    @Column(name = "correct_answer", nullable = false, length = 1)
    private String correctAnswer; // A, B, C, or D

    @Column(name = "points", nullable = false)
    private Integer points = 1;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Date createdAt;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "updated_at", nullable = false)
    private Date updatedAt;

    public QuizQuestion() {
    }

    public QuizQuestion(Assessment assessment, String questionText, String optionA, 
                       String optionB, String optionC, String optionD, String correctAnswer, Integer points) {
        this.assessment = assessment;
        this.questionText = questionText;
        this.optionA = optionA;
        this.optionB = optionB;
        this.optionC = optionC;
        this.optionD = optionD;
        this.correctAnswer = correctAnswer;
        this.points = points != null ? points : 1;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
        updatedAt = new Date();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = new Date();
    }
}

