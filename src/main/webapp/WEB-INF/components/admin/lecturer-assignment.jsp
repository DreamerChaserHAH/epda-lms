<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String contextPath = request.getContextPath();
%>
<div>
    <div class="flex items-center justify-between pb-3 pt-3">
        <h2 class="font-title font-bold text-2xl">Lecturer Assignment</h2>
    </div>
    <p class="text-lg text-gray-500 pr-6 pt-2">Assign lecturers to academic leaders</p>

    <jsp:include page="/lecturers"/>
</div>