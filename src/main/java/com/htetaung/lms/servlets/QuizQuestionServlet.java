package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.AssessmentFacade;
import com.htetaung.lms.ejbs.facades.QuizQuestionFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.models.Assessment;
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

@WebServlet(name = "quizQuestionServlet", urlPatterns = {"/api/quiz-questions/*"})
public class QuizQuestionServlet extends HttpServlet {

    @EJB
    private QuizQuestionFacade quizQuestionFacade;

    @EJB
    private AssessmentFacade assessmentFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                String assessmentIdParam = request.getParameter("assessmentId");
                if (assessmentIdParam != null) {
                    Long assessmentId = Long.parseLong(assessmentIdParam);
                    List<QuizQuestion> questions = quizQuestionFacade.findByAssessmentId(assessmentId);
                    sendJsonResponse(response, questions, HttpServletResponse.SC_OK);
                } else {
                    sendErrorResponse(response, "Assessment ID is required", HttpServletResponse.SC_BAD_REQUEST);
                }
            } else {
                String idStr = pathInfo.substring(1);
                try {
                    Long id = Long.parseLong(idStr);
                    QuizQuestion question = quizQuestionFacade.find(id);
                    if (question != null) {
                        sendJsonResponse(response, question, HttpServletResponse.SC_OK);
                    } else {
                        sendErrorResponse(response, "Question not found", HttpServletResponse.SC_NOT_FOUND);
                    }
                } catch (NumberFormatException e) {
                    sendErrorResponse(response, "Invalid question ID", HttpServletResponse.SC_BAD_REQUEST);
                }
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Error retrieving questions: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String assessmentIdStr = request.getParameter("assessmentId");
            String questionText = request.getParameter("questionText");
            String optionA = request.getParameter("optionA");
            String optionB = request.getParameter("optionB");
            String optionC = request.getParameter("optionC");
            String optionD = request.getParameter("optionD");
            String correctAnswer = request.getParameter("correctAnswer");
            String pointsStr = request.getParameter("points");

            if (assessmentIdStr == null || questionText == null || optionA == null || 
                optionB == null || correctAnswer == null) {
                sendErrorResponse(response, "Missing required fields", HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Long assessmentId = Long.parseLong(assessmentIdStr);
            Assessment assessment = assessmentFacade.find(assessmentId);
            if (assessment == null) {
                sendErrorResponse(response, "Assessment not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            Integer points = pointsStr != null ? Integer.parseInt(pointsStr) : 1;

            QuizQuestion question = new QuizQuestion(assessment, questionText, optionA, optionB, 
                    optionC, optionD, correctAnswer.toUpperCase(), points);

            HttpSession session = request.getSession(false);
            String operatedBy = "system";
            if (session != null && session.getAttribute("userId") != null) {
                Long userId = (Long) session.getAttribute("userId");
                User user = userFacade.find(userId);
                if (user != null) {
                    operatedBy = user.getUsername();
                }
            }

            quizQuestionFacade.create(question, operatedBy);
            sendJsonResponse(response, question, HttpServletResponse.SC_CREATED);
        } catch (Exception e) {
            sendErrorResponse(response, "Error creating question: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            sendErrorResponse(response, "Question ID is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            String idStr = pathInfo.substring(1);
            Long id = Long.parseLong(idStr);
            QuizQuestion question = quizQuestionFacade.find(id);

            if (question == null) {
                sendErrorResponse(response, "Question not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            String questionText = request.getParameter("questionText");
            if (questionText != null) question.setQuestionText(questionText);
            
            String optionA = request.getParameter("optionA");
            if (optionA != null) question.setOptionA(optionA);
            
            String optionB = request.getParameter("optionB");
            if (optionB != null) question.setOptionB(optionB);
            
            String optionC = request.getParameter("optionC");
            if (optionC != null) question.setOptionC(optionC);
            
            String optionD = request.getParameter("optionD");
            if (optionD != null) question.setOptionD(optionD);
            
            String correctAnswer = request.getParameter("correctAnswer");
            if (correctAnswer != null) question.setCorrectAnswer(correctAnswer.toUpperCase());
            
            String pointsStr = request.getParameter("points");
            if (pointsStr != null) question.setPoints(Integer.parseInt(pointsStr));

            HttpSession session = request.getSession(false);
            String operatedBy = "system";
            if (session != null && session.getAttribute("userId") != null) {
                Long userId = (Long) session.getAttribute("userId");
                User user = userFacade.find(userId);
                if (user != null) {
                    operatedBy = user.getUsername();
                }
            }

            quizQuestionFacade.edit(question, operatedBy);
            sendJsonResponse(response, question, HttpServletResponse.SC_OK);
        } catch (Exception e) {
            sendErrorResponse(response, "Error updating question: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            sendErrorResponse(response, "Question ID is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            String idStr = pathInfo.substring(1);
            Long id = Long.parseLong(idStr);
            QuizQuestion question = quizQuestionFacade.find(id);

            if (question == null) {
                sendErrorResponse(response, "Question not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            HttpSession session = request.getSession(false);
            String operatedBy = "system";
            if (session != null && session.getAttribute("userId") != null) {
                Long userId = (Long) session.getAttribute("userId");
                User user = userFacade.find(userId);
                if (user != null) {
                    operatedBy = user.getUsername();
                }
            }

            quizQuestionFacade.remove(question, operatedBy);
            sendJsonResponse(response, "Question deleted successfully", HttpServletResponse.SC_OK);
        } catch (Exception e) {
            sendErrorResponse(response, "Error deleting question: " + e.getMessage(), 
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
        } else if (obj instanceof QuizQuestion) {
            QuizQuestion q = (QuizQuestion) obj;
            StringBuilder json = new StringBuilder("{");
            json.append("\"id\":").append(q.getId()).append(",");
            json.append("\"assessmentId\":").append(q.getAssessment().getId()).append(",");
            json.append("\"questionText\":\"").append(escapeJson(q.getQuestionText())).append("\",");
            json.append("\"optionA\":\"").append(escapeJson(q.getOptionA())).append("\",");
            json.append("\"optionB\":\"").append(escapeJson(q.getOptionB())).append("\",");
            json.append("\"optionC\":").append(q.getOptionC() != null ? 
                    "\"" + escapeJson(q.getOptionC()) + "\"" : "null").append(",");
            json.append("\"optionD\":").append(q.getOptionD() != null ? 
                    "\"" + escapeJson(q.getOptionD()) + "\"" : "null").append(",");
            json.append("\"correctAnswer\":\"").append(q.getCorrectAnswer()).append("\",");
            json.append("\"points\":").append(q.getPoints());
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

