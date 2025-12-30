package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.assessments.QuizSubmission;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.HashMap;
import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
public class QuizSubmissionDTO extends SubmissionDTO {
    private Map<Integer, Integer> selectedOptions = new HashMap<>();
    private Integer totalQuestions;
    private Integer correctAnswers;

    public QuizSubmissionDTO(QuizSubmission submission) {
        super(submission);
        if (submission.getSelectedOptions() != null) {
            this.selectedOptions = new HashMap<>(submission.getSelectedOptions());
            this.totalQuestions = submission.getSelectedOptions().size();
        }
    }
}

