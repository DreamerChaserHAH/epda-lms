package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.AttendanceFacade;
import com.htetaung.lms.ejbs.facades.ClassFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.models.Attendance;
import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.User;
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

@WebServlet(name = "attendanceServlet", urlPatterns = {"/api/attendance/*"})
public class AttendanceServlet extends HttpServlet {

    @EJB
    private AttendanceFacade attendanceFacade;

    @EJB
    private ClassFacade classFacade;

    @EJB
    private UserFacade userFacade;

    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            sendErrorResponse(response, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Long userId = (Long) session.getAttribute("userId");
        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                String classIdParam = request.getParameter("classId");
                String studentIdParam = request.getParameter("studentId");
                String dateParam = request.getParameter("date");

                if (classIdParam != null && dateParam != null) {
                    Long classId = Long.parseLong(classIdParam);
                    Date date = dateFormat.parse(dateParam);
                    List<Attendance> attendance = attendanceFacade.findByClassAndDate(classId, date);
                    sendJsonResponse(response, attendance, HttpServletResponse.SC_OK);
                } else if (classIdParam != null) {
                    Long classId = Long.parseLong(classIdParam);
                    List<Attendance> attendance = attendanceFacade.findByClassId(classId);
                    sendJsonResponse(response, attendance, HttpServletResponse.SC_OK);
                } else if (studentIdParam != null) {
                    Long studentId = Long.parseLong(studentIdParam);
                    List<Attendance> attendance = attendanceFacade.findByStudentId(studentId);
                    sendJsonResponse(response, attendance, HttpServletResponse.SC_OK);
                } else {
                    sendErrorResponse(response, "Missing parameters", HttpServletResponse.SC_BAD_REQUEST);
                }
            } else {
                String idStr = pathInfo.substring(1);
                Long id = Long.parseLong(idStr);
                Attendance attendance = attendanceFacade.find(id);
                if (attendance != null) {
                    sendJsonResponse(response, attendance, HttpServletResponse.SC_OK);
                } else {
                    sendErrorResponse(response, "Attendance not found", HttpServletResponse.SC_NOT_FOUND);
                }
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Error retrieving attendance: " + e.getMessage(), 
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

            Long userId = (Long) session.getAttribute("userId");
            User markedBy = userFacade.find(userId);
            
            // Check if user is lecturer
            if (markedBy == null || !markedBy.getRole().toString().equals("LECTURER")) {
                sendErrorResponse(response, "Only lecturers can mark attendance", HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String classIdStr = request.getParameter("classId");
            String studentIdStr = request.getParameter("studentId");
            String dateStr = request.getParameter("date");
            String status = request.getParameter("status");
            String notes = request.getParameter("notes");

            if (classIdStr == null || studentIdStr == null || dateStr == null || status == null) {
                sendErrorResponse(response, "Missing required fields: classId, studentId, date, status", 
                        HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Long classId = Long.parseLong(classIdStr);
            Long studentId = Long.parseLong(studentIdStr);
            Date date = dateFormat.parse(dateStr);

            Class classEntity = classFacade.find(classId);
            User student = userFacade.find(studentId);

            if (classEntity == null || student == null) {
                sendErrorResponse(response, "Class or student not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Check if attendance already exists
            Attendance existing = attendanceFacade.findByClassStudentAndDate(classId, studentId, date);
            if (existing != null) {
                existing.setStatus(status);
                if (notes != null) existing.setNotes(notes);
                existing.setMarkedBy(markedBy);
                existing.setMarkedAt(new Date());
                attendanceFacade.edit(existing, markedBy.getUsername());
                sendJsonResponse(response, existing, HttpServletResponse.SC_OK);
            } else {
                Attendance attendance = new Attendance(classEntity, student, date, status, markedBy);
                if (notes != null) attendance.setNotes(notes);
                attendanceFacade.create(attendance, markedBy.getUsername());
                sendJsonResponse(response, attendance, HttpServletResponse.SC_CREATED);
            }
        } catch (ParseException e) {
            sendErrorResponse(response, "Invalid date format. Use yyyy-MM-dd", HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            sendErrorResponse(response, "Error creating attendance: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            sendErrorResponse(response, "Attendance ID is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendErrorResponse(response, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            Long userId = (Long) session.getAttribute("userId");
            User user = userFacade.find(userId);
            
            if (user == null || !user.getRole().toString().equals("LECTURER")) {
                sendErrorResponse(response, "Only lecturers can update attendance", HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String idStr = pathInfo.substring(1);
            Long id = Long.parseLong(idStr);
            Attendance attendance = attendanceFacade.find(id);

            if (attendance == null) {
                sendErrorResponse(response, "Attendance not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            String status = request.getParameter("status");
            if (status != null) attendance.setStatus(status);
            
            String notes = request.getParameter("notes");
            if (notes != null) attendance.setNotes(notes);

            attendance.setMarkedBy(user);
            attendance.setMarkedAt(new Date());

            attendanceFacade.edit(attendance, user.getUsername());
            sendJsonResponse(response, attendance, HttpServletResponse.SC_OK);
        } catch (Exception e) {
            sendErrorResponse(response, "Error updating attendance: " + e.getMessage(), 
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
        if (obj instanceof Attendance) {
            Attendance a = (Attendance) obj;
            StringBuilder json = new StringBuilder("{");
            json.append("\"id\":").append(a.getId()).append(",");
            json.append("\"classId\":").append(a.getClassEntity().getClassId()).append(",");
            json.append("\"studentId\":").append(a.getStudent().getUserId()).append(",");
            json.append("\"studentName\":\"").append(escapeJson(a.getStudent().getFullName())).append("\",");
            json.append("\"attendanceDate\":\"").append(dateFormat.format(a.getAttendanceDate())).append("\",");
            json.append("\"status\":\"").append(a.getStatus()).append("\",");
            json.append("\"notes\":").append(a.getNotes() != null ? "\"" + escapeJson(a.getNotes()) + "\"" : "null").append(",");
            json.append("\"markedAt\":\"").append(formatDate(a.getMarkedAt())).append("\"");
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
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
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

