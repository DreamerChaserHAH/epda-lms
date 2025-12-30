package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.QuizSessionBean;
import com.htetaung.lms.ejbs.services.AssessmentServiceFacade;
import com.htetaung.lms.ejbs.services.QuizQuestionServiceFacade;
import com.htetaung.lms.ejbs.services.SubmissionServiceFacade;
import com.htetaung.lms.models.dto.AssessmentDTO;
import com.htetaung.lms.models.dto.QuizIndividualQuestionDTO;
import com.htetaung.lms.utils.MessageModal;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "quizTakingServlet", urlPatterns = {"/api/take-quiz"})
public class QuizTakingServlet extends HttpServlet {

    @EJB
    private AssessmentServiceFacade assessmentServiceFacade;

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    @EJB
    private QuizQuestionServiceFacade quizQuestionServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        Long assessmentId = parseLong(request.getParameter("assessmentId"));

        if (assessmentId == null) {
            MessageModal.DisplayErrorMessage("Assessment ID is required", request);
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
            return;
        }

        // Get or create quiz session bean
        QuizSessionBean quizSession = (QuizSessionBean) session.getAttribute("quizSession");

        try {
            if ("start".equals(action) || quizSession == null || !quizSession.isQuizInitialized()) {
                // Initialize new quiz session
                startQuiz(request, response, session, assessmentId);
            } else if ("next".equals(action)) {
                // Save current answer and move to next
                saveAnswerAndNavigate(request, quizSession, true);
                // Redirect to render full page with CSS
                response.sendRedirect(request.getContextPath() + "/api/take-quiz?assessmentId=" + assessmentId);
            } else if ("previous".equals(action)) {
                // Save current answer and move to previous
                saveAnswerAndNavigate(request, quizSession, false);
                // Redirect to render full page with CSS
                response.sendRedirect(request.getContextPath() + "/api/take-quiz?assessmentId=" + assessmentId);
            } else if ("goto".equals(action)) {
                // Jump to specific question
                int questionIndex = parseInt(request.getParameter("questionIndex"), 0);
                saveCurrentAnswer(request, quizSession);
                quizSession.moveToQuestion(questionIndex);
                // Redirect to render full page with CSS
                response.sendRedirect(request.getContextPath() + "/api/take-quiz?assessmentId=" + assessmentId);
            } else if ("review".equals(action)) {
                // Show review page before submission
                saveCurrentAnswer(request, quizSession);
                request.setAttribute("quizSession", quizSession);
                loadAssessmentForDisplay(request, assessmentId);
                request.getRequestDispatcher("/WEB-INF/views/student/quiz-review.jsp").forward(request, response);
            } else {
                // Default: show current question (full page render)
                loadAssessmentForDisplay(request, assessmentId);
                request.getRequestDispatcher("/WEB-INF/views/student/take-quiz.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            MessageModal.DisplayErrorMessage("Error loading quiz: " + e.getMessage(), request);
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        QuizSessionBean quizSession = (QuizSessionBean) session.getAttribute("quizSession");

        if (quizSession == null || !quizSession.isQuizInitialized()) {
            MessageModal.DisplayErrorMessage("Quiz session expired. Please start again.", request);
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
            return;
        }

        try {
            if ("submit".equals(action)) {
                // Final submission
                submitQuiz(request, response, session, quizSession);
            } else {
                // Handle other POST actions
                doGet(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            MessageModal.DisplayErrorMessage("Error processing quiz: " + e.getMessage(), request);
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
        }
    }

    private void startQuiz(HttpServletRequest request, HttpServletResponse response,
                          HttpSession session, Long assessmentId) throws Exception {
        Long studentId = (Long) session.getAttribute("userId");

        // Check if already submitted
        boolean alreadySubmitted = submissionServiceFacade.HasSubmitted(studentId, assessmentId);
        if (alreadySubmitted) {
            MessageModal.DisplayErrorMessage("You have already submitted this quiz", request);
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
            return;
        }

        // Get quiz questions
        List<QuizIndividualQuestionDTO> questions = quizQuestionServiceFacade.GetQuestionsForQuiz(assessmentId);

        if (questions == null || questions.isEmpty()) {
            MessageModal.DisplayErrorMessage("This quiz has no questions", request);
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
            return;
        }

        // Create new quiz session
        QuizSessionBean quizSession = new QuizSessionBean();
        quizSession.initializeQuiz(assessmentId, studentId, questions);

        // Store in session
        session.setAttribute("quizSession", quizSession);

        // Get assessment details for display
        AssessmentDTO assessment = assessmentServiceFacade.GetAssessment(assessmentId);
        request.setAttribute("assessment", assessment);

        // Check if this is an included request
        String includingPage = (String) request.getAttribute("includingPage");
        if (includingPage != null) {
            // Include the quiz page for rendering within the parent page
            request.getRequestDispatcher("/WEB-INF/views/student/take-quiz.jsp").include(request, response);
        } else {
            // Forward to quiz page
            request.getRequestDispatcher("/WEB-INF/views/student/take-quiz.jsp").forward(request, response);
        }
    }

    private void saveAnswerAndNavigate(HttpServletRequest request, QuizSessionBean quizSession, boolean moveNext) {
        saveCurrentAnswer(request, quizSession);

        if (moveNext) {
            quizSession.moveToNextQuestion();
        } else {
            quizSession.moveToPreviousQuestion();
        }
    }

    private void saveCurrentAnswer(HttpServletRequest request, QuizSessionBean quizSession) {
        String answerStr = request.getParameter("selectedOption");
        if (answerStr != null && !answerStr.isEmpty()) {
            try {
                int selectedOption = Integer.parseInt(answerStr);
                quizSession.answerCurrentQuestion(selectedOption);
            } catch (NumberFormatException e) {
                // Invalid answer format, skip
            }
        }
    }

    private void submitQuiz(HttpServletRequest request, HttpServletResponse response,
                           HttpSession session, QuizSessionBean quizSession) throws Exception {
        // Save final answer if provided
        saveCurrentAnswer(request, quizSession);

        Long studentId = (Long) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        Long assessmentId = quizSession.getAssessmentId();
        Map<Long, Integer> answers = quizSession.getAllAnswers();

        // Submit quiz through service
        submissionServiceFacade.SubmitQuiz(studentId, assessmentId, answers, username);

        // Clean up session
        quizSession.completeQuiz();
        session.removeAttribute("quizSession");

        // Redirect to results
        MessageModal.DisplaySuccessMessage("Quiz submitted successfully!", request);
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=results");
    }

    private void loadAssessmentForDisplay(HttpServletRequest request, Long assessmentId) throws Exception {
        AssessmentDTO assessment = assessmentServiceFacade.GetAssessment(assessmentId);
        request.setAttribute("assessment", assessment);
    }

    private Long parseLong(String value) {
        if (value == null || value.isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parseInt(String value, int defaultValue) {
        if (value == null || value.isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}

