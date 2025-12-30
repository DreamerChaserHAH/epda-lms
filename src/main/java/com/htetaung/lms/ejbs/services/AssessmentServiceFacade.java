package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.AssessmentFacade;
import com.htetaung.lms.ejbs.facades.AssignmentFacade;
import com.htetaung.lms.ejbs.facades.LecturerFacade;
import com.htetaung.lms.ejbs.facades.QuizFacade;
import com.htetaung.lms.exception.AssessmentException;
import com.htetaung.lms.exception.ClassException;
import com.htetaung.lms.exception.ModuleException;
import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.Lecturer;
import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.assessments.Assignment;
import com.htetaung.lms.models.assessments.Quiz;
import com.htetaung.lms.models.dto.AssessmentDTO;
import com.htetaung.lms.models.dto.ClassDTO;
import com.htetaung.lms.models.dto.LecturerDTO;
import com.htetaung.lms.models.dto.QuizDTO;
import com.htetaung.lms.models.enums.AssessmentType;
import com.htetaung.lms.models.enums.FileFormats;
import com.htetaung.lms.models.enums.Visibility;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Stateless
public class AssessmentServiceFacade {
    @EJB
    private AssessmentFacade assessmentFacade;

    @EJB
    private QuizFacade quizFacade;

    @EJB
    private AssignmentFacade assignmentFacade;

    @EJB
    private ClassServiceFacade classServiceFacade;

    @EJB
    private LecturerFacade lecturerFacade;

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    public void CreateAssessment(
            String assessmentName,
            String assessmentDescription,
            Long relatedClassId,
            Date deadline,
            AssessmentType assessmentType,
            Long lecturerId
    ) throws AssessmentException {
        try {
            ClassDTO classEntityDTO = classServiceFacade.GetClass(relatedClassId);
            if (classEntityDTO == null) {
                throw new AssessmentException("Class does not exist to create an assessment for!");
            }
            Class classEntity = classEntityDTO.toClass();
            Lecturer lecturer = lecturerFacade.find(lecturerId);
            if (lecturer == null) {
                throw new AssessmentException("Lecturer does not exist to create an assessment!");
            }

            switch (assessmentType) {
                case QUIZ -> {
                    Quiz quiz = new Quiz(
                            new Assessment(
                                assessmentName,
                                assessmentDescription,
                                    classEntity,
                                    deadline,
                                    assessmentType,
                                    lecturer,
                                    Visibility.PRIVATE,
                                    null
                            ),
                            Duration.ofMinutes(10)
                    );
                    quizFacade.create(quiz, lecturer.getUsername());
                }
                case ASSIGNMENT -> {

                    ArrayList<FileFormats> fileFormats = new ArrayList<>();
                    fileFormats.add(FileFormats.PDF);
                    Assignment assignment = new Assignment(
                            new Assessment(
                                    assessmentName,
                                    assessmentDescription,
                                    classEntity,
                                    deadline,
                                    assessmentType,
                                    lecturer,
                                    Visibility.PRIVATE,
                                    null
                            ),
                            1000,
                            fileFormats
                    );
                    assignmentFacade.create(assignment, lecturer.getUsername());
                }
                default -> throw new AssessmentException("Unsupported assessment type!");
            }
        } catch (ClassException | ModuleException e) {
            throw new AssessmentException(e.getMessage());
        } catch (Exception e) {
            throw new AssessmentException("Failed to create assessment: " + e.getMessage());
        }
    }

    public AssessmentDTO GetAssessment(Long assessmentId) throws AssessmentException {
        Assessment assessment = assessmentFacade.find(assessmentId);
        if (assessment == null){
            throw new AssessmentException("Assessment not found");
        } else {
            return new AssessmentDTO(assessment);
        }
    }

    public List<AssessmentDTO> ListAllAssessments() throws AssessmentException {
        List<Assessment> assessments = assessmentFacade.findAll();
        List<AssessmentDTO> assessmentDTOs = new ArrayList<>();
        for (Assessment assessment : assessments) {
            assessmentDTOs.add(new AssessmentDTO(assessment));
        }
        return assessmentDTOs;
    }
    public List<AssessmentDTO> ListAllAssessmentsInClass(Long classId) throws AssessmentException {
        return assessmentFacade.findAssessmentsInClass(classId);
    }

    public List<AssessmentDTO> ListVisibleAssessmentsForStudent(Long classId, Long studentId) throws AssessmentException {
        return assessmentFacade.findVisibleAssessmentsForStudent(classId, studentId);
    }

    public void UpdateAssessmentDetails(AssessmentDTO dto, Long classId, Long lecturerId, String operatedBy) throws AssessmentException {
        if (!assessmentFacade.assessmentExists(dto.getAssessmentId())) {
            throw new AssessmentException("Assessment not found");
        }

        try {
            // Validate class exists
            ClassDTO classEntityDTO = classServiceFacade.GetClass(classId);
            if (classEntityDTO == null) {
                throw new AssessmentException("Class does not exist to update an assessment for!");
            }

            // Validate lecturer exists
            Lecturer lecturer = lecturerFacade.find(lecturerId);
            if (lecturer == null) {
                throw new AssessmentException("Lecturer does not exist to update an assessment!");
            }

            // Get the existing assessment
            Assessment assessment = assessmentFacade.find(dto.getAssessmentId());

            // Update the assessment details
            assessment.setAssessmentName(dto.getAssessmentName());
            assessment.setAssessmentDescription(dto.getAssessmentDescription());
            assessment.setDeadline(dto.getDeadline());
            assessment.setAssessmentType(dto.getAssessmentType());
            assessment.setVisibility(dto.getVisibility());
            assessment.setRelatedClass(classEntityDTO.toClass());
            assessment.setCreatedBy(lecturer);

            // Persist changes
            assessmentFacade.edit(assessment, operatedBy);

        } catch (ClassException | ModuleException e) {
            throw new AssessmentException(e.getMessage());
        } catch (Exception e) {
            throw new AssessmentException("Failed to update assessment: " + e.getMessage());
        }
    }


    public void DeleteAssessment(Long assessmentId) throws AssessmentException {
        if (!assessmentFacade.assessmentExists(assessmentId)){
            throw new AssessmentException("Assessment not found");
        }
        assessmentFacade.deleteAssessment(assessmentId);
    }

    /**
     * Enrich assessment DTOs with submission information for a specific student
     */
    public List<AssessmentDTO> EnrichWithSubmissionInfo(List<AssessmentDTO> assessments, Long studentId) {
        for (AssessmentDTO assessment : assessments) {
            try {
                submissionServiceFacade.EnrichAssessmentWithSubmission(assessment, studentId);
            } catch (Exception e) {
                // If there's an error, just mark as not submitted
                assessment.setSubmission(null);
            }
        }
        return assessments;
    }
}
