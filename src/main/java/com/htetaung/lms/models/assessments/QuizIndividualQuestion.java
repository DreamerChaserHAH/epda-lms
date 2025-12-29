package com.htetaung.lms.models.assessments;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "QuizIndividualQuestion")
public class QuizIndividualQuestion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="quiz_question_id")
    private Long quizQuestionId;

    @Column(name="question_text", nullable = false)
    public String questionText;

    @ElementCollection
    @CollectionTable(
            name = "quiz_question_options",
            joinColumns = @JoinColumn(name = "quiz_question_id")
    )
    @Column(name = "option_text")
    private List<String> options = new ArrayList<>();

    @Column(name = "correct_answer_index", nullable = false)
    private Integer correctAnswerIndex;
}
