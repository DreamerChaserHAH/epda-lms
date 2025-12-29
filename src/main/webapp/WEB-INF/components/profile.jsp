<%@ page import="com.htetaung.lms.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String userId = request.getParameter("userId");
  if(userId == null || userId.isEmpty()) {
      userId = (String) session.getAttribute("userId");
      if (userId == null){
        return;
      }
  }
%>

<jsp:include page="/api/users/<%=userId%>"/>