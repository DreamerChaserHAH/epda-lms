package com.htetaung.lms.models.assessments;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Access(AccessType.FIELD)
public class QuizSubmission extends Submission {

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(
            name = "quiz_submission_selected_options",
            joinColumns = @JoinColumn(name = "submission_id")
    )
    @MapKeyColumn(name = "question_id")
    @Column(name = "selected_option_index")
    private Map<Integer, Integer> selectedOptions;

    public QuizSubmission(Submission submission) {
        this.setSubmission_id(submission.getSubmission_id());
        this.setFeedback(submission.getFeedback());
        this.setSubmittedBy(submission.getSubmittedBy());
    }
}
