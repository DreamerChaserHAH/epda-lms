package com.htetaung.lms.models.assessments;

import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.assessments.QuizIndividualQuestion;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name="Quiz")
@PrimaryKeyJoinColumn(name="assessment_id")
public class Quiz extends Assessment {
    @Column(name="time_limit", nullable = false)
    private LocalDateTime timeLimit;

    @ManyToMany(cascade = CascadeType.ALL)
    @JoinTable(
            name = "QuizIndividualQuestion",
            joinColumns = @JoinColumn(name = "quiz_id"),
            inverseJoinColumns = @JoinColumn(name = "question_id")
    )
    private List<QuizIndividualQuestion> questions = new ArrayList<>();

    public Quiz(Assessment assessment, LocalDateTime timeLimit) {
        super(
                assessment.getAssessmentName(),
                assessment.getAssessmentDescription(),
                assessment.getRelatedClass(),
                assessment.getDeadline(),
                assessment.getAssessmentType(),
                assessment.getCreatedBy(),
                assessment.getVisibility(),
                assessment.getVisibleToStudents()
        );
        this.timeLimit = timeLimit;
    }
}
