<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div>
    <div class="flex items-center justify-between pb-3 pt-3">
        <h2 class="font-title font-bold text-2xl">Classes</h2>
    </div>
    <%
        String classId_String = request.getParameter("classId");
        if (classId_String != null && !classId_String.isEmpty()) {
            int classId = Integer.parseInt(classId_String);
            request.setAttribute("classId", classId);
    %>
    <jsp:include page="../../views/admin/class-details-fragment.jsp" />
    <%
            return;
        }
        String leaderId_string = request.getParameter("leaderId");
        if (leaderId_string != null && !leaderId_string.isEmpty()) {
            int leaderId = Integer.parseInt(leaderId_string);
            request.setAttribute("leaderId", leaderId);
    %>
    <jsp:include page="../../views/admin/classes-academic-leader-dropdown-fragment.jsp" />
    <jsp:include page="../../views/admin/classes-fragment.jsp">
        <jsp:param name="leaderId" value="<%= String.valueOf(leaderId) %>" />
    </jsp:include>
    <%
    } else {
    %>
    <jsp:include page="../../views/admin/classes-academic-leader-dropdown-fragment.jsp" />
    <%
        }
    %>
</div>
