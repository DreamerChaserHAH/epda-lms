<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.UserDTO" %>
<%@ page import="java.util.List" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    if (request.getAttribute("users") == null) {
        request.setAttribute("pagination", 1);
        request.setAttribute("searchQuery", "ACADEMIC_LEADER");
        request.setAttribute("filterField", "role");
        request.setAttribute("includingPage", "/WEB-INF/views/admin/classes-academic-leader-dropdown-fragment.jsp");
        request.getRequestDispatcher("/users").include(request, response);
        return;
    }

    List<UserDTO> academicLeaders = (List<UserDTO>) request.getAttribute("users");
    String contextPath = request.getContextPath();
    String selectedLeaderId = request.getAttribute("leaderId") != null? request.getAttribute("leaderId").toString() : null;
%>

<div class="flex items-center gap-4">
    <!-- Academic Leader Dropdown -->
    <div class="form-control flex-1">
        <label class="label">
            <span class="label-text font-semibold">Academic Leader</span>
        </label>
        <select id="academicLeaderSelect" class="select select-bordered w-full">
            <option value="" <%= selectedLeaderId == null ? "selected" : "" %>>Select Academic Leader</option>
            <% if (academicLeaders != null) {
                for (UserDTO leader : academicLeaders) { %>
            <option value="<%= leader.userId %>" <%= String.valueOf(leader.userId).equals(selectedLeaderId) ? "selected" : "" %>>
                <%= leader.fullName %> (<%= leader.username %>)
            </option>
            <% }
            } %>
        </select>
    </div>

    <!-- Search Button -->
    <div class="form-control">
        <label class="label">
            <span class="label-text opacity-0">Action</span>
        </label>
        <button type="button" id="searchBtn" class="btn btn-primary" onclick="searchByLeader()">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            Search
        </button>
    </div>
</div>

<script>
    function searchByLeader() {
        const select = document.getElementById('academicLeaderSelect');
        const leaderId = select.value;

        if (leaderId) {
            window.location.href = '<%= contextPath %>/index.jsp?page=classes&leaderId=' + leaderId;
        } else {
            alert('Please select an academic leader');
        }
    }
</script>
