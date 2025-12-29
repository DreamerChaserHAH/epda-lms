package com.htetaung.lms.models.assessments;

import com.htetaung.lms.models.Student;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.HashMap;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class QuizSubmission extends Submission {

    @ElementCollection
    @CollectionTable(
            name = "quiz_submission_selected_options",
            joinColumns = @JoinColumn(name = "submission_id")
    )
    @MapKeyColumn(name = "question_id")
    @Column(name = "selected_option_index")
    private HashMap<Integer, Integer> selectedOptions = new HashMap<>();

    public QuizSubmission(Submission submission) {
        this.setSubmission_id(submission.getSubmission_id());
        this.setFeedback(submission.getFeedback());
        this.setSubmittedBy(submission.getSubmittedBy());
    }
}
