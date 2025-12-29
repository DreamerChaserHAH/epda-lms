package com.htetaung.lms.models.assessments;

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

    public Feedback(String feedbackText, int score) {
        this.feedbackText = feedbackText;
        this.score = score;
    }
}
