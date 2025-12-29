package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.QuizAnswerFacade;
import com.htetaung.lms.ejbs.facades.QuizQuestionFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.models.QuizAnswer;
import com.htetaung.lms.models.QuizQuestion;
import com.htetaung.lms.models.User;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "quizAnswerServlet", urlPatterns = {"/api/quiz-answers/*"})
public class QuizAnswerServlet extends HttpServlet {

    @EJB
    private QuizAnswerFacade quizAnswerFacade;

    @EJB
    private QuizQuestionFacade quizQuestionFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String assessmentIdParam = request.getParameter("assessmentId");
        String studentIdParam = request.getParameter("studentId");
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendErrorResponse(response, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            Long studentId = (Long) session.getAttribute("userId");
            if (studentIdParam != null) {
                studentId = Long.parseLong(studentIdParam);
            }

            if (assessmentIdParam == null) {
                sendErrorResponse(response, "Assessment ID is required", HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Long assessmentId = Long.parseLong(assessmentIdParam);
            List<QuizAnswer> answers = quizAnswerFacade.findByAssessmentAndStudent(assessmentId, studentId);
            sendJsonResponse(response, answers, HttpServletResponse.SC_OK);
        } catch (Exception e) {
            sendErrorResponse(response, "Error retrieving answers: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendErrorResponse(response, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            Long studentId = (Long) session.getAttribute("userId");
            User student = userFacade.find(studentId);
            if (student == null) {
                sendErrorResponse(response, "Student not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            String questionIdStr = request.getParameter("questionId");
            String selectedAnswer = request.getParameter("selectedAnswer");

            if (questionIdStr == null || selectedAnswer == null) {
                sendErrorResponse(response, "Missing required fields: questionId, selectedAnswer", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Long questionId = Long.parseLong(questionIdStr);
            QuizQuestion question = quizQuestionFacade.find(questionId);
            if (question == null) {
                sendErrorResponse(response, "Question not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Check if student already answered this question
            List<QuizAnswer> existing = quizAnswerFacade.findByAssessmentAndStudent(
                    question.getAssessment().getId(), studentId);
            boolean alreadyAnswered = existing.stream()
                    .anyMatch(a -> a.getQuestion().getId().equals(questionId));

            if (alreadyAnswered) {
                sendErrorResponse(response, "You have already answered this question", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            QuizAnswer answer = new QuizAnswer(question, student, selectedAnswer.toUpperCase());
            quizAnswerFacade.create(answer, student.getUsername());

            sendJsonResponse(response, answer, HttpServletResponse.SC_CREATED);
        } catch (Exception e) {
            sendErrorResponse(response, "Error submitting answer: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void sendJsonResponse(HttpServletResponse response, Object data, int statusCode) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(statusCode);
        response.getWriter().write(convertToJson(data));
    }

    private void sendErrorResponse(HttpServletResponse response, String message, int statusCode) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(statusCode);
        response.getWriter().write("{\"error\":\"" + escapeJson(message) + "\"}");
    }

    private String convertToJson(Object obj) {
        if (obj instanceof String) {
            return "{\"message\":\"" + escapeJson((String) obj) + "\"}";
        } else if (obj instanceof QuizAnswer) {
            QuizAnswer a = (QuizAnswer) obj;
            StringBuilder json = new StringBuilder("{");
            json.append("\"id\":").append(a.getId()).append(",");
            json.append("\"questionId\":").append(a.getQuestion().getId()).append(",");
            json.append("\"studentId\":").append(a.getStudent().getUserId()).append(",");
            json.append("\"selectedAnswer\":\"").append(a.getSelectedAnswer()).append("\",");
            json.append("\"isCorrect\":").append(a.getIsCorrect()).append(",");
            json.append("\"pointsEarned\":").append(a.getPointsEarned()).append(",");
            json.append("\"correctAnswer\":\"").append(a.getQuestion().getCorrectAnswer()).append("\"");
            json.append("}");
            return json.toString();
        } else if (obj instanceof List) {
            List<?> list = (List<?>) obj;
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                if (i > 0) json.append(",");
                json.append(convertToJson(list.get(i)));
            }
            json.append("]");
            return json.toString();
        }
        return "{}";
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}

