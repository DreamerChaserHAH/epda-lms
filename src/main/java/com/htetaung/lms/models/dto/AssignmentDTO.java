package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.assessments.Assignment;
import com.htetaung.lms.models.enums.FileFormats;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class AssignmentDTO {

    private AssessmentDTO assessmentDTO;
    private int number_of_files;
    private List<FileFormats> fileFormats;

    public AssignmentDTO(Assignment assignment) {
        this.assessmentDTO = new AssessmentDTO((Assessment) assignment);
        this.number_of_files = assignment.getNumber_of_files();
        this.fileFormats = assignment.getAllowedFileFormat();
    }

    public Assignment toAssignment() {
        Assignment assignment = new Assignment();
        assignment.setAssessmentId(this.assessmentDTO.getAssessmentId());
        assignment.setAssessmentName(this.assessmentDTO.getAssessmentName());
        assignment.setAssessmentDescription(this.assessmentDTO.getAssessmentDescription());
        assignment.setRelatedClass(this.assessmentDTO.getRelatedClass().toClass());
        assignment.setDeadline(this.assessmentDTO.getDeadline());
        assignment.setAssessmentType(this.assessmentDTO.getAssessmentType());
        assignment.setCreatedBy(this.assessmentDTO.getCreatedBy().toLecturer());
        assignment.setVisibility(this.assessmentDTO.getVisibility());
        assignment.setNumber_of_files(this.number_of_files);
        assignment.setAllowedFileFormat(this.fileFormats);
        return assignment;
    }
}
