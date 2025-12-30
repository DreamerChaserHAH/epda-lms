package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.Lecturer;
import com.htetaung.lms.models.Student;
import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.assessments.Assignment;
import com.htetaung.lms.models.enums.AssessmentType;
import com.htetaung.lms.models.enums.FileFormats;
import com.htetaung.lms.models.enums.Visibility;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class AssessmentDTO {
    private Long assessmentId;
    private String assessmentName;
    private String assessmentDescription;
    private ClassDTO relatedClass;
    private Date deadline;
    private AssessmentType assessmentType;
    private LecturerDTO createdBy;
    private Visibility visibility;

    // Assignment-specific fields
    private List<FileFormats> allowedFileFormats; // For assignments only

    // Submission tracking for student view
    private SubmissionDTO submission;

    public AssessmentDTO(Assessment assessment) {
        this.assessmentId = assessment.getAssessmentId();
        this.assessmentName = assessment.getAssessmentName();
        this.assessmentDescription = assessment.getAssessmentDescription();
        this.relatedClass = new ClassDTO(assessment.getRelatedClass());
        this.deadline = assessment.getDeadline();
        this.assessmentType = assessment.getAssessmentType();
        this.createdBy = new LecturerDTO(assessment.getCreatedBy());
        this.visibility = assessment.getVisibility();

        // Populate allowed file formats if this is an Assignment
        if (assessment instanceof Assignment) {
            Assignment assignment = (Assignment) assessment;
            this.allowedFileFormats = assignment.getAllowedFileFormat();
        }
    }

    public Assessment toAssessment(){
        Assessment assessment = new Assessment();
        assessment.setAssessmentId(this.assessmentId);
        assessment.setAssessmentName(this.assessmentName);
        assessment.setAssessmentDescription(this.assessmentDescription);
        assessment.setRelatedClass(this.relatedClass.toClass());
        assessment.setDeadline(this.deadline);
        assessment.setAssessmentType(this.assessmentType);
        assessment.setCreatedBy(this.createdBy.toLecturer());
        assessment.setVisibility(this.visibility);
        assessment.setVisibleToStudents(new ArrayList<>());
        return assessment;
    }

    /**
     * Convenience method to check if student has submitted
     */
    public boolean isHasSubmitted() {
        return submission != null;
    }

    /**
     * Convenience method to get submission ID
     */
    public Long getSubmissionId() {
        return submission != null ? submission.getSubmissionId() : null;
    }

    /**
     * Convenience method to get score
     */
    public Integer getScore() {
        return submission != null ? submission.getScore() : null;
    }

    /**
     * Convenience method to get feedback text
     */
    public String getFeedbackText() {
        return submission != null ? submission.getFeedbackText() : null;
    }

    /**
     * Convenience method to get grade symbol
     */
    public String getGradeSymbol() {
        return submission != null ? submission.getGradeSymbol() : "UNCATEGORIZED";
    }
}
