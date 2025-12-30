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
    if (request.getAttribute("totalModules") == null) {
        request.setAttribute("includingPage", "/WEB-INF/components/academic leader/dashboard.jsp");
        request.getRequestDispatcher("/api/dashboard").include(request, response);
        if (request.getAttribute("totalModules") == null) {
            return;
        }
    }

    String username = (String) session.getAttribute("username");
    Integer totalModules = (Integer) request.getAttribute("totalModules");
    Integer totalClasses = (Integer) request.getAttribute("totalClasses");
    Integer totalAssessments = (Integer) request.getAttribute("totalAssessments");
    Integer totalLecturers = (Integer) request.getAttribute("totalLecturers");
    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    List<ModuleDTO> managedModules = (List<ModuleDTO>) request.getAttribute("managedModules");
    List<ModuleDTO> recentModules = (List<ModuleDTO>) request.getAttribute("recentModules");
    String contextPath = request.getContextPath();

    if (totalModules == null) totalModules = 0;
    if (totalClasses == null) totalClasses = 0;
    if (totalAssessments == null) totalAssessments = 0;
    if (totalLecturers == null) totalLecturers = 0;
    if (totalStudents == null) totalStudents = 0;
    if (managedModules == null) managedModules = new ArrayList<>();
    if (recentModules == null) recentModules = new ArrayList<>();
%>

<div class="container mx-auto p-6">
    <!-- Welcome Header -->
    <div class="pb-6">
        <h1 class="font-title font-bold text-4xl text-base-content">Welcome back, <%= username %>!</h1>
        <p class="text-base-content/70 mt-2 text-lg">Manage your modules and oversee academic activities</p>
    </div>

    <!-- Statistics Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
        <!-- Total Modules Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                </div>
                <div class="stat-title">My Modules</div>
                <div class="stat-value text-primary"><%= totalModules %></div>
                <div class="stat-desc">Under management</div>
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
                <div class="stat-desc">Across modules</div>
            </div>
        </div>

        <!-- Total Lecturers Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-accent">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                </div>
                <div class="stat-title">Lecturers</div>
                <div class="stat-value text-accent"><%= totalLecturers %></div>
                <div class="stat-desc">Teaching staff</div>
            </div>
        </div>

        <!-- Total Students Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-info">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path d="M12 14l9-5-9-5-9 5 9 5z" />
                        <path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222" />
                    </svg>
                </div>
                <div class="stat-title">Students</div>
                <div class="stat-value text-info"><%= totalStudents %></div>
                <div class="stat-desc">Enrolled total</div>
            </div>
        </div>

        <!-- Total Assessments Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-warning">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                </div>
                <div class="stat-title">Assessments</div>
                <div class="stat-value text-warning"><%= totalAssessments %></div>
                <div class="stat-desc">All modules</div>
            </div>
        </div>
    </div>

    <!-- Modules Overview and Quick Actions -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- My Modules -->
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                    My Modules
                </h2>
                <% if (managedModules.isEmpty()) { %>
                <div class="text-center py-8 text-base-content/60">
                    <p>No modules assigned yet</p>
                </div>
                <% } else { %>
                <div class="space-y-3 max-h-96 overflow-y-auto">
                    <% for (ModuleDTO module : managedModules) { %>
                    <div class="card bg-gradient-to-r from-primary/10 to-accent/10 hover:from-primary/20 hover:to-accent/20 transition-colors cursor-pointer border border-base-300"
                         onclick="window.location.href='<%= contextPath %>/index.jsp?page=modules&moduleId=<%= module.moduleId %>'">
                        <div class="card-body p-4">
                            <div class="flex justify-between items-start">
                                <div>
                                    <h3 class="font-bold text-lg"><%= module.moduleName %></h3>
                                    <% if (module.managedBy != null) { %>
                                    <p class="text-sm text-base-content/70">
                                        Managed by: <%= module.managedBy.fullname %>
                                    </p>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
                <div class="card-actions justify-end mt-4">
                    <a href="<%= contextPath %>/index.jsp?page=modules" class="btn btn-primary">View All Modules</a>
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
                    <a href="<%= contextPath %>/index.jsp?page=modules" class="btn btn-lg btn-outline">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                        </svg>
                        Manage Modules
                    </a>
                    <a href="<%= contextPath %>/index.jsp?page=reports-academic-leader" class="btn btn-lg btn-outline">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        View Reports
                    </a>
                </div>

                <div class="divider">Module Statistics</div>

                <div class="stats stats-vertical shadow bg-base-200">
                    <div class="stat">
                        <div class="stat-title">Avg Classes per Module</div>
                        <div class="stat-value text-2xl">
                            <%= totalModules > 0 ? String.format("%.1f", (double)totalClasses / totalModules) : "0" %>
                        </div>
                    </div>

                    <div class="stat">
                        <div class="stat-title">Avg Assessments per Class</div>
                        <div class="stat-value text-2xl">
                            <%= totalClasses > 0 ? String.format("%.1f", (double)totalAssessments / totalClasses) : "0" %>
                        </div>
                    </div>

                    <div class="stat">
                        <div class="stat-title">Avg Students per Lecturer</div>
                        <div class="stat-value text-2xl">
                            <%= totalLecturers > 0 ? String.format("%.0f", (double)totalStudents / totalLecturers) : "0" %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Modules Details -->
    <% if (!recentModules.isEmpty()) { %>
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body">
            <h2 class="card-title text-2xl mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Recent Modules
            </h2>
            <div class="overflow-x-auto">
                <table class="table table-zebra w-full">
                    <thead>
                        <tr>
                            <th>Module Name</th>
                            <th>Managed By</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (ModuleDTO module : recentModules) { %>
                        <tr>
                            <td class="font-semibold"><%= module.moduleName %></td>
                            <td><%= module.managedBy != null ? module.managedBy.fullname : "Unassigned" %></td>
                            <td>
                                <a href="<%= contextPath %>/index.jsp?page=modules&moduleId=<%= module.moduleId %>"
                                   class="btn btn-sm btn-ghost">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                    View
                                </a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <% } %>

    <!-- System Info -->
    <div class="card bg-gradient-to-r from-primary to-secondary text-white shadow-xl mt-6">
        <div class="card-body">
            <h2 class="card-title text-2xl">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Academic Leadership Overview
            </h2>
            <p class="text-white/90">
                You are currently managing <strong><%= totalModules %></strong> module<%= totalModules != 1 ? "s" : "" %>
                with <strong><%= totalClasses %></strong> active class<%= totalClasses != 1 ? "es" : "" %>.
                There are <strong><%= totalLecturers %></strong> lecturer<%= totalLecturers != 1 ? "s" : "" %> teaching
                <strong><%= totalStudents %></strong> student<%= totalStudents != 1 ? "s" : "" %> across your modules.
            </p>
        </div>
    </div>
</div>

