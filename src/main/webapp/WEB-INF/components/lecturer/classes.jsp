<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String contextPath = request.getContextPath();
    String classId = request.getParameter("classId");
    String assessmentId = request.getParameter("assessmentId");
%>

<% if (assessmentId != null && !assessmentId.isEmpty()) { %>
<!-- Display assessment details page when assessmentId parameter exists -->
<jsp:include page="../../views/lecturer/assessment-details.jsp"/>
<% } else if (classId != null && !classId.isEmpty()) { %>
<!-- Display class details page when classId parameter exists -->
<jsp:include page="../../views/lecturer/class-details.jsp"/>
<% } else { %>
<!-- Display class list when no parameters -->
<div>
    <div class="flex items-center justify-between pb-3 pt-3">
        <h2 class="font-title font-bold text-2xl">Classes</h2>
    </div>
    <p class="text-lg text-gray-500 pr-6 pt-2">Manage your classes</p>

    <jsp:include page="../../views/lecturer/class-list-fragment.jsp"/>
</div>
<% } %>
