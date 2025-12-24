package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.AssessmentFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.ejbs.services.NotificationService;
import com.htetaung.lms.models.Assessment;
import com.htetaung.lms.models.User;
import com.htetaung.lms.models.enums.AssessmentType;
import com.htetaung.lms.models.enums.Visibility;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "assessmentServlet", urlPatterns = {"/api/assessments/*"})
public class AssessmentServlet extends HttpServlet {

    @EJB
    private AssessmentFacade assessmentFacade;

    @EJB
    private UserFacade userFacade;

    @EJB
    private NotificationService notificationService;

    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    private static final SimpleDateFormat dateFormatSimple = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // GET /api/assessments - List all assessments
                List<Assessment> assessments = assessmentFacade.findAll();
                sendJsonResponse(response, assessments, HttpServletResponse.SC_OK);
            } else {
                // GET /api/assessments/{id} - Get assessment by ID
                String idStr = pathInfo.substring(1);
                try {
                    Long id = Long.parseLong(idStr);
                    Assessment assessment = assessmentFacade.find(id);
                    if (assessment != null) {
                        sendJsonResponse(response, assessment, HttpServletResponse.SC_OK);
                    } else {
                        sendErrorResponse(response, "Assessment not found", HttpServletResponse.SC_NOT_FOUND);
                    }
                } catch (NumberFormatException e) {
                    sendErrorResponse(response, "Invalid assessment ID", HttpServletResponse.SC_BAD_REQUEST);
                }
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Error retrieving assessments: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String deadlineStr = request.getParameter("deadline");
            String visibilityStr = request.getParameter("visibility");
            String assessmentTypeStr = request.getParameter("assessmentType");

            // Validate required fields
            if (name == null || name.trim().isEmpty() ||
                deadlineStr == null || deadlineStr.trim().isEmpty() ||
                visibilityStr == null || visibilityStr.trim().isEmpty() ||
                assessmentTypeStr == null || assessmentTypeStr.trim().isEmpty()) {
                sendErrorResponse(response, "Missing required fields: name, deadline, visibility, assessmentType", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            // Parse deadline
            Date deadline;
            try {
                deadline = parseDate(deadlineStr);
            } catch (ParseException e) {
                sendErrorResponse(response, "Invalid date format. Use yyyy-MM-dd'T'HH:mm:ss or yyyy-MM-dd", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            // Parse enums
            Visibility visibility;
            AssessmentType assessmentType;
            try {
                visibility = Visibility.valueOf(visibilityStr.toUpperCase());
                assessmentType = AssessmentType.valueOf(assessmentTypeStr.toUpperCase());
            } catch (IllegalArgumentException e) {
                sendErrorResponse(response, "Invalid visibility or assessmentType value", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            // Get current user from session
            HttpSession session = request.getSession(false);
            String operatedBy = "system";
            Optional<User> createdBy = Optional.empty();
            
            if (session != null && session.getAttribute("userId") != null) {
                Long userId = (Long) session.getAttribute("userId");
                User user = userFacade.find(userId);
                if (user != null) {
                    createdBy = Optional.of(user);
                    operatedBy = user.getUsername();
                }
            }

            // Create assessment
            Assessment assessment = new Assessment(name, description, deadline, visibility, assessmentType, createdBy);
            assessmentFacade.create(assessment, operatedBy);

            // Send notifications for new assignment (if PUBLIC visibility)
            if (visibility == Visibility.PUBLIC) {
                // Note: In production, you'd get classId from request or assessment-class relationship
                // For now, we'll notify all students (you can enhance this later)
                String classIdParam = request.getParameter("classId");
                if (classIdParam != null) {
                    try {
                        Long classId = Long.parseLong(classIdParam);
                        notificationService.notifyNewAssignment(assessment.getId(), assessment.getName(), classId);
                    } catch (NumberFormatException e) {
                        // Ignore if classId is invalid
                    }
                }
            }

            sendJsonResponse(response, assessment, HttpServletResponse.SC_CREATED);
        } catch (Exception e) {
            sendErrorResponse(response, "Error creating assessment: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String httpMethod = request.getMethod();
        String methodOverride = request.getParameter("_method");
        
        // Handle method override for PUT and DELETE (for HTML forms)
        if (methodOverride != null && (methodOverride.equalsIgnoreCase("PUT") || methodOverride.equalsIgnoreCase("DELETE"))) {
            if (methodOverride.equalsIgnoreCase("PUT")) {
                doPut(request, response);
                return;
            } else if (methodOverride.equalsIgnoreCase("DELETE")) {
                doDelete(request, response);
                return;
            }
        }
        
        // Handle actual HTTP PUT and DELETE methods
        if ("PUT".equalsIgnoreCase(httpMethod)) {
            doPut(request, response);
        } else if ("DELETE".equalsIgnoreCase(httpMethod)) {
            doDelete(request, response);
        } else {
            super.service(request, response);
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            sendErrorResponse(response, "Assessment ID is required for update", 
                    HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            String idStr = pathInfo.substring(1);
            Long id = Long.parseLong(idStr);
            Assessment assessment = assessmentFacade.find(id);

            if (assessment == null) {
                sendErrorResponse(response, "Assessment not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Update fields if provided
            String name = request.getParameter("name");
            if (name != null && !name.trim().isEmpty()) {
                assessment.setName(name);
            }

            String description = request.getParameter("description");
            if (description != null) {
                assessment.setDescription(description);
            }

            String deadlineStr = request.getParameter("deadline");
            if (deadlineStr != null && !deadlineStr.trim().isEmpty()) {
                try {
                    Date deadline = parseDate(deadlineStr);
                    assessment.setDeadline(deadline);
                } catch (ParseException e) {
                    sendErrorResponse(response, "Invalid date format. Use yyyy-MM-dd'T'HH:mm:ss or yyyy-MM-dd", 
                            HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }

            String visibilityStr = request.getParameter("visibility");
            if (visibilityStr != null && !visibilityStr.trim().isEmpty()) {
                try {
                    Visibility visibility = Visibility.valueOf(visibilityStr.toUpperCase());
                    assessment.setVisibility(visibility);
                } catch (IllegalArgumentException e) {
                    sendErrorResponse(response, "Invalid visibility value", HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }

            String assessmentTypeStr = request.getParameter("assessmentType");
            if (assessmentTypeStr != null && !assessmentTypeStr.trim().isEmpty()) {
                try {
                    AssessmentType assessmentType = AssessmentType.valueOf(assessmentTypeStr.toUpperCase());
                    assessment.setAssessmentType(assessmentType);
                } catch (IllegalArgumentException e) {
                    sendErrorResponse(response, "Invalid assessmentType value", HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }

            // Get current user from session
            HttpSession session = request.getSession(false);
            String operatedBy = "system";
            
            if (session != null && session.getAttribute("userId") != null) {
                Long userId = (Long) session.getAttribute("userId");
                User user = userFacade.find(userId);
                if (user != null) {
                    operatedBy = user.getUsername();
                }
            }

            assessmentFacade.edit(assessment, operatedBy);
            sendJsonResponse(response, assessment, HttpServletResponse.SC_OK);
        } catch (NumberFormatException e) {
            sendErrorResponse(response, "Invalid assessment ID", HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            sendErrorResponse(response, "Error updating assessment: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            sendErrorResponse(response, "Assessment ID is required for deletion", 
                    HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            String idStr = pathInfo.substring(1);
            Long id = Long.parseLong(idStr);
            Assessment assessment = assessmentFacade.find(id);

            if (assessment == null) {
                sendErrorResponse(response, "Assessment not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Get current user from session
            HttpSession session = request.getSession(false);
            String operatedBy = "system";
            
            if (session != null && session.getAttribute("userId") != null) {
                Long userId = (Long) session.getAttribute("userId");
                User user = userFacade.find(userId);
                if (user != null) {
                    operatedBy = user.getUsername();
                }
            }

            assessmentFacade.remove(assessment, operatedBy);
            sendJsonResponse(response, "Assessment deleted successfully", HttpServletResponse.SC_OK);
        } catch (NumberFormatException e) {
            sendErrorResponse(response, "Invalid assessment ID", HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            sendErrorResponse(response, "Error deleting assessment: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private Date parseDate(String dateStr) throws ParseException {
        try {
            return dateFormat.parse(dateStr);
        } catch (ParseException e) {
            return dateFormatSimple.parse(dateStr);
        }
    }

    private void sendJsonResponse(HttpServletResponse response, Object data, int statusCode) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(statusCode);
        
        // Simple JSON serialization (in production, use a library like Jackson or Gson)
        String json = convertToJson(data);
        response.getWriter().write(json);
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
        } else if (obj instanceof Assessment) {
            Assessment a = (Assessment) obj;
            StringBuilder json = new StringBuilder("{");
            json.append("\"id\":").append(a.getId()).append(",");
            json.append("\"name\":\"").append(escapeJson(a.getName())).append("\",");
            json.append("\"description\":").append(a.getDescription() != null ? 
                    "\"" + escapeJson(a.getDescription()) + "\"" : "null").append(",");
            json.append("\"deadline\":\"").append(formatDate(a.getDeadline())).append("\",");
            json.append("\"visibility\":\"").append(a.getVisibility()).append("\",");
            json.append("\"assessmentType\":\"").append(a.getAssessmentType()).append("\",");
            json.append("\"createdAt\":\"").append(formatDate(a.getCreatedAt())).append("\",");
            json.append("\"updatedAt\":\"").append(formatDate(a.getUpdatedAt())).append("\"");
            if (a.getCreatedBy() != null) {
                json.append(",\"createdBy\":{\"userId\":").append(a.getCreatedBy().getUserId())
                    .append(",\"username\":\"").append(escapeJson(a.getCreatedBy().getUsername())).append("\"}");
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

    private String formatDate(Date date) {
        if (date == null) return null;
        return dateFormat.format(date);
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

