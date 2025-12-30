package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.assessments.QuizIndividualQuestion;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class QuizIndividualQuestionDTO {
    private Long quizQuestionId;
    private String questionText;
    private List<String> options = new ArrayList<>();
    private Integer correctAnswerIndex;

    public QuizIndividualQuestionDTO(QuizIndividualQuestion question) {
        this.quizQuestionId = question.getQuizQuestionId();
        this.questionText = question.getQuestionText();
        this.options = question.getOptions() != null ? new ArrayList<>(question.getOptions()) : new ArrayList<>();
        this.correctAnswerIndex = question.getCorrectAnswerIndex();
    }

    public QuizIndividualQuestionDTO(String questionText, List<String> options, Integer correctAnswerIndex) {
        this.questionText = questionText;
        this.options = options;
        this.correctAnswerIndex = correctAnswerIndex;
    }

    public QuizIndividualQuestion toEntity() {
        QuizIndividualQuestion question = new QuizIndividualQuestion();
        question.setQuizQuestionId(this.quizQuestionId);
        question.setQuestionText(this.questionText);
        question.setOptions(this.options);
        question.setCorrectAnswerIndex(this.correctAnswerIndex);
        return question;
    }
}

