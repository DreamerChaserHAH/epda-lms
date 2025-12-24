package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.ClassFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.models.ClassEntity;
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

@WebServlet(name = "classServlet", urlPatterns = {"/api/classes/*"})
public class ClassServlet extends HttpServlet {

    @EJB
    private ClassFacade classFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String lecturerIdParam = request.getParameter("lecturerId");

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                if (lecturerIdParam != null) {
                    Long lecturerId = Long.parseLong(lecturerIdParam);
                    List<ClassEntity> classes = classFacade.findByLecturerId(lecturerId);
                    sendJsonResponse(response, classes, HttpServletResponse.SC_OK);
                } else {
                    List<ClassEntity> classes = classFacade.findAll();
                    sendJsonResponse(response, classes, HttpServletResponse.SC_OK);
                }
            } else {
                String idStr = pathInfo.substring(1);
                Long id = Long.parseLong(idStr);
                ClassEntity classEntity = classFacade.find(id);
                if (classEntity != null) {
                    sendJsonResponse(response, classEntity, HttpServletResponse.SC_OK);
                } else {
                    sendErrorResponse(response, "Class not found", HttpServletResponse.SC_NOT_FOUND);
                }
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Error retrieving classes: " + e.getMessage(), 
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

            String name = request.getParameter("name");
            String classCode = request.getParameter("classCode");
            String description = request.getParameter("description");
            String lecturerIdStr = request.getParameter("lecturerId");

            if (name == null || classCode == null) {
                sendErrorResponse(response, "Missing required fields: name, classCode", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            // Check if class code already exists
            ClassEntity existing = classFacade.findByClassCode(classCode);
            if (existing != null) {
                sendErrorResponse(response, "Class code already exists", HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            User lecturer = null;
            if (lecturerIdStr != null) {
                Long lecturerId = Long.parseLong(lecturerIdStr);
                lecturer = userFacade.find(lecturerId);
            }

            ClassEntity classEntity = new ClassEntity(name, classCode, description, lecturer);
            classFacade.create(classEntity, lecturer != null ? lecturer.getUsername() : "system");
            sendJsonResponse(response, classEntity, HttpServletResponse.SC_CREATED);
        } catch (Exception e) {
            sendErrorResponse(response, "Error creating class: " + e.getMessage(), 
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
        if (obj instanceof ClassEntity) {
            ClassEntity c = (ClassEntity) obj;
            StringBuilder json = new StringBuilder("{");
            json.append("\"id\":").append(c.getId()).append(",");
            json.append("\"name\":\"").append(escapeJson(c.getName())).append("\",");
            json.append("\"classCode\":\"").append(escapeJson(c.getClassCode())).append("\",");
            json.append("\"description\":").append(c.getDescription() != null ? 
                    "\"" + escapeJson(c.getDescription()) + "\"" : "null").append(",");
            json.append("\"lecturerId\":").append(c.getLecturer() != null ? c.getLecturer().getUserId() : "null").append(",");
            json.append("\"isActive\":").append(c.getIsActive());
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

