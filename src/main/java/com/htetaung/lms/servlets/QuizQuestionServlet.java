package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.QuizQuestionServiceFacade;
import com.htetaung.lms.exception.QuizQuestionException;
import com.htetaung.lms.models.dto.QuizIndividualQuestionDTO;
import com.htetaung.lms.utils.MessageModal;
import com.htetaung.lms.utils.RequestParameterProcessor;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "quizQuestionServlet", urlPatterns = {"/api/quiz-questions"})
public class QuizQuestionServlet extends HttpServlet {

    @EJB
    private QuizQuestionServiceFacade quizQuestionServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String includingPage = (String) request.getAttribute("includingPage");
        String questionIdString = RequestParameterProcessor.getStringValue("questionId", request, null);
        String quizIdString = RequestParameterProcessor.getStringValue("quizId", request, null);

        try {
            // Get single question by ID
            if (questionIdString != null && !questionIdString.isEmpty()) {
                Long questionId = Long.parseLong(questionIdString);
                QuizIndividualQuestionDTO question = quizQuestionServiceFacade.GetQuestion(questionId);
                request.setAttribute("question", question);
                MessageModal.DisplaySuccessMessage("Question loaded successfully", request);

            }
            // Get all questions for a quiz
            else if (quizIdString != null && !quizIdString.isEmpty()) {
                Long quizId = Long.parseLong(quizIdString);
                List<QuizIndividualQuestionDTO> questions = quizQuestionServiceFacade.GetQuestionsForQuiz(quizId);
                request.setAttribute("questions", questions);
                MessageModal.DisplaySuccessMessage("Questions loaded successfully", request);

            } else {
                MessageModal.DisplayErrorMessage("Quiz ID or Question ID is required", request);
            }

            // Forward to including page if specified
            if (includingPage != null && !includingPage.isEmpty()) {
                request.getRequestDispatcher(includingPage).include(request, response);
            }

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid ID format", request);
        } catch (QuizQuestionException e) {
            MessageModal.DisplayErrorMessage("Error: " + e.getMessage(), request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Unexpected error: " + e.getMessage(), request);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get userId from session
            Long userId = (Long) request.getSession().getAttribute("userId");
            String username = (String) request.getSession().getAttribute("username");

            if (userId == null || username == null) {
                MessageModal.DisplayErrorMessage("User session expired. Please login again.", request);
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Get form parameters
            String assessmentIdStr = request.getParameter("assessmentId");
            String questionText = request.getParameter("questionText");
            String correctAnswerIndexStr = request.getParameter("correctAnswerIndex");

            // Get options (option0, option1, option2, option3)
            List<String> options = new ArrayList<>();
            for (int i = 0; i < 4; i++) {
                String option = request.getParameter("option" + i);
                if (option != null && !option.trim().isEmpty()) {
                    options.add(option.trim());
                }
            }

            // Validate required fields
            if (assessmentIdStr == null || assessmentIdStr.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Assessment ID is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&assessmentId=" + assessmentIdStr);
                return;
            }

            if (questionText == null || questionText.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Question text is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&assessmentId=" + assessmentIdStr);
                return;
            }

            if (options.isEmpty()) {
                MessageModal.DisplayErrorMessage("At least one option is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&assessmentId=" + assessmentIdStr);
                return;
            }

            if (correctAnswerIndexStr == null || correctAnswerIndexStr.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Correct answer must be selected", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&assessmentId=" + assessmentIdStr);
                return;
            }

            // Parse parameters
            Long assessmentId = Long.parseLong(assessmentIdStr);
            Integer correctAnswerIndex = Integer.parseInt(correctAnswerIndexStr);

            // Create question
            QuizIndividualQuestionDTO createdQuestion = quizQuestionServiceFacade.CreateQuestion(
                    assessmentId,
                    questionText,
                    options,
                    correctAnswerIndex,
                    username
            );

            MessageModal.DisplaySuccessMessage("Quiz question created successfully!", request);

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid number format: " + e.getMessage(), request);
        } catch (QuizQuestionException e) {
            MessageModal.DisplayErrorMessage("Failed to create question: " + e.getMessage(), request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Unexpected error: " + e.getMessage(), request);
        }

        // Redirect back to assessment details
        String assessmentId = request.getParameter("assessmentId");
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&assessmentId=" + assessmentId);
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get userId from session
            String username = (String) request.getSession().getAttribute("username");
            if (username == null) {
                MessageModal.DisplayErrorMessage("User session expired. Please login again.", request);
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Get form parameters
            String questionIdStr = request.getParameter("questionId");
            String questionText = request.getParameter("questionText");
            String correctAnswerIndexStr = request.getParameter("correctAnswerIndex");
            String assessmentIdStr = request.getParameter("assessmentId");

            // Get options
            List<String> options = new ArrayList<>();
            for (int i = 0; i < 4; i++) {
                String option = request.getParameter("option" + i);
                if (option != null && !option.trim().isEmpty()) {
                    options.add(option.trim());
                }
            }

            // Validate required fields
            if (questionIdStr == null || questionIdStr.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Question ID is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&assessmentId=" + assessmentIdStr);
                return;
            }

            // Parse parameters
            Long questionId = Long.parseLong(questionIdStr);
            Integer correctAnswerIndex = Integer.parseInt(correctAnswerIndexStr);

            // Update question
            quizQuestionServiceFacade.UpdateQuestion(
                    questionId,
                    questionText,
                    options,
                    correctAnswerIndex,
                    username
            );

            MessageModal.DisplaySuccessMessage("Quiz question updated successfully!", request);

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid number format: " + e.getMessage(), request);
        } catch (QuizQuestionException e) {
            MessageModal.DisplayErrorMessage("Failed to update question: " + e.getMessage(), request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Unexpected error: " + e.getMessage(), request);
        }

        String assessmentId = request.getParameter("assessmentId");
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&assessmentId=" + assessmentId);
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get userId from session
            String username = (String) request.getSession().getAttribute("username");
            if (username == null) {
                MessageModal.DisplayErrorMessage("User session expired. Please login again.", request);
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Get question ID
            String questionIdStr = request.getParameter("questionId");
            String assessmentIdStr = request.getParameter("assessmentId");

            if (questionIdStr == null || questionIdStr.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Question ID is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&assessmentId=" + assessmentIdStr);
                return;
            }

            Long questionId = Long.parseLong(questionIdStr);

            // Delete question
            quizQuestionServiceFacade.DeleteQuestion(questionId, username);

            MessageModal.DisplaySuccessMessage("Quiz question deleted successfully!", request);

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid question ID format", request);
        } catch (QuizQuestionException e) {
            MessageModal.DisplayErrorMessage("Failed to delete question: " + e.getMessage(), request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Unexpected error: " + e.getMessage(), request);
        }

        String assessmentId = request.getParameter("assessmentId");
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&assessmentId=" + assessmentId);
    }
}

