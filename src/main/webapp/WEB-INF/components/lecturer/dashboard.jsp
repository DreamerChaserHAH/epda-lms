<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.*" %>
<%@ page import="com.htetaung.lms.models.enums.AssessmentType" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Fetch dashboard data if not already loaded
    if (request.getAttribute("totalClasses") == null) {
        request.setAttribute("includingPage", "/WEB-INF/components/lecturer/dashboard.jsp");
        request.getRequestDispatcher("/api/dashboard").include(request, response);
        if (request.getAttribute("totalClasses") == null) {
            return;
        }
    }

    String username = (String) session.getAttribute("username");
    Integer totalClasses = (Integer) request.getAttribute("totalClasses");
    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    Integer totalAssessments = (Integer) request.getAttribute("totalAssessments");
    Integer pendingGrading = (Integer) request.getAttribute("pendingGrading");
    Integer gradedSubmissions = (Integer) request.getAttribute("gradedSubmissions");
    List<ClassDTO> myClasses = (List<ClassDTO>) request.getAttribute("myClasses");
    List<SubmissionDTO> recentSubmissions = (List<SubmissionDTO>) request.getAttribute("recentSubmissions");
    List<AssessmentDTO> upcomingAssessments = (List<AssessmentDTO>) request.getAttribute("upcomingAssessments");
    String contextPath = request.getContextPath();

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

    if (totalClasses == null) totalClasses = 0;
    if (totalStudents == null) totalStudents = 0;
    if (totalAssessments == null) totalAssessments = 0;
    if (pendingGrading == null) pendingGrading = 0;
    if (gradedSubmissions == null) gradedSubmissions = 0;
    if (myClasses == null) myClasses = new ArrayList<>();
    if (recentSubmissions == null) recentSubmissions = new ArrayList<>();
    if (upcomingAssessments == null) upcomingAssessments = new ArrayList<>();
%>

<div class="container mx-auto p-6">
    <!-- Welcome Header -->
    <div class="pb-6">
        <h1 class="font-title font-bold text-4xl text-base-content">Welcome back, <%= username %>!</h1>
        <p class="text-base-content/70 mt-2 text-lg">Manage your classes and grade student submissions</p>
    </div>

    <!-- Statistics Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <!-- Total Classes Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                </div>
                <div class="stat-title">My Classes</div>
                <div class="stat-value text-primary"><%= totalClasses %></div>
                <div class="stat-desc">Teaching this semester</div>
            </div>
        </div>

        <!-- Total Students Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path d="M12 14l9-5-9-5-9 5 9 5z" />
                        <path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222" />
                    </svg>
                </div>
                <div class="stat-title">Total Students</div>
                <div class="stat-value text-secondary"><%= totalStudents %></div>
                <div class="stat-desc">Across all classes</div>
            </div>
        </div>

        <!-- Total Assessments Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-accent">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                </div>
                <div class="stat-title">Assessments</div>
                <div class="stat-value text-accent"><%= totalAssessments %></div>
                <div class="stat-desc">Created assessments</div>
            </div>
        </div>

        <!-- Pending Grading Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-warning">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div class="stat-title">Pending Grading</div>
                <div class="stat-value text-warning"><%= pendingGrading %></div>
                <div class="stat-desc"><%= gradedSubmissions %> already graded</div>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- My Classes -->
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                    My Classes
                </h2>
                <% if (myClasses.isEmpty()) { %>
                <div class="text-center py-8 text-base-content/60">
                    <p>No classes assigned yet</p>
                </div>
                <% } else { %>
                <div class="space-y-3 max-h-96 overflow-y-auto">
                    <% for (ClassDTO classDTO : myClasses) { %>
                    <div class="card bg-base-200 hover:bg-base-300 transition-colors cursor-pointer"
                         onclick="window.location.href='<%= contextPath %>/index.jsp?page=classes&classId=<%= classDTO.classId %>'">
                        <div class="card-body p-4">
                            <div class="flex justify-between items-start">
                                <div>
                                    <h3 class="font-bold text-lg"><%= classDTO.className %></h3>
                                    <p class="text-sm text-base-content/70">
                                        <%= classDTO.moduleDTO != null ? classDTO.moduleDTO.moduleName : "N/A" %>
                                    </p>
                                </div>
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

        <!-- Recent Submissions -->
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                    Recent Submissions
                </h2>
                <% if (recentSubmissions.isEmpty()) { %>
                <div class="text-center py-8 text-base-content/60">
                    <p>No submissions yet</p>
                </div>
                <% } else { %>
                <div class="space-y-3 max-h-96 overflow-y-auto">
                    <% for (SubmissionDTO submission : recentSubmissions) { %>
                    <%
                        String statusBadge = "";
                        String statusText = "";
                        if ("GRADED".equals(submission.getGradingStatus())) {
                            statusBadge = "badge-success";
                            statusText = "Graded";
                        } else {
                            statusBadge = "badge-warning";
                            statusText = "Pending";
                        }
                    %>
                    <div class="card bg-base-200 hover:bg-base-300 transition-colors cursor-pointer"
                         onclick="window.location.href='<%= contextPath %>/index.jsp?page=view-submission-lecturer&submissionId=<%= submission.getSubmissionId() %>'">
                        <div class="card-body p-4">
                            <div class="flex justify-between items-start">
                                <div class="flex-1">
                                    <h3 class="font-bold"><%= submission.getAssessmentTitle() != null ? submission.getAssessmentTitle() : "Assessment" %></h3>
                                    <p class="text-sm text-base-content/70">
                                        By: <%= submission.getStudentName() != null ? submission.getStudentName() : "Student" %>
                                    </p>
                                    <p class="text-xs text-base-content/60">
                                        <%= dateFormat.format(submission.getSubmittedAt()) %> at <%= timeFormat.format(submission.getSubmittedAt()) %>
                                    </p>
                                </div>
                                <span class="badge <%= statusBadge %>"><%= statusText %></span>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Upcoming Deadlines -->
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body">
            <h2 class="card-title text-2xl mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                Upcoming Assessment Deadlines
            </h2>
            <% if (upcomingAssessments.isEmpty()) { %>
            <div class="text-center py-8 text-base-content/60">
                <p>No upcoming deadlines</p>
            </div>
            <% } else { %>
            <div class="overflow-x-auto">
                <table class="table table-zebra w-full">
                    <thead>
                        <tr>
                            <th>Assessment</th>
                            <th>Class</th>
                            <th>Type</th>
                            <th>Deadline</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (AssessmentDTO assessment : upcomingAssessments) {
                            Date now = new Date();
                            long diffMillis = assessment.getDeadline().getTime() - now.getTime();
                            long daysUntil = diffMillis / (24 * 60 * 60 * 1000);
                            String urgencyClass = "";
                            if (daysUntil <= 1) {
                                urgencyClass = "text-error font-bold";
                            } else if (daysUntil <= 3) {
                                urgencyClass = "text-warning font-semibold";
                            }
                        %>
                        <tr>
                            <td><%= assessment.getAssessmentName() %></td>
                            <td><%= assessment.getRelatedClass() != null ? assessment.getRelatedClass().className : "N/A" %></td>
                            <td>
                                <span class="badge <%= assessment.getAssessmentType() == AssessmentType.QUIZ ? "badge-secondary" : "badge-accent" %>">
                                    <%= assessment.getAssessmentType() %>
                                </span>
                            </td>
                            <td class="<%= urgencyClass %>">
                                <%= dateFormat.format(assessment.getDeadline()) %>
                                <br>
                                <span class="text-xs"><%= timeFormat.format(assessment.getDeadline()) %></span>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="mt-6 flex gap-4 justify-center flex-wrap">
        <a href="<%= contextPath %>/index.jsp?page=classes" class="btn btn-outline">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
            View Classes
        </a>
    </div>
</div>

