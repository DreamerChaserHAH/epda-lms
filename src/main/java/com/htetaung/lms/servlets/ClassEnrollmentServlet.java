package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.ClassFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.ejbs.services.ClassServiceFacade;
import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.User;
import com.htetaung.lms.models.dto.ClassDTO;
import com.htetaung.lms.models.dto.ClassEnrollmentDTO;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "classEnrollmentServlet", urlPatterns = {"/api/enrollments/*"})
public class ClassEnrollmentServlet extends HttpServlet {

    @EJB
    private ClassServiceFacade classFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String classIdParam = request.getParameter("classId");
        String studentIdParam = request.getParameter("studentId");

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                if (classIdParam != null) {
                    Long classId = Long.parseLong(classIdParam);
                    List<ClassEnrollmentDTO> enrollments = classFacade.FindEnrollmentsInClass(classId);
                    sendJsonResponse(response, enrollments, HttpServletResponse.SC_OK);
                } else if (studentIdParam != null) {
                    Long studentId = Long.parseLong(studentIdParam);
                    List<ClassEnrollmentDTO> enrollments = classFacade.FindClassesOfStudent(studentId);
                    sendJsonResponse(response, enrollments, HttpServletResponse.SC_OK);
                } else {
                    sendErrorResponse(response, "Missing parameters: classId or studentId", 
                            HttpServletResponse.SC_BAD_REQUEST);
                }
            } else {
                /*String idStr = pathInfo.substring(1);
                Long id = Long.parseLong(idStr);
                ClassEnrollmentDTO enrollment = enrollmentFacade.find(id);
                if (enrollment != null) {
                    sendJsonResponse(response, enrollment, HttpServletResponse.SC_OK);
                } else {
                    sendErrorResponse(response, "Enrollment not found", HttpServletResponse.SC_NOT_FOUND);
                }*/
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Error retrieving enrollments: " + e.getMessage(), 
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

            String classIdStr = request.getParameter("classId");
            String studentIdStr = request.getParameter("studentId");

            if (classIdStr == null || studentIdStr == null) {
                sendErrorResponse(response, "Missing required fields: classId, studentId", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Long classId = Long.parseLong(classIdStr);
            Long studentId = Long.parseLong(studentIdStr);

            ClassDTO classEntity = classFacade.GetClass(classId);
            User student = userFacade.find(studentId);

            if (classEntity == null || student == null) {
                sendErrorResponse(response, "Class or student not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Check if already enrolled
            ClassEnrollmentDTO existing = classFacade.FindClassEnrollmentByStudentAndClass(classId, studentId);
            if (existing != null) {
                sendErrorResponse(response, "Student is already enrolled in this class", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            //ClassEnrollment enrollment = new ClassEnrollment(classEntity, student);
            //enrollmentFacade.create(enrollment, student.getUsername());
            //sendJsonResponse(response, enrollment, HttpServletResponse.SC_CREATED);
        } catch (Exception e) {
            sendErrorResponse(response, "Error creating enrollment: " + e.getMessage(), 
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
        /*if (obj instanceof ClassEnrollment) {
            ClassEnrollment e = (ClassEnrollment) obj;
            StringBuilder json = new StringBuilder("{");
            json.append("\"id\":").append(e.getId()).append(",");
            json.append("\"classId\":").append(e.getClassEntity().getId()).append(",");
            json.append("\"student\":{");
            json.append("\"userId\":").append(e.getStudent().getUserId()).append(",");
            json.append("\"fullName\":\"").append(escapeJson(e.getStudent().getFullName())).append("\",");
            json.append("\"username\":\"").append(escapeJson(e.getStudent().getUsername())).append("\"");
            json.append("},");
            json.append("\"enrolledAt\":\"").append(formatDate(e.getEnrolledAt())).append("\"");
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
        }*/
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

