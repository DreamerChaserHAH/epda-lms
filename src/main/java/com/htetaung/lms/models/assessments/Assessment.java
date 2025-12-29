package com.htetaung.lms.models.assessments;

import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.Lecturer;
import com.htetaung.lms.models.Student;
import com.htetaung.lms.models.enums.AssessmentType;
import com.htetaung.lms.models.enums.Visibility;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
@Table(name="Assessment")
public class Assessment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="assessment_id")
    private Long assessmentId;

    @Column(name="assessment_name", nullable = false)
    private String assessmentName;

    @Column(name="assessment_description", nullable = true)
    private String assessmentDescription;

    @ManyToOne
    @JoinColumn(name="related_class_id", nullable = false)
    private Class relatedClass;

    @Column(name="deadline", nullable = false)
    private Date deadline;

    @Enumerated(EnumType.STRING)
    @Column(name="assessment_type", nullable = false)
    private AssessmentType assessmentType;

    @ManyToOne
    @JoinColumn(name="created_by_id", nullable = false)
    private Lecturer createdBy;

    @Enumerated(EnumType.STRING)
    @Column(name="visibility", nullable = false)
    private Visibility visibility;

    @ManyToMany
    @JoinTable(
            name = "assessment_visibility",
            joinColumns = @JoinColumn(name = "assessment_id"),
            inverseJoinColumns = @JoinColumn(name = "student_id")
    )
    private List<Student> visibleToStudents; /// can be empty if visibility is PUBLIC
    public Assessment(
            String assessmentName,
            String assessmentDescription,
            Class relatedClass,
            Date deadline,
            AssessmentType assessmentType,
            Lecturer createdBy,
            Visibility visibility,
            List<Student> visibleToStudents
    ) {
        this.assessmentName = assessmentName;
        this.assessmentDescription = assessmentDescription;
        this.relatedClass = relatedClass;
        this.deadline = deadline;
        this.assessmentType = assessmentType;
        this.createdBy = createdBy;
        this.visibility = visibility;
        this.visibleToStudents = visibleToStudents;
    }
}
