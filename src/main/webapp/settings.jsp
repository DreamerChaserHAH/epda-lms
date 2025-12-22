<%--
  Created by IntelliJ IDEA.
  User: victor
  Date: 12/22/25
  Time: 11:32 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Get parameters passed from parent
    String username = request.getParameter("username");
    String userRole = request.getParameter("userRole");
%>
<div class="navbar bg-white shadow-sm">
    <div class="flex-1">
        <span class="text-xl font-semibold">Welcome, <%= username %></span>
    </div>
</div>