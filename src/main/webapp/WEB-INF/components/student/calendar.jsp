<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Fetch calendar data if not already loaded
    if (request.getAttribute("upcomingAssessments") == null) {
        request.setAttribute("includingPage", "/WEB-INF/components/student/calendar.jsp");
        request.getRequestDispatcher("/api/calendar").include(request, response);
        return;
    }
%>
<jsp:include page="../../views/student/calendar-view.jsp"/>
