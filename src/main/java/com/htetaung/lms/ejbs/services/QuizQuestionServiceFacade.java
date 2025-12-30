package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.QuizFacade;
import com.htetaung.lms.ejbs.facades.QuizIndividualQuestionFacade;
import com.htetaung.lms.exception.QuizQuestionException;
import com.htetaung.lms.models.assessments.Quiz;
import com.htetaung.lms.models.assessments.QuizIndividualQuestion;
import com.htetaung.lms.models.dto.QuizIndividualQuestionDTO;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import java.util.ArrayList;
import java.util.List;

@Stateless
public class QuizQuestionServiceFacade {

    @EJB
    private QuizFacade quizFacade;

    @EJB
    private QuizIndividualQuestionFacade questionFacade;

    public QuizIndividualQuestionDTO CreateQuestion(
            Long quizId,
            String questionText,
            List<String> options,
            Integer correctAnswerIndex,
            String operatedBy
    ) throws QuizQuestionException {

        // Validate quiz exists
        Quiz quiz = quizFacade.find(quizId);
        if (quiz == null) {
            throw new QuizQuestionException("Quiz not found with ID: " + quizId);
        }

        // Validate question text
        if (questionText == null || questionText.trim().isEmpty()) {
            throw new QuizQuestionException("Question text cannot be empty");
        }

        // Validate options
        if (options == null || options.size() < 2) {
            throw new QuizQuestionException("At least 2 options are required");
        }

        for (String option : options) {
            if (option == null || option.trim().isEmpty()) {
                throw new QuizQuestionException("Option text cannot be empty");
            }
        }

        // Validate correct answer index
        if (correctAnswerIndex == null || correctAnswerIndex < 0 || correctAnswerIndex >= options.size()) {
            throw new QuizQuestionException("Invalid correct answer index");
        }

        try {
            // Create the question
            QuizIndividualQuestion question = new QuizIndividualQuestion();
            question.setQuestionText(questionText);
            question.setOptions(new ArrayList<>(options));
            question.setCorrectAnswerIndex(correctAnswerIndex);

            // Add question to quiz first (don't persist question separately)
            if (quiz.getQuestions() == null) {
                quiz.setQuestions(new ArrayList<>());
            }
            quiz.getQuestions().add(question);

            // Persist the quiz - cascade will persist the question with correct assessment_id
            quizFacade.edit(quiz, operatedBy);

            return new QuizIndividualQuestionDTO(question);

        } catch (Exception e) {
            throw new QuizQuestionException("Failed to create question: " + e.getMessage(), e);
        }
    }

    public List<QuizIndividualQuestionDTO> GetQuestionsForQuiz(Long quizId) throws QuizQuestionException {
        // Validate quiz exists
        Quiz quiz = quizFacade.find(quizId);
        if (quiz == null) {
            throw new QuizQuestionException("Quiz not found with ID: " + quizId);
        }

        try {
            List<QuizIndividualQuestion> questions = quiz.getQuestions();
            if (questions == null || questions.isEmpty()) {
                return new ArrayList<>();
            }

            return questions.stream()
                    .map(QuizIndividualQuestionDTO::new)
                    .toList();

        } catch (Exception e) {
            throw new QuizQuestionException("Failed to retrieve questions: " + e.getMessage(), e);
        }
    }

    public QuizIndividualQuestionDTO GetQuestion(Long questionId) throws QuizQuestionException {
        QuizIndividualQuestion question = questionFacade.find(questionId);
        if (question == null) {
            throw new QuizQuestionException("Question not found with ID: " + questionId);
        }
        return new QuizIndividualQuestionDTO(question);
    }

    public void UpdateQuestion(
            Long questionId,
            String questionText,
            List<String> options,
            Integer correctAnswerIndex,
            String operatedBy
    ) throws QuizQuestionException {

        // Validate question exists
        QuizIndividualQuestion question = questionFacade.find(questionId);
        if (question == null) {
            throw new QuizQuestionException("Question not found with ID: " + questionId);
        }

        // Validate question text
        if (questionText == null || questionText.trim().isEmpty()) {
            throw new QuizQuestionException("Question text cannot be empty");
        }

        // Validate options
        if (options == null || options.size() < 2) {
            throw new QuizQuestionException("At least 2 options are required");
        }

        for (String option : options) {
            if (option == null || option.trim().isEmpty()) {
                throw new QuizQuestionException("Option text cannot be empty");
            }
        }

        // Validate correct answer index
        if (correctAnswerIndex == null || correctAnswerIndex < 0 || correctAnswerIndex >= options.size()) {
            throw new QuizQuestionException("Invalid correct answer index");
        }

        try {
            question.setQuestionText(questionText);
            question.setOptions(new ArrayList<>(options));
            question.setCorrectAnswerIndex(correctAnswerIndex);

            questionFacade.edit(question, operatedBy);

        } catch (Exception e) {
            throw new QuizQuestionException("Failed to update question: " + e.getMessage(), e);
        }
    }

    public void DeleteQuestion(Long questionId, String operatedBy) throws QuizQuestionException {
        // Validate question exists
        QuizIndividualQuestion question = questionFacade.find(questionId);
        if (question == null) {
            throw new QuizQuestionException("Question not found with ID: " + questionId);
        }

        try {
            // Remove question from any quiz that contains it
            List<Quiz> allQuizzes = quizFacade.findAll();
            for (Quiz quiz : allQuizzes) {
                if (quiz.getQuestions() != null && quiz.getQuestions().contains(question)) {
                    quiz.getQuestions().remove(question);
                    quizFacade.edit(quiz, operatedBy);
                }
            }

            // Delete the question
            questionFacade.remove(question, operatedBy);

        } catch (Exception e) {
            throw new QuizQuestionException("Failed to delete question: " + e.getMessage(), e);
        }
    }
}

