package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.assessments.AssignmentSubmission;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class AssignmentSubmissionDTO extends SubmissionDTO {
    private List<FileSubmittedDTO> filesSubmitted = new ArrayList<>();

    public AssignmentSubmissionDTO(AssignmentSubmission submission) {
        super(submission);
        if (submission.getFilesSubmitted() != null) {
            this.filesSubmitted = submission.getFilesSubmitted().stream()
                    .map(FileSubmittedDTO::new)
                    .toList();
        }
    }
}
