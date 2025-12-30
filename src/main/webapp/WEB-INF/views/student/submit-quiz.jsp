<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String assessmentIdString = request.getParameter("assessmentId");

    if (assessmentIdString == null || assessmentIdString.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
        return;
    }

    // Include the quiz taking servlet to start the quiz session
    request.setAttribute("includingPage", "/WEB-INF/views/student/submit-quiz.jsp");
    request.getRequestDispatcher("/api/take-quiz?action=start&assessmentId=" + assessmentIdString).include(request, response);
%>
