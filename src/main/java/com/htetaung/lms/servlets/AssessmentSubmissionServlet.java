package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.AssessmentFacade;
import com.htetaung.lms.ejbs.facades.AssessmentSubmissionFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.ejbs.services.NotificationService;
import com.htetaung.lms.models.Assessment;
import com.htetaung.lms.models.AssessmentSubmission;
import com.htetaung.lms.models.User;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.List;

@MultipartConfig
@WebServlet(name = "assessmentSubmissionServlet", urlPatterns = {"/api/submissions/*"})
public class AssessmentSubmissionServlet extends HttpServlet {

    @EJB
    private AssessmentSubmissionFacade submissionFacade;

    @EJB
    private AssessmentFacade assessmentFacade;

    @EJB
    private UserFacade userFacade;

    @EJB
    private NotificationService notificationService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("userId") == null) {
            sendErrorResponse(response, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Long userId = (Long) session.getAttribute("userId");
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                String assessmentIdParam = request.getParameter("assessmentId");
                if (assessmentIdParam != null) {
                    Long assessmentId = Long.parseLong(assessmentIdParam);
                    AssessmentSubmission submission = submissionFacade.findByAssessmentAndStudent(assessmentId, userId);
                    if (submission != null) {
                        sendJsonResponse(response, submission, HttpServletResponse.SC_OK);
                    } else {
                        sendErrorResponse(response, "Submission not found", HttpServletResponse.SC_NOT_FOUND);
                    }
                } else {
                    // Get all submissions for the student
                    List<AssessmentSubmission> submissions = submissionFacade.findByStudentId(userId);
                    sendJsonResponse(response, submissions, HttpServletResponse.SC_OK);
                }
            } else {
                String idStr = pathInfo.substring(1);
                Long id = Long.parseLong(idStr);
                AssessmentSubmission submission = submissionFacade.find(id);
                if (submission != null) {
                    sendJsonResponse(response, submission, HttpServletResponse.SC_OK);
                } else {
                    sendErrorResponse(response, "Submission not found", HttpServletResponse.SC_NOT_FOUND);
                }
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Error retrieving submission: " + e.getMessage(), 
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

            String assessmentIdStr = request.getParameter("assessmentId");
            String submissionContent = request.getParameter("submissionContent");

            if (assessmentIdStr == null) {
                sendErrorResponse(response, "Assessment ID is required", HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Long assessmentId = Long.parseLong(assessmentIdStr);
            Assessment assessment = assessmentFacade.find(assessmentId);
            if (assessment == null) {
                sendErrorResponse(response, "Assessment not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Check if already submitted
            AssessmentSubmission existing = submissionFacade.findByAssessmentAndStudent(assessmentId, studentId);
            if (existing != null) {
                sendErrorResponse(response, "You have already submitted this assessment", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            AssessmentSubmission submission = new AssessmentSubmission(assessment, student, submissionContent);

            // Handle file upload
            Part filePart = request.getPart("file");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = filePart.getSubmittedFileName();
                submission.setFileName(fileName);
                // In production, save file to storage and set filePath
                submission.setFilePath("/uploads/" + fileName);
            }

            submissionFacade.create(submission, student.getUsername());
            sendJsonResponse(response, submission, HttpServletResponse.SC_CREATED);
        } catch (Exception e) {
            sendErrorResponse(response, "Error submitting assessment: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            sendErrorResponse(response, "Submission ID is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendErrorResponse(response, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            String idStr = pathInfo.substring(1);
            Long id = Long.parseLong(idStr);
            AssessmentSubmission submission = submissionFacade.find(id);

            if (submission == null) {
                sendErrorResponse(response, "Submission not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Check if user is lecturer/admin for grading
            Long userId = (Long) session.getAttribute("userId");
            User user = userFacade.find(userId);
            boolean canGrade = user != null && 
                    (user.getRole().toString().equals("LECTURER") || 
                     user.getRole().toString().equals("ADMIN") ||
                     user.getRole().toString().equals("ACADEMIC_LEADER"));

            if (canGrade) {
                // Grading
                String marksStr = request.getParameter("marks");
                String maxMarksStr = request.getParameter("maxMarks");
                String feedback = request.getParameter("feedback");

                Double oldMarks = submission.getMarks();
                if (marksStr != null) submission.setMarks(Double.parseDouble(marksStr));
                if (maxMarksStr != null) submission.setMaxMarks(Double.parseDouble(maxMarksStr));
                if (feedback != null) submission.setFeedback(feedback);
                
                submission.setGradedBy(user);
                submission.setGradedAt(new java.util.Date());
                submission.setStatus("GRADED");

                // Send notification to student when grade is posted
                if (oldMarks == null && submission.getMarks() != null) {
                    notificationService.notifyGradePosted(
                        submission.getId(),
                        submission.getStudent().getUserId(),
                        submission.getAssessment().getName(),
                        submission.getMarks()
                    );
                }
            } else {
                // Student updating their submission (before deadline)
                String submissionContent = request.getParameter("submissionContent");
                if (submissionContent != null) {
                    submission.setSubmissionContent(submissionContent);
                }
            }

            submissionFacade.edit(submission, user.getUsername());
            sendJsonResponse(response, submission, HttpServletResponse.SC_OK);
        } catch (Exception e) {
            sendErrorResponse(response, "Error updating submission: " + e.getMessage(), 
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
        } else if (obj instanceof AssessmentSubmission) {
            AssessmentSubmission s = (AssessmentSubmission) obj;
            StringBuilder json = new StringBuilder("{");
            json.append("\"id\":").append(s.getId()).append(",");
            json.append("\"assessmentId\":").append(s.getAssessment().getId()).append(",");
            json.append("\"studentId\":").append(s.getStudent().getUserId()).append(",");
            json.append("\"student\":{\"userId\":").append(s.getStudent().getUserId()).append("},");
            json.append("\"submissionContent\":").append(s.getSubmissionContent() != null ? 
                    "\"" + escapeJson(s.getSubmissionContent()) + "\"" : "null").append(",");
            json.append("\"fileName\":").append(s.getFileName() != null ? 
                    "\"" + escapeJson(s.getFileName()) + "\"" : "null").append(",");
            json.append("\"marks\":").append(s.getMarks() != null ? s.getMarks() : "null").append(",");
            json.append("\"maxMarks\":").append(s.getMaxMarks() != null ? s.getMaxMarks() : "null").append(",");
            json.append("\"feedback\":").append(s.getFeedback() != null ? 
                    "\"" + escapeJson(s.getFeedback()) + "\"" : "null").append(",");
            json.append("\"status\":\"").append(s.getStatus() != null ? s.getStatus() : "SUBMITTED").append("\",");
            json.append("\"submittedAt\":\"").append(formatDate(s.getSubmittedAt())).append("\"");
            if (s.getGradedAt() != null) {
                json.append(",\"gradedAt\":\"").append(formatDate(s.getGradedAt())).append("\"");
            }
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

    private String formatDate(java.util.Date date) {
        if (date == null) return null;
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
        return sdf.format(date);
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

