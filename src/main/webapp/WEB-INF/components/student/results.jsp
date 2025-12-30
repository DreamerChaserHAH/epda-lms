<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.SubmissionDTO" %>
<%@ page import="com.htetaung.lms.models.Grading" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String contextPath = request.getContextPath();
    Long studentId = (Long) request.getSession().getAttribute("userId");

    // Fetch submissions if not already loaded
    if (request.getAttribute("submissions") == null && studentId != null) {
        request.setAttribute("includingPage", "/WEB-INF/components/student/results.jsp");
        request.getRequestDispatcher("/api/student-submissions?studentId=" + studentId).include(request, response);
        return;
    }

    List<SubmissionDTO> submissions = (List<SubmissionDTO>) request.getAttribute("submissions");
    List<Grading> gradings = (List<Grading>) request.getAttribute("gradings");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
%>

<div class="container mx-auto p-6">
    <!-- Header Section -->
    <div class="mb-6">
        <h2 class="font-title font-bold text-3xl text-base-content">My Results</h2>
        <p class="text-base-content/70 mt-2">View all your submissions and grades</p>
    </div>

    <!-- Statistics Cards -->
    <% if (submissions != null && !submissions.isEmpty()) {
        int totalSubmissions = submissions.size();
        int gradedSubmissions = 0;
        int pendingSubmissions = 0;
        double totalScore = 0;
        int scoredCount = 0;

        for (SubmissionDTO submission : submissions) {
            if ("GRADED".equals(submission.getGradingStatus())) {
                gradedSubmissions++;
                if (submission.getScore() != null) {
                    totalScore += submission.getScore();
                    scoredCount++;
                }
            } else {
                pendingSubmissions++;
            }
        }

        double averageScore = scoredCount > 0 ? totalScore / scoredCount : 0;
    %>
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                </div>
                <div class="stat-title">Total Submissions</div>
                <div class="stat-value text-primary"><%= totalSubmissions %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-success">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div class="stat-title">Graded</div>
                <div class="stat-value text-success"><%= gradedSubmissions %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-warning">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div class="stat-title">Pending</div>
                <div class="stat-value text-warning"><%= pendingSubmissions %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-accent">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                    </svg>
                </div>
                <div class="stat-title">Average Score</div>
                <div class="stat-value text-accent"><%= String.format("%.1f", averageScore) %>%</div>
            </div>
        </div>
    </div>
    <% } %>

    <!-- Submissions List -->
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                </svg>
                All Submissions
            </h3>

            <% if (submissions != null && !submissions.isEmpty()) { %>
            <div class="overflow-x-auto">
                <table class="table table-zebra">
                    <thead>
                        <tr>
                            <th>Assessment</th>
                            <th>Submitted At</th>
                            <th class="text-center">Score</th>
                            <th class="text-center">Grade</th>
                            <th class="text-center">Status</th>
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (SubmissionDTO submission : submissions) {
                            boolean isGraded = "GRADED".equals(submission.getGradingStatus());
                            String statusBadgeClass = isGraded ? "badge-success" : "badge-warning";
                            String gradeBadgeClass = "badge-accent";

                            // Determine grade badge color based on grade
                            String gradeSymbol = submission.getGradeSymbol() != null ? submission.getGradeSymbol() : "UNCATEGORIZED";
                            if (gradeSymbol.equals("A") || gradeSymbol.equals("A+")) {
                                gradeBadgeClass = "badge-success";
                            } else if (gradeSymbol.equals("B") || gradeSymbol.equals("B+")) {
                                gradeBadgeClass = "badge-info";
                            } else if (gradeSymbol.equals("C") || gradeSymbol.equals("C+")) {
                                gradeBadgeClass = "badge-warning";
                            } else if (gradeSymbol.equals("D") || gradeSymbol.equals("F")) {
                                gradeBadgeClass = "badge-error";
                            }
                        %>
                        <tr class="hover">
                            <td>
                                <div>
                                    <div class="font-bold"><%= submission.getAssessmentTitle() != null ? submission.getAssessmentTitle() : "Unknown Assessment" %></div>
                                    <div class="text-sm opacity-50">ID: <%= submission.getAssessmentId() %></div>
                                </div>
                            </td>
                            <td>
                                <div class="text-sm">
                                    <%= submission.getSubmittedAt() != null ? dateFormat.format(submission.getSubmittedAt()) : "N/A" %>
                                </div>
                            </td>
                            <td class="text-center">
                                <% if (isGraded && submission.getScore() != null) { %>
                                <div class="flex flex-col items-center">
                                    <span class="font-bold text-lg"><%= submission.getScore() %>%</span>
                                    <% if (submission.getScore() >= 50) { %>
                                    <span class="text-xs text-success">PASS</span>
                                    <% } else { %>
                                    <span class="text-xs text-error">FAIL</span>
                                    <% } %>
                                </div>
                                <% } else { %>
                                <span class="text-base-content/50">-</span>
                                <% } %>
                            </td>
                            <td class="text-center">
                                <% if (isGraded) { %>
                                <div class="badge <%= gradeBadgeClass %> badge-lg">
                                    <%= gradeSymbol %>
                                </div>
                                <% } else { %>
                                <span class="text-base-content/50">-</span>
                                <% } %>
                            </td>
                            <td class="text-center">
                                <div class="badge <%= statusBadgeClass %> gap-2">
                                    <% if (isGraded) { %>
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    Graded
                                    <% } else { %>
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    Pending
                                    <% } %>
                                </div>
                            </td>
                            <td class="text-center">
                                <a href="<%= contextPath %>/index.jsp?page=view-submission&assessmentId=<%= submission.getAssessmentId() %>"
                                   class="btn btn-sm btn-primary">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                    View Details
                                </a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } else { %>
            <div class="text-center py-12">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-24 w-24 mx-auto text-base-content/30 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <p class="text-xl font-semibold text-base-content/70">No Submissions Yet</p>
                <p class="text-base-content/50 mt-2">You haven't submitted any assessments yet.</p>
                <a href="<%= contextPath %>/index.jsp?page=assignments" class="btn btn-primary mt-4">
                    View Assignments
                </a>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Grade Legend -->
    <% if (submissions != null && !submissions.isEmpty()) { %>
    <div class="card bg-base-100 shadow-xl border border-base-300 mt-6">
        <div class="card-body">
            <h3 class="card-title text-sm text-base-content/70 mb-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Grade Legend
            </h3>
            <% if (gradings != null && !gradings.isEmpty()) { %>
            <div class="overflow-x-auto">
                <table class="table table-sm">
                    <thead>
                        <tr>
                            <th>Grade</th>
                            <th>Score Range</th>
                            <th class="text-center">Badge</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Grading grading : gradings) {
                            String gradeBadgeClass = "badge-accent";
                            String gradeSymbol = grading.getGradeSymbol();

                            // Determine badge color based on grade symbol
                            if (gradeSymbol.startsWith("A")) {
                                gradeBadgeClass = "badge-success";
                            } else if (gradeSymbol.startsWith("B")) {
                                gradeBadgeClass = "badge-info";
                            } else if (gradeSymbol.startsWith("C")) {
                                gradeBadgeClass = "badge-warning";
                            } else if (gradeSymbol.startsWith("D") || gradeSymbol.startsWith("F")) {
                                gradeBadgeClass = "badge-error";
                            }
                        %>
                        <tr>
                            <td class="font-semibold"><%= grading.getGradeSymbol() %></td>
                            <td><%= grading.getMinScore() %>% - <%= grading.getMaxScore() %>%</td>
                            <td class="text-center">
                                <div class="badge <%= gradeBadgeClass %> badge-lg">
                                    <%= grading.getGradeSymbol() %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        <tr>
                            <td class="font-semibold">UNCATEGORIZED</td>
                            <td colspan="2">
                                <span class="text-sm text-base-content/70">Score does not match any grade category</span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <% } else { %>
            <div class="alert alert-info">
                <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>No grading categories have been configured yet.</span>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>
</div>
