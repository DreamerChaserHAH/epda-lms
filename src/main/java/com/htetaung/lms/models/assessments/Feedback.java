package com.htetaung.lms.models.assessments;

import com.htetaung.lms.models.Grading;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class Feedback {
    @Id
    @GeneratedValue(strategy = jakarta.persistence.GenerationType.IDENTITY)
    private Long feedbackId;

    @Column(length = 300, nullable = false, name = "feedback_text")
    private String feedbackText;

    @Column(nullable = false, name = "score")
    private int score; // e.g., score out of 100

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "grading_id")
    private Grading grading; // Grade category based on score

    public Feedback(String feedbackText, int score) {
        this.feedbackText = feedbackText;
        this.score = score;
    }

    public Feedback(String feedbackText, int score, Grading grading) {
        this.feedbackText = feedbackText;
        this.score = score;
        this.grading = grading;
    }
}
