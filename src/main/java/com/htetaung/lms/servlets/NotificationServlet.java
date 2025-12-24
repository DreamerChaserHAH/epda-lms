package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.NotificationFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.models.Notification;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "notificationServlet", urlPatterns = {"/api/notifications/*"})
public class NotificationServlet extends HttpServlet {

    @EJB
    private NotificationFacade notificationFacade;

    @EJB
    private UserFacade userFacade;

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
                String unreadOnly = request.getParameter("unreadOnly");
                List<Notification> notifications;
                if ("true".equals(unreadOnly)) {
                    notifications = notificationFacade.findUnreadByUserId(userId);
                } else {
                    notifications = notificationFacade.findByUserId(userId);
                }
                sendJsonResponse(response, notifications, HttpServletResponse.SC_OK);
            } else if (pathInfo.equals("/count")) {
                Long count = notificationFacade.countUnreadByUserId(userId);
                response.setContentType("application/json");
                response.getWriter().write("{\"count\":" + count + "}");
            } else {
                String idStr = pathInfo.substring(1);
                Long id = Long.parseLong(idStr);
                Notification notification = notificationFacade.find(id);
                if (notification != null && notification.getUser().getUserId().equals(userId)) {
                    sendJsonResponse(response, notification, HttpServletResponse.SC_OK);
                } else {
                    sendErrorResponse(response, "Notification not found", HttpServletResponse.SC_NOT_FOUND);
                }
            }
        } catch (Exception e) {
            sendErrorResponse(response, "Error retrieving notifications: " + e.getMessage(), 
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            sendErrorResponse(response, "Notification ID is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                sendErrorResponse(response, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            Long userId = (Long) session.getAttribute("userId");
            String idStr = pathInfo.substring(1);
            Long id = Long.parseLong(idStr);
            Notification notification = notificationFacade.find(id);

            if (notification == null || !notification.getUser().getUserId().equals(userId)) {
                sendErrorResponse(response, "Notification not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            String isReadStr = request.getParameter("isRead");
            if (isReadStr != null) {
                notification.setIsRead(Boolean.parseBoolean(isReadStr));
            }

            notificationFacade.edit(notification, userFacade.find(userId).getUsername());
            sendJsonResponse(response, notification, HttpServletResponse.SC_OK);
        } catch (Exception e) {
            sendErrorResponse(response, "Error updating notification: " + e.getMessage(), 
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
        if (obj instanceof Notification) {
            Notification n = (Notification) obj;
            StringBuilder json = new StringBuilder("{");
            json.append("\"id\":").append(n.getId()).append(",");
            json.append("\"userId\":").append(n.getUser().getUserId()).append(",");
            json.append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",");
            json.append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",");
            json.append("\"type\":\"").append(n.getType()).append("\",");
            json.append("\"isRead\":").append(n.getIsRead()).append(",");
            json.append("\"relatedId\":").append(n.getRelatedId() != null ? n.getRelatedId() : "null").append(",");
            json.append("\"relatedType\":").append(n.getRelatedType() != null ? "\"" + escapeJson(n.getRelatedType()) + "\"" : "null").append(",");
            json.append("\"createdAt\":\"").append(formatDate(n.getCreatedAt())).append("\"");
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

