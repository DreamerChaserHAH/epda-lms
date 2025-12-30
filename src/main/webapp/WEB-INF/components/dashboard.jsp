<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    // Check if user is authenticated
    if (session.getAttribute("authenticated") == null ||
            !(Boolean)session.getAttribute("authenticated")) {
        return;
    }

    String role = session.getAttribute("role") != null ?
            session.getAttribute("role").toString() : "STUDENT";

    // Redirect to role-specific dashboard
    String dashboardPath = "";
    switch (role) {
        case "ADMIN":
            dashboardPath = "/WEB-INF/components/admin/dashboard.jsp";
            break;
        case "ACADEMIC_LEADER":
            dashboardPath = "/WEB-INF/components/academic leader/dashboard.jsp";
            break;
        case "LECTURER":
            dashboardPath = "/WEB-INF/components/lecturer/dashboard.jsp";
            break;
        case "STUDENT":
            dashboardPath = "/WEB-INF/components/student/dashboard.jsp";
            break;
        default:
            dashboardPath = "/WEB-INF/components/student/dashboard.jsp";
    }
%>
<jsp:include page="<%= dashboardPath %>"/>

