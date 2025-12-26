<%@ page import="com.htetaung.lms.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
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
    } catch (NumberFormatException e) {
        return;
    }
%>

<jsp:include page="/profile">
    <jsp:param name="userId" value="<%= userId %>"/>
</jsp:include>