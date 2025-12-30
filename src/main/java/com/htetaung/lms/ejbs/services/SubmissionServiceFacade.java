package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.*;
import com.htetaung.lms.exception.SubmissionException;
import com.htetaung.lms.models.Grading;
import com.htetaung.lms.models.Student;
import com.htetaung.lms.models.assessments.*;
import com.htetaung.lms.models.dto.AssignmentSubmissionDTO;
import com.htetaung.lms.models.dto.QuizSubmissionDTO;
import com.htetaung.lms.models.dto.SubmissionDTO;
import com.htetaung.lms.models.dto.AssessmentDTO;
import com.htetaung.lms.models.enums.FileFormats;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Stateless
public class SubmissionServiceFacade {

    @EJB
    private SubmissionFacade submissionFacade;

    @EJB
    private AssignmentSubmissionFacade assignmentSubmissionFacade;

    @EJB
    private QuizSubmissionFacade quizSubmissionFacade;

    @EJB
    private FeedbackFacade feedbackFacade;

    @EJB
    private StudentFacade studentFacade;

    @EJB
    private QuizFacade quizFacade;

    @EJB
    private QuizIndividualQuestionFacade questionFacade;

    @EJB
    private AssessmentFacade assessmentFacade;

    @EJB
    private GradingFacade gradingFacade;

    // Base upload directory - adjust as needed
    private static final String UPLOAD_DIR = System.getProperty("user.home") + "/lms-uploads/assignments/";

    /**
     * Submit an assignment with file upload
     */
    public AssignmentSubmissionDTO SubmitAssignment(
            Long studentId,
            Long assessmentId,
            InputStream fileInputStream,
            String fileName,
            String comments,
            String operatedBy
    ) throws SubmissionException {

        try {
            // Validate student exists
            Student student = studentFacade.find(studentId);
            if (student == null) {
                throw new SubmissionException("Student not found with ID: " + studentId);
            }

            // Validate assessment exists
            Assessment assessment = assessmentFacade.find(assessmentId);
            if (assessment == null) {
                throw new SubmissionException("Assessment not found with ID: " + assessmentId);
            }

            // Check if already submitted
            Submission existingSubmission = submissionFacade.findByStudentAndAssessment(studentId, assessmentId);
            if (existingSubmission != null) {
                throw new SubmissionException("You have already submitted this assignment");
            }

            // Validate file
            if (fileInputStream == null || fileName == null || fileName.trim().isEmpty()) {
                throw new SubmissionException("File is required for assignment submission");
            }

            // Determine file format
            FileFormats fileFormat = determineFileFormat(fileName);

            // Create upload directory if it doesn't exist
            Path uploadPath = Paths.get(UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // Generate unique filename
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            Path filePath = uploadPath.resolve(uniqueFileName);

            // Save file to disk
            Files.copy(fileInputStream, filePath, StandardCopyOption.REPLACE_EXISTING);

            // Create initial feedback (no score yet)
            Feedback feedback = new Feedback(comments != null ? comments : "Pending review", 0);
            feedbackFacade.create(feedback, operatedBy);

            // Create submission with assessment reference
            Submission submission = new Submission(feedback, student, assessment);
            submissionFacade.create(submission, operatedBy);

            // Create file submitted record
            FileSubmitted fileSubmitted = new FileSubmitted();
            fileSubmitted.setFileName(fileName);
            fileSubmitted.setFileFormat(fileFormat);
            fileSubmitted.setFilePath(filePath.toString());

            // Create assignment submission
            List<FileSubmitted> files = new ArrayList<>();
            files.add(fileSubmitted);

            AssignmentSubmission assignmentSubmission = new AssignmentSubmission(submission, files);

            // Set bi-directional relationship
            fileSubmitted.setAssignmentSubmission(assignmentSubmission);

            assignmentSubmissionFacade.create(assignmentSubmission, operatedBy);

            return new AssignmentSubmissionDTO(assignmentSubmission);

        } catch (IOException e) {
            throw new SubmissionException("Failed to save file: " + e.getMessage(), e);
        } catch (Exception e) {
            throw new SubmissionException("Failed to submit assignment: " + e.getMessage(), e);
        }
    }

    /**
     * Submit a quiz with answers
     */
    public QuizSubmissionDTO SubmitQuiz(
            Long studentId,
            Long quizId,
            Map<Long, Integer> answers,
            String operatedBy
    ) throws SubmissionException {

        try {
            // Validate student exists
            Student student = studentFacade.find(studentId);
            if (student == null) {
                throw new SubmissionException("Student not found with ID: " + studentId);
            }

            // Validate quiz exists
            Quiz quiz = quizFacade.find(quizId);
            if (quiz == null) {
                throw new SubmissionException("Quiz not found with ID: " + quizId);
            }

            // Check if already submitted
            Submission existingSubmission = submissionFacade.findByStudentAndAssessment(studentId, quizId);
            if (existingSubmission != null) {
                throw new SubmissionException("You have already submitted this quiz");
            }

            // Validate answers
            if (answers == null || answers.isEmpty()) {
                throw new SubmissionException("At least one answer is required");
            }

            // Calculate score
            List<QuizIndividualQuestion> questions = quiz.getQuestions();
            int correctCount = 0;
            int totalQuestions = questions.size();

            HashMap<Integer, Integer> selectedOptions = new HashMap<>();

            for (QuizIndividualQuestion question : questions) {
                Long questionId = question.getQuizQuestionId();
                Integer selectedOption = answers.get(questionId);

                if (selectedOption != null) {
                    // Store as Integer for the HashMap
                    selectedOptions.put(questionId.intValue(), selectedOption);

                    // Check if answer is correct
                    if (selectedOption.equals(question.getCorrectAnswerIndex())) {
                        correctCount++;
                    }
                }
            }

            // Calculate percentage score
            int score = totalQuestions > 0 ? (correctCount * 100) / totalQuestions : 0;

            // Determine grade category based on score
            Grading grading = determineGrade(score);

            // Create feedback with score and grade
            String feedbackText = String.format("Quiz completed. Score: %d/%d (%d%%)",
                    correctCount, totalQuestions, score);
            Feedback feedback = new Feedback(feedbackText, score, grading);
            feedbackFacade.create(feedback, operatedBy);

            // Create quiz submission directly (extends Submission)
            QuizSubmission quizSubmission = new QuizSubmission();
            quizSubmission.setFeedback(feedback);
            quizSubmission.setSubmittedBy(student);
            quizSubmission.setAssessment(quiz);  // Set the assessment reference
            quizSubmission.setSelectedOptions(selectedOptions);

            // Persist quiz submission (includes base Submission fields)
            quizSubmissionFacade.create(quizSubmission, operatedBy);

            // Create DTO with results
            QuizSubmissionDTO dto = new QuizSubmissionDTO(quizSubmission);
            dto.setTotalQuestions(totalQuestions);
            dto.setCorrectAnswers(correctCount);

            return dto;

        } catch (Exception e) {
            throw new SubmissionException("Failed to submit quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Get submission by ID
     */
    public SubmissionDTO GetSubmission(Long submissionId) throws SubmissionException {
        Submission submission = submissionFacade.find(submissionId);
        if (submission == null) {
            throw new SubmissionException("Submission not found with ID: " + submissionId);
        }

        // Return specific DTO based on submission type
        if (submission instanceof QuizSubmission) {
            return new QuizSubmissionDTO((QuizSubmission) submission);
        } else if (submission instanceof AssignmentSubmission) {
            return new AssignmentSubmissionDTO((AssignmentSubmission) submission);
        }

        return new SubmissionDTO(submission);
    }

    /**
     * Get all submissions by student
     */
    public List<SubmissionDTO> GetSubmissionsByStudent(Long studentId) throws SubmissionException {
        List<Submission> submissions = submissionFacade.findByStudentId(studentId);
        return submissions.stream()
                .map(SubmissionDTO::new)
                .toList();
    }

    /**
     * Check if student has submitted for an assessment
     */
    public boolean HasSubmitted(Long studentId, Long assessmentId) {
        Submission submission = submissionFacade.findByStudentAndAssessment(studentId, assessmentId);
        return submission != null;
    }

    /**
     * Get all submissions for a specific assessment
     */
    public List<SubmissionDTO> GetSubmissionsByAssessment(Long assessmentId) {
        List<Submission> submissions = submissionFacade.findByAssessmentId(assessmentId);
        return submissions.stream()
                .map(submission -> {
                    if (submission instanceof QuizSubmission) {
                        return new QuizSubmissionDTO((QuizSubmission) submission);
                    } else if (submission instanceof AssignmentSubmission) {
                        return new AssignmentSubmissionDTO((AssignmentSubmission) submission);
                    }
                    return new SubmissionDTO(submission);
                })
                .toList();
    }

    /**
     * Enrich assessment DTO with submission information for a student
     */
    public void EnrichAssessmentWithSubmission(AssessmentDTO assessment, Long studentId) {
        Submission submission = submissionFacade.findByStudentAndAssessment(studentId, assessment.getAssessmentId());

        if (submission != null) {
            // Create SubmissionDTO and set it in the assessment
            SubmissionDTO submissionDTO = new SubmissionDTO(submission);
            assessment.setSubmission(submissionDTO);
        } else {
            // No submission found
            assessment.setSubmission(null);
        }
    }

    /**
     * Determine file format from filename
     */
    private FileFormats determineFileFormat(String fileName) throws SubmissionException {
        String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toUpperCase();
        try {
            return FileFormats.valueOf(extension);
        } catch (IllegalArgumentException e) {
            throw new SubmissionException("Unsupported file format: " + extension);
        }
    }

    /**
     * Determine grade category based on score
     * Returns null if no matching grade found (will be UNCATEGORIZED)
     */
    private Grading determineGrade(int score) {
        try {
            return gradingFacade.findByScore(score).orElse(null);
        } catch (Exception e) {
            // If error finding grade, return null
            return null;
        }
    }

    /**
     * Grade or update grade for a submission
     */
    public SubmissionDTO GradeSubmission(Long submissionId, Integer score, String feedbackText, String operatedBy) throws SubmissionException {
        try {
            Submission submission = submissionFacade.find(submissionId);
            if (submission == null) {
                throw new SubmissionException("Submission not found with ID: " + submissionId);
            }

            // Determine grade category based on score
            Grading grading = determineGrade(score);

            Feedback feedback = submission.getFeedback();
            if (feedback == null) {
                // Create new feedback if it doesn't exist
                feedback = new Feedback(feedbackText, score, grading);
                feedbackFacade.create(feedback, operatedBy);
                submission.setFeedback(feedback);
            } else {
                // Update existing feedback
                feedback.setFeedbackText(feedbackText);
                feedback.setScore(score);
                feedback.setGrading(grading);
                feedbackFacade.edit(feedback, operatedBy);
            }

            submissionFacade.edit(submission, operatedBy);

            // Return appropriate DTO type
            if (submission instanceof QuizSubmission) {
                return new QuizSubmissionDTO((QuizSubmission) submission);
            } else if (submission instanceof AssignmentSubmission) {
                return new AssignmentSubmissionDTO((AssignmentSubmission) submission);
            }

            return new SubmissionDTO(submission);

        } catch (Exception e) {
            throw new SubmissionException("Failed to grade submission: " + e.getMessage(), e);
        }
    }
}

