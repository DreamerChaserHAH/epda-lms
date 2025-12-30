<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String reportType = request.getParameter("type");
    if (reportType == null) reportType = "overview";

    // Fetch report data if not already loaded
    request.setAttribute("includingPage", "/WEB-INF/components/academic leader/reports-academic-leader.jsp");
    request.getRequestDispatcher("/api/academic-leader-reports?type=" + reportType).include(request, response);
%>
<jsp:include page="../../views/academic-leader/reports-detail-view.jsp"/>


