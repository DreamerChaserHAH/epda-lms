package com.htetaung.lms.models.assessments;

import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.assessments.QuizIndividualQuestion;
import com.htetaung.lms.models.enums.AssessmentType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Duration;
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
    private Duration timeLimit;

    @ManyToMany(cascade = CascadeType.ALL)
    @JoinTable(
            name = "quiz_questions",
            joinColumns = @JoinColumn(name = "assessment_id"),
            inverseJoinColumns = @JoinColumn(name = "quiz_question_id")
    )
    private List<QuizIndividualQuestion> questions = new ArrayList<>();

    public Quiz(Assessment assessment, Duration timeLimit) {
        super(
                assessment.getAssessmentName(),
                assessment.getAssessmentDescription(),
                assessment.getRelatedClass(),
                assessment.getDeadline(),
                AssessmentType.QUIZ,
                assessment.getCreatedBy(),
                assessment.getVisibility(),
                assessment.getVisibleToStudents()
        );
        this.timeLimit = timeLimit;
    }
}
