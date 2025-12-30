package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.assessments.Submission;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
public class SubmissionDTO {
    private Long submissionId;
    private Long studentId;
    private String studentName;
    private String studentEmail;
    private Long feedbackId;
    private String feedbackText;
    private Integer score;
    private String gradeSymbol; // Grade category (A, B, C, etc.) or "UNCATEGORIZED"
    private Date submittedAt;
    private String gradingStatus; // "GRADED" or "PENDING"
    private Long assessmentId;
    private String assessmentTitle;

    public SubmissionDTO(Submission submission) {
        this.submissionId = submission.getSubmission_id();
        if (submission.getSubmittedBy() != null) {
            this.studentId = submission.getSubmittedBy().getUserId();
            this.studentName = submission.getSubmittedBy().getFullName();
            this.studentEmail = submission.getSubmittedBy().getEmail();
        }
        if (submission.getFeedback() != null) {
            this.feedbackId = submission.getFeedback().getFeedbackId();
            this.feedbackText = submission.getFeedback().getFeedbackText();
            this.score = submission.getFeedback().getScore();

            // Set grade symbol from Grading entity or "UNCATEGORIZED"
            if (submission.getFeedback().getGrading() != null) {
                this.gradeSymbol = submission.getFeedback().getGrading().getGradeSymbol();
            } else {
                this.gradeSymbol = "UNCATEGORIZED";
            }

            // If feedback text is not "Pending review" and score is set, consider it graded
            this.gradingStatus = (this.feedbackText != null &&
                                  !this.feedbackText.equals("Pending review") &&
                                  this.score != null && this.score >= 0) ? "GRADED" : "PENDING";
        } else {
            this.gradingStatus = "PENDING";
            this.gradeSymbol = "UNCATEGORIZED";
        }
        if (submission.getAssessment() != null) {
            this.assessmentId = submission.getAssessment().getAssessmentId();
            this.assessmentTitle = submission.getAssessment().getAssessmentName();
        }
        this.submittedAt = submission.getCreatedAt();
    }
}

