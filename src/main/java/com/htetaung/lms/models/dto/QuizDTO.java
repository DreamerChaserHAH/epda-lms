package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.assessments.Assignment;
import com.htetaung.lms.models.assessments.Quiz;
import com.htetaung.lms.models.assessments.QuizIndividualQuestion;
import com.htetaung.lms.models.enums.FileFormats;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class QuizDTO {

    private AssessmentDTO assessmentDTO;
    private Duration timeLimit;
    private List<QuizIndividualQuestion> questions = new ArrayList<>();

    public QuizDTO(Quiz quiz) {
        this.assessmentDTO = new AssessmentDTO((Assessment) quiz);
        this.timeLimit = quiz.getTimeLimit();
        this.questions = quiz.getQuestions();
    }

    public Quiz toQuiz() {
        Quiz quiz = new Quiz();
        quiz.setAssessmentId(this.assessmentDTO.getAssessmentId());
        quiz.setAssessmentName(this.assessmentDTO.getAssessmentName());
        quiz.setAssessmentDescription(this.assessmentDTO.getAssessmentDescription());
        quiz.setRelatedClass(this.assessmentDTO.getRelatedClass().toClass());
        quiz.setDeadline(this.assessmentDTO.getDeadline());
        quiz.setAssessmentType(this.assessmentDTO.getAssessmentType());
        quiz.setCreatedBy(this.assessmentDTO.getCreatedBy().toLecturer());
        quiz.setVisibility(this.assessmentDTO.getVisibility());
        quiz.setTimeLimit(this.getTimeLimit());
        quiz.setQuestions(this.getQuestions());
        return quiz;
    }
}
