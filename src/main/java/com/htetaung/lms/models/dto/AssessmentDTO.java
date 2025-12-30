package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.Lecturer;
import com.htetaung.lms.models.Student;
import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.enums.AssessmentType;
import com.htetaung.lms.models.enums.Visibility;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.Date;

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

    public AssessmentDTO(Assessment assessment) {
        this.assessmentId = assessment.getAssessmentId();
        this.assessmentName = assessment.getAssessmentName();
        this.assessmentDescription = assessment.getAssessmentDescription();
        this.relatedClass = new ClassDTO(assessment.getRelatedClass());
        this.deadline = assessment.getDeadline();
        this.assessmentType = assessment.getAssessmentType();
        this.createdBy = new LecturerDTO(assessment.getCreatedBy());
        this.visibility = assessment.getVisibility();
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
}
