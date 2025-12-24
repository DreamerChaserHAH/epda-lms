package com.htetaung.lms.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.Date;

@Getter
@Setter
@Entity
@Table(name = "QuizAnswer")
public class QuizAnswer implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "answer_id")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "question_id", nullable = false)
    private QuizQuestion question;

    @ManyToOne(optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @Column(name = "selected_answer", length = 1)
    private String selectedAnswer; // A, B, C, or D

    @Column(name = "is_correct")
    private Boolean isCorrect;

    @Column(name = "points_earned")
    private Integer pointsEarned = 0;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "answered_at", nullable = false)
    private Date answeredAt;

    public QuizAnswer() {
    }

    public QuizAnswer(QuizQuestion question, User student, String selectedAnswer) {
        this.question = question;
        this.student = student;
        this.selectedAnswer = selectedAnswer;
        this.answeredAt = new Date();
        // Calculate if answer is correct
            this.isCorrect = question != null && question.getCorrectAnswer() != null && 
                            question.getCorrectAnswer().equalsIgnoreCase(selectedAnswer);
            this.pointsEarned = this.isCorrect && question != null ? question.getPoints() : 0;
    }

    @PrePersist
    protected void onCreate() {
        if (answeredAt == null) {
            answeredAt = new Date();
        }
        // Recalculate correctness if not set
        if (isCorrect == null && question != null && selectedAnswer != null && 
            question.getCorrectAnswer() != null) {
            isCorrect = question.getCorrectAnswer().equalsIgnoreCase(selectedAnswer);
            pointsEarned = isCorrect ? question.getPoints() : 0;
        }
    }
}

