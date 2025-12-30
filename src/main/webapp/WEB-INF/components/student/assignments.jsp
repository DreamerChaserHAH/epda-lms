<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String contextPath = request.getContextPath();
    String classId = request.getParameter("classId");
%>

<% if (classId != null && !classId.isEmpty()) { %>
<!-- Display individual class assessments when classId parameter exists -->
<jsp:include page="../../views/student/class-assessments.jsp"/>
<% } else { %>
<!-- Display all enrolled classes when no classId parameter -->
<jsp:include page="../../views/student/assignments-list.jsp"/>
<% } %>

