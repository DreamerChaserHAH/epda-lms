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
        request.setAttribute("includingPage", "/WEB-INF/components/student/dashboard.jsp");
        request.getRequestDispatcher("/api/dashboard").include(request, response);
        if (request.getAttribute("totalClasses") == null) {
            return;
        }
    }

    String username = (String) session.getAttribute("username");
    Integer totalClasses = (Integer) request.getAttribute("totalClasses");
    Integer totalAssessments = (Integer) request.getAttribute("totalAssessments");
    Integer completedAssessments = (Integer) request.getAttribute("completedAssessments");
    Integer pendingAssessments = (Integer) request.getAttribute("pendingAssessments");
    Double averageScore = (Double) request.getAttribute("averageScore");
    List<ClassDTO> enrolledClasses = (List<ClassDTO>) request.getAttribute("enrolledClasses");
    List<AssessmentDTO> upcomingAssessments = (List<AssessmentDTO>) request.getAttribute("upcomingAssessments");
    List<AssessmentDTO> recentSubmissions = (List<AssessmentDTO>) request.getAttribute("recentSubmissions");
    String contextPath = request.getContextPath();

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

    if (totalClasses == null) totalClasses = 0;
    if (totalAssessments == null) totalAssessments = 0;
    if (completedAssessments == null) completedAssessments = 0;
    if (pendingAssessments == null) pendingAssessments = 0;
    if (averageScore == null) averageScore = 0.0;
    if (enrolledClasses == null) enrolledClasses = new ArrayList<>();
    if (upcomingAssessments == null) upcomingAssessments = new ArrayList<>();
    if (recentSubmissions == null) recentSubmissions = new ArrayList<>();
%>

<div class="container mx-auto p-6">
    <!-- Welcome Header -->
    <div class="pb-6">
        <h1 class="font-title font-bold text-4xl text-base-content">Welcome back, <%= username %>!</h1>
        <p class="text-base-content/70 mt-2 text-lg">Track your progress and upcoming assessments</p>
    </div>

    <!-- Statistics Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
        <!-- Enrolled Classes Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                </div>
                <div class="stat-title">Enrolled</div>
                <div class="stat-value text-primary"><%= totalClasses %></div>
                <div class="stat-desc">Classes</div>
            </div>
        </div>

        <!-- Total Assessments Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                </div>
                <div class="stat-title">Total</div>
                <div class="stat-value text-secondary"><%= totalAssessments %></div>
                <div class="stat-desc">Assessments</div>
            </div>
        </div>

        <!-- Completed Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-success">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div class="stat-title">Completed</div>
                <div class="stat-value text-success"><%= completedAssessments %></div>
                <div class="stat-desc">Submitted</div>
            </div>
        </div>

        <!-- Pending Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-warning">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div class="stat-title">Pending</div>
                <div class="stat-value text-warning"><%= pendingAssessments %></div>
                <div class="stat-desc">To submit</div>
            </div>
        </div>

        <!-- Average Score Card -->
        <div class="stats shadow border border-base-300 hover:shadow-lg transition-shadow">
            <div class="stat">
                <div class="stat-figure text-accent">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                    </svg>
                </div>
                <div class="stat-title">Avg Score</div>
                <div class="stat-value text-accent"><%= String.format("%.1f", averageScore) %></div>
                <div class="stat-desc">Out of 100</div>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- Enrolled Classes -->
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                    My Classes
                </h2>
                <% if (enrolledClasses.isEmpty()) { %>
                <div class="text-center py-8 text-base-content/60">
                    <p>Not enrolled in any classes yet</p>
                </div>
                <% } else { %>
                <div class="space-y-3 max-h-96 overflow-y-auto">
                    <% for (ClassDTO classDTO : enrolledClasses) { %>
                    <div class="card bg-gradient-to-r from-primary/10 to-secondary/10 hover:from-primary/20 hover:to-secondary/20 transition-colors cursor-pointer border border-base-300"
                         onclick="window.location.href='<%= contextPath %>/index.jsp?page=assignments&classId=<%= classDTO.classId %>'">
                        <div class="card-body p-4">
                            <div class="flex justify-between items-start">
                                <div>
                                    <h3 class="font-bold text-lg"><%= classDTO.className %></h3>
                                    <p class="text-sm text-base-content/70">
                                        <%= classDTO.moduleDTO != null ? classDTO.moduleDTO.moduleName : "N/A" %>
                                    </p>
                                    <p class="text-xs text-base-content/60 mt-1">
                                        <%= classDTO.moduleDTO != null && classDTO.moduleDTO.managedBy != null ? classDTO.moduleDTO.managedBy.fullname : "No Lecturer" %>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Recent Submissions -->
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
                    </svg>
                    Recent Submissions
                </h2>
                <% if (recentSubmissions.isEmpty()) { %>
                <div class="text-center py-8 text-base-content/60">
                    <p>No submissions yet</p>
                </div>
                <% } else { %>
                <div class="space-y-3 max-h-96 overflow-y-auto">
                    <% for (AssessmentDTO assessment : recentSubmissions) {
                        SubmissionDTO submission = assessment.getSubmission();
                        String statusBadge = "";
                        String statusText = "";
                        if ("GRADED".equals(submission.getGradingStatus())) {
                            statusBadge = "badge-success";
                            statusText = "Graded";
                        } else {
                            statusBadge = "badge-info";
                            statusText = "Submitted";
                        }
                    %>
                    <div class="card bg-base-200 hover:bg-base-300 transition-colors cursor-pointer"
                         onclick="window.location.href='<%= contextPath %>/index.jsp?page=view-submission&submissionId=<%= submission.getSubmissionId() %>'">
                        <div class="card-body p-4">
                            <div class="flex justify-between items-start">
                                <div class="flex-1">
                                    <h3 class="font-bold"><%= assessment.getAssessmentName() %></h3>
                                    <p class="text-sm text-base-content/70">
                                        <%= assessment.getClassName() %>
                                    </p>
                                    <p class="text-xs text-base-content/60">
                                        Submitted: <%= dateFormat.format(submission.getSubmittedAt()) %>
                                    </p>
                                    <% if (submission.getScore() != null) { %>
                                    <p class="text-sm font-bold text-accent mt-1">
                                        Score: <%= submission.getScore() %>/100
                                    </p>
                                    <% } %>
                                </div>
                                <span class="badge <%= statusBadge %>"><%= statusText %></span>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
                <div class="card-actions justify-end mt-4">
                    <a href="<%= contextPath %>/index.jsp?page=results" class="btn btn-outline">View All Results</a>
                </div>
            </div>
        </div>
    </div>

    <!-- Upcoming Assessments -->
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body">
            <h2 class="card-title text-2xl mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Upcoming Assessments - Action Required
            </h2>
            <% if (upcomingAssessments.isEmpty()) { %>
            <div class="alert alert-success">
                <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>Great! You're all caught up. No pending assessments.</span>
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
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (AssessmentDTO assessment : upcomingAssessments) {
                            Date now = new Date();
                            long diffMillis = assessment.getDeadline().getTime() - now.getTime();
                            long daysUntil = diffMillis / (24 * 60 * 60 * 1000);
                            String urgencyClass = "";
                            String urgencyBadge = "";
                            if (daysUntil == 0) {
                                urgencyClass = "text-error font-bold";
                                urgencyBadge = "badge-error";
                            } else if (daysUntil == 1) {
                                urgencyClass = "text-error font-bold";
                                urgencyBadge = "badge-error";
                            } else if (daysUntil <= 3) {
                                urgencyClass = "text-warning font-semibold";
                                urgencyBadge = "badge-warning";
                            } else {
                                urgencyBadge = "badge-ghost";
                            }
                        %>
                        <tr>
                            <td><%= assessment.getAssessmentName() %></td>
                            <td><%= assessment.getClassName() %></td>
                            <td>
                                <span class="badge <%= assessment.getAssessmentType() == AssessmentType.QUIZ ? "badge-secondary" : "badge-accent" %>">
                                    <%= assessment.getAssessmentType() %>
                                </span>
                            </td>
                            <td class="<%= urgencyClass %>">
                                <%= dateFormat.format(assessment.getDeadline()) %>
                                <br>
                                <span class="text-xs"><%= timeFormat.format(assessment.getDeadline()) %></span>
                                <br>
                                <span class="badge <%= urgencyBadge %> badge-sm">
                                    <%= daysUntil == 0 ? "Today" : (daysUntil == 1 ? "Tomorrow" : daysUntil + " days") %>
                                </span>
                            </td>
                            <td>
                                <a href="<%= contextPath %>/index.jsp?page=submit-assessment&assessmentId=<%= assessment.getAssessmentId() %>"
                                   class="btn btn-sm btn-primary">
                                    Submit Now
                                </a>
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
        <a href="<%= contextPath %>/index.jsp?page=assignments" class="btn btn-primary">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
            View All Assessments
        </a>
        <a href="<%= contextPath %>/index.jsp?page=calendar" class="btn btn-outline">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            Calendar View
        </a>
        <a href="<%= contextPath %>/index.jsp?page=results" class="btn btn-outline">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
            View Results
        </a>
    </div>
</div>

