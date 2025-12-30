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
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
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
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                        </svg>
                        <p class="text-sm text-base-content/80">
                            <span class="font-semibold">Module:</span> <%= classDTO.moduleDTO.moduleName %>
                        </p>
                    </div>
                    <% if (classDTO.moduleDTO.createdBy != null) { %>
                    <div class="flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
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
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>
