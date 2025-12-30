<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.*" %>
<%@ page import="java.util.*" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Fetch dashboard data if not already loaded
    if (request.getAttribute("totalUsers") == null) {
        request.setAttribute("includingPage", "/WEB-INF/components/admin/dashboard.jsp");
        request.getRequestDispatcher("/api/dashboard").include(request, response);
        if (request.getAttribute("totalUsers") == null) {
            return;
        }
    }

    String username = (String) session.getAttribute("username");
    Long totalUsers = (Long) request.getAttribute("totalUsers");
    Long totalStudents = (Long) request.getAttribute("totalStudents");
    Long totalLecturers = (Long) request.getAttribute("totalLecturers");
    Long totalAcademicLeaders = (Long) request.getAttribute("totalAcademicLeaders");
    Integer totalClasses = (Integer) request.getAttribute("totalClasses");
    Integer totalModules = (Integer) request.getAttribute("totalModules");
    Integer totalAssessments = (Integer) request.getAttribute("totalAssessments");
    Integer totalGradingSchemes = (Integer) request.getAttribute("totalGradingSchemes");
    List<ClassDTO> recentClasses = (List<ClassDTO>) request.getAttribute("recentClasses");
    String contextPath = request.getContextPath();

    if (totalUsers == null) totalUsers = 0L;
    if (totalStudents == null) totalStudents = 0L;
    if (totalLecturers == null) totalLecturers = 0L;
    if (totalAcademicLeaders == null) totalAcademicLeaders = 0L;
    if (totalClasses == null) totalClasses = 0;
    if (totalModules == null) totalModules = 0;
    if (totalAssessments == null) totalAssessments = 0;
    if (totalGradingSchemes == null) totalGradingSchemes = 0;
    if (recentClasses == null) recentClasses = new ArrayList<>();
%>

<div class="container mx-auto p-6">
    <!-- Welcome Header -->
    <div class="pb-6">
        <h1 class="font-title font-bold text-4xl text-base-content">Welcome back, <%= username %>!</h1>
        <p class="text-base-content/70 mt-2 text-lg">Here's your administrative overview</p>
    </div>

    <!-- Statistics Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <!-- Total Users Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                    </svg>
                </div>
                <div class="stat-title">Total Users</div>
                <div class="stat-value text-primary"><%= totalUsers %></div>
                <div class="stat-desc">Registered in system</div>
            </div>
        </div>

        <!-- Total Classes Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                </div>
                <div class="stat-title">Total Classes</div>
                <div class="stat-value text-secondary"><%= totalClasses %></div>
                <div class="stat-desc">Active classes</div>
            </div>
        </div>

        <!-- Total Modules Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-accent">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                </div>
                <div class="stat-title">Total Modules</div>
                <div class="stat-value text-accent"><%= totalModules %></div>
                <div class="stat-desc">Course modules</div>
            </div>
        </div>

        <!-- Total Assessments Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-info">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                </div>
                <div class="stat-title">Total Assessments</div>
                <div class="stat-value text-info"><%= totalAssessments %></div>
                <div class="stat-desc">System-wide</div>
            </div>
        </div>
    </div>

    <!-- User Distribution Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <!-- Students Card -->
        <div class="card bg-gradient-to-br from-blue-500 to-blue-700 text-white shadow-xl">
            <div class="card-body">
                <h3 class="card-title text-2xl">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path d="M12 14l9-5-9-5-9 5 9 5z" />
                        <path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222" />
                    </svg>
                    Students
                </h3>
                <p class="text-5xl font-bold my-4"><%= totalStudents %></p>
                <div class="card-actions justify-end">
                    <a href="<%= contextPath %>/index.jsp?page=users" class="btn btn-sm btn-ghost text-white">View All →</a>
                </div>
            </div>
        </div>

        <!-- Lecturers Card -->
        <div class="card bg-gradient-to-br from-purple-500 to-purple-700 text-white shadow-xl">
            <div class="card-body">
                <h3 class="card-title text-2xl">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                    Lecturers
                </h3>
                <p class="text-5xl font-bold my-4"><%= totalLecturers %></p>
                <div class="card-actions justify-end">
                    <a href="<%= contextPath %>/index.jsp?page=users" class="btn btn-sm btn-ghost text-white">View All →</a>
                </div>
            </div>
        </div>

        <!-- Academic Leaders Card -->
        <div class="card bg-gradient-to-br from-orange-500 to-orange-700 text-white shadow-xl">
            <div class="card-body">
                <h3 class="card-title text-2xl">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                    </svg>
                    Leaders
                </h3>
                <p class="text-5xl font-bold my-4"><%= totalAcademicLeaders %></p>
                <div class="card-actions justify-end">
                    <a href="<%= contextPath %>/index.jsp?page=users" class="btn btn-sm btn-ghost text-white">View All →</a>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Classes and Quick Actions -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Recent Classes -->
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Recent Classes
                </h2>
                <% if (recentClasses.isEmpty()) { %>
                <div class="text-center py-8 text-base-content/60">
                    <p>No classes created yet</p>
                </div>
                <% } else { %>
                <div class="space-y-3">
                    <% for (ClassDTO classDTO : recentClasses) { %>
                    <div class="card bg-base-200 hover:bg-base-300 transition-colors">
                        <div class="card-body p-4">
                            <div class="flex justify-between items-start">
                                <div>
                                    <h3 class="font-bold text-lg"><%= classDTO.className %></h3>
                                    <p class="text-sm text-base-content/70">
                                        Module: <%= classDTO.moduleDTO != null ? classDTO.moduleDTO.moduleName : "N/A" %>
                                    </p>
                                    <p class="text-sm text-base-content/60">
                                        Lecturer: <%= classDTO.moduleDTO != null && classDTO.moduleDTO.managedBy != null ? classDTO.moduleDTO.managedBy.fullname : "Unassigned" %>
                                    </p>
                                </div>
                                <a href="<%= contextPath %>/index.jsp?page=classes" class="btn btn-sm btn-ghost">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                                    </svg>
                                </a>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
                <div class="card-actions justify-end mt-4">
                    <a href="<%= contextPath %>/index.jsp?page=classes" class="btn btn-primary">View All Classes</a>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                    </svg>
                    Quick Actions
                </h2>
                <div class="grid grid-cols-1 gap-3">
                    <a href="<%= contextPath %>/index.jsp?page=users" class="btn btn-lg btn-outline">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                        </svg>
                        Manage Users
                    </a>
                    <a href="<%= contextPath %>/index.jsp?page=classes" class="btn btn-lg btn-outline">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                        </svg>
                        Manage Classes
                    </a>
                    <a href="<%= contextPath %>/index.jsp?page=modules" class="btn btn-lg btn-outline">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                        </svg>
                        Manage Modules
                    </a>
                    <a href="<%= contextPath %>/index.jsp?page=grading" class="btn btn-lg btn-outline">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
                        </svg>
                        Grading Schemes
                    </a>
                    <a href="<%= contextPath %>/index.jsp?page=reports" class="btn btn-lg btn-outline">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                        View Reports
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- System Overview Card -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mt-6">
        <div class="card-body">
            <h2 class="card-title text-2xl mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
                System Overview
            </h2>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div class="stat bg-base-200 rounded-lg p-4">
                    <div class="stat-title">Grading Schemes</div>
                    <div class="stat-value text-2xl"><%= totalGradingSchemes %></div>
                </div>
                <div class="stat bg-base-200 rounded-lg p-4">
                    <div class="stat-title">Active Modules</div>
                    <div class="stat-value text-2xl"><%= totalModules %></div>
                </div>
                <div class="stat bg-base-200 rounded-lg p-4">
                    <div class="stat-title">Active Classes</div>
                    <div class="stat-value text-2xl"><%= totalClasses %></div>
                </div>
                <div class="stat bg-base-200 rounded-lg p-4">
                    <div class="stat-title">Assessments</div>
                    <div class="stat-value text-2xl"><%= totalAssessments %></div>
                </div>
            </div>
        </div>
    </div>
</div>

