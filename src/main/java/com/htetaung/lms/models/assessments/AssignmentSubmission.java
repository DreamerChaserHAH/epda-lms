package com.htetaung.lms.models.assessments;

import com.htetaung.lms.models.enums.FileFormats;
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
@PrimaryKeyJoinColumn(name="submission_id")
public class AssignmentSubmission extends Submission{

    @OneToMany(mappedBy = "assignmentSubmission", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<FileSubmitted> filesSubmitted = new ArrayList<>();

    public AssignmentSubmission(Submission submission, List<FileSubmitted> filesSubmitted){
        super(
                submission.getFeedback(),
                submission.getSubmittedBy()
        );
        this.filesSubmitted = filesSubmitted;
    }
}
