<%--
  Created by IntelliJ IDEA.
  User: victor
  Date: 12/23/25
  Time: 3:29 PM
  To change this template use File | Settings | File Templates.
--%>
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

    String username = (String) session.getAttribute("username");
    String role = session.getAttribute("role") != null ?
            session.getAttribute("role").toString() : "STUDENT";
%>
<div class="navbar bg-white shadow-sm">
    <div class="flex-1">
        <span class="text-xl font-semibold">Welcome, <%= username %></span>
    </div>
</div>
