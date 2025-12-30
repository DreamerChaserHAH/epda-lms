package com.htetaung.lms.models.assessments;

import com.htetaung.lms.models.enums.AssessmentType;
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
@Table(name="Assignment")
@PrimaryKeyJoinColumn(name="assessment_id")
public class Assignment extends Assessment{

    @Column(name="number_of_files", nullable = false)
    private int number_of_files;

    @ElementCollection(targetClass = FileFormats.class, fetch = FetchType.EAGER)
    @CollectionTable(
            name = "assignment_allowed_formats",
            joinColumns = @JoinColumn(name = "assignment_id")
    )
    @Enumerated(EnumType.STRING)
    @Column(name = "file_format")
    private List<FileFormats> allowedFileFormat = new ArrayList<>();

    public Assignment(Assessment assessment, int number_of_files, List<FileFormats> allowedFileFormat) {
        super(
                assessment.getAssessmentName(),
                assessment.getAssessmentDescription(),
                assessment.getRelatedClass(),
                assessment.getDeadline(),
                AssessmentType.ASSIGNMENT,
                assessment.getCreatedBy(),
                assessment.getVisibility(),
                assessment.getVisibleToStudents()
        );
        this.number_of_files = number_of_files;
        this.allowedFileFormat = allowedFileFormat;
    }
}
