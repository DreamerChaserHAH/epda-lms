<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    // Get userId from either parameter or session
    String userId = request.getParameter("userId");
    if(userId == null || userId.isEmpty() || userId.equals("null")) {
        Long userId_Long = (Long) session.getAttribute("userId");
        if (userId_Long == null){
            return;
        }
        userId = userId_Long.toString();
    }

    try {
        Long.parseLong(userId);
        // Directly set as attribute for the fragment to use
        request.setAttribute("requestedUserId", Long.parseLong(userId));
        request.getRequestDispatcher("/api/users").include(request, response);
    } catch (NumberFormatException e) {
        return;
    }
%>
