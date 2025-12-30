<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.ClassDTO" %>
<%@ page import="java.util.List" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Get lecturer ID from session
    Long lecturerId = (Long) request.getSession().getAttribute("userId");

    // Fetch classes if not already loaded
    if (request.getAttribute("classes") == null && lecturerId != null) {
        request.setAttribute("includingPage", "/WEB-INF/views/lecturer/class-list-fragment.jsp");
        request.getRequestDispatcher("/classes?lecturerId=" + lecturerId).include(request, response);
        return;
    }

    List<ClassDTO> classes = (List<ClassDTO>) request.getAttribute("classes");
    String contextPath = request.getContextPath();
%>

<div class="container mx-auto p-6">
    <div class="mb-8">
        <h1 class="text-3xl font-bold text-base-content mb-2">My Classes</h1>
        <p class="text-base-content/70">Manage and view all classes you're teaching</p>
    </div>

    <% if (classes == null || classes.isEmpty()) { %>
    <div class="alert alert-info shadow-lg">
        <img src="<%= contextPath %>/images/icons/info-circle.png"
             alt="Info" class="h-6 w-6 shrink-0">
        <span class="font-medium">You are not assigned to any classes yet</span>
    </div>
    <% } else { %>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <% for (ClassDTO classDTO : classes) { %>
        <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300 hover:scale-105 border border-base-300">
            <div class="card-body">
                <div class="flex items-start justify-between mb-4">
                    <h2 class="card-title text-xl font-bold text-base-content">
                        <%= classDTO.className %>
                    </h2>
                    <div class="badge badge-primary badge-lg">
                        <%= classDTO.students != null ? classDTO.students.size() : 0 %> Students
                    </div>
                </div>

                <div class="space-y-2 mb-4">
                    <div class="flex items-center gap-2">
                        <img src="<%= contextPath %>/images/icons/books.png"
                             alt="Module" class="h-5 w-5">
                        <p class="text-sm text-base-content/80">
                            <span class="font-semibold">Module:</span> <%= classDTO.moduleDTO.moduleName %>
                        </p>
                    </div>
                    <% if (classDTO.moduleDTO.createdBy != null) { %>
                    <div class="flex items-center gap-2">
                        <img src="<%= contextPath %>/images/icons/profile.png"
                             alt="Leader" class="h-5 w-5">
                        <p class="text-sm text-base-content/80">
                            <span class="font-semibold">Lead:</span> <%= classDTO.moduleDTO.createdBy.fullname %>
                        </p>
                    </div>
                    <% } %>
                </div>

                <div class="card-actions justify-end mt-4">
                    <button class="btn btn-primary btn-sm text-white font-semibold rounded-lg hover:scale-105 transition-transform"
                            onclick="window.location.href='<%= contextPath %>/index.jsp?page=classes&classId=<%= classDTO.classId %>'">
                        View Details
                        <img src="<%= contextPath %>/images/icons/arrow-right.png"
                             alt="Arrow" class="h-4 w-4 ml-1">
                    </button>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>
