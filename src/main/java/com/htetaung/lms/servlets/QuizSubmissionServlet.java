package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.SubmissionServiceFacade;
import com.htetaung.lms.exception.SubmissionException;
import com.htetaung.lms.models.dto.QuizSubmissionDTO;
import com.htetaung.lms.utils.MessageModal;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "quizSubmissionServlet", urlPatterns = {"/api/quiz-submissions"})
public class QuizSubmissionServlet extends HttpServlet {

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("QuizSubmissionServlet.doPost() called");

        try {
            // Get session info
            Long userId = (Long) request.getSession().getAttribute("userId");
            String username = (String) request.getSession().getAttribute("username");

            System.out.println("User ID: " + userId + ", Username: " + username);

            if (userId == null || username == null) {
                MessageModal.DisplayErrorMessage("User session expired. Please login again.", request);
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Get form parameters
            String assessmentIdStr = request.getParameter("assessmentId");
            String studentIdStr = request.getParameter("studentId");

            // Validate required fields
            if (assessmentIdStr == null || assessmentIdStr.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Assessment ID is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
                return;
            }

            if (studentIdStr == null || studentIdStr.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Student ID is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
                return;
            }

            // Parse parameters
            Long quizId = Long.parseLong(assessmentIdStr);
            Long studentId = Long.parseLong(studentIdStr);

            // Collect answers from form parameters
            // Format: question_{questionId} = selectedOptionIndex
            Map<Long, Integer> answers = new HashMap<>();
            Map<String, String[]> parameterMap = request.getParameterMap();

            for (String paramName : parameterMap.keySet()) {
                if (paramName.startsWith("question_")) {
                    try {
                        String questionIdStr = paramName.substring(9); // Remove "question_" prefix
                        Long questionId = Long.parseLong(questionIdStr);
                        Integer selectedOption = Integer.parseInt(request.getParameter(paramName));
                        answers.put(questionId, selectedOption);
                    } catch (NumberFormatException e) {
                        // Skip invalid parameters
                        continue;
                    }
                }
            }

            // Validate at least one answer
            if (answers.isEmpty()) {
                System.out.println("No answers found in request!");
                MessageModal.DisplayErrorMessage("You must answer at least one question", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=submit-assessment&assessmentId=" + assessmentIdStr);
                return;
            }

            System.out.println("Collected " + answers.size() + " answers: " + answers);

            // Submit quiz
            QuizSubmissionDTO submission = submissionServiceFacade.SubmitQuiz(
                    studentId,
                    quizId,
                    answers,
                    username
            );

            // Display success message with score
            String message = String.format("Quiz submitted successfully! Score: %d/%d (%d%%)",
                    submission.getCorrectAnswers(),
                    submission.getTotalQuestions(),
                    submission.getScore());
            MessageModal.DisplaySuccessMessage(message, request);

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid number format: " + e.getMessage(), request);
            e.printStackTrace();
        } catch (SubmissionException e) {
            MessageModal.DisplayErrorMessage("Submission failed: " + e.getMessage(), request);
            e.printStackTrace();
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Unexpected error: " + e.getMessage(), request);
            e.printStackTrace();
        }

        // Redirect back to assignments page
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
    }
}

