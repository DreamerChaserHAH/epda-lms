<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.AssessmentDTO" %>
<%@ page import="com.htetaung.lms.models.enums.AssessmentType" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<AssessmentDTO> upcomingAssessments = (List<AssessmentDTO>) request.getAttribute("upcomingAssessments");
    Map<String, List<AssessmentDTO>> assessmentsByDate = (Map<String, List<AssessmentDTO>>) request.getAttribute("assessmentsByDate");
    Integer totalUpcoming = (Integer) request.getAttribute("totalUpcoming");
    Long upcomingThisWeek = (Long) request.getAttribute("upcomingThisWeek");
    Long upcomingThisMonth = (Long) request.getAttribute("upcomingThisMonth");
    String contextPath = request.getContextPath();

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
    SimpleDateFormat dayFormat = new SimpleDateFormat("EEEE");

    if (upcomingAssessments == null) {
        upcomingAssessments = new ArrayList<>();
    }
    if (totalUpcoming == null) totalUpcoming = 0;
    if (upcomingThisWeek == null) upcomingThisWeek = 0L;
    if (upcomingThisMonth == null) upcomingThisMonth = 0L;
%>

<div class="container mx-auto p-6">
    <!-- Header Section -->
    <div class="pb-3 pt-3">
        <h2 class="font-title font-bold text-3xl text-base-content">Assessment Calendar</h2>
        <p class="text-base-content/70 mt-1">Track your upcoming assessments and deadlines</p>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                </div>
                <div class="stat-title">Total Upcoming</div>
                <div class="stat-value text-primary"><%= totalUpcoming %></div>
                <div class="stat-desc">All future assessments</div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-warning">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div class="stat-title">This Week</div>
                <div class="stat-value text-warning"><%= upcomingThisWeek %></div>
                <div class="stat-desc">Due in next 7 days</div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                </div>
                <div class="stat-title">This Month</div>
                <div class="stat-value text-secondary"><%= upcomingThisMonth %></div>
                <div class="stat-desc">Due in next 30 days</div>
            </div>
        </div>
    </div>

    <% if (upcomingAssessments.isEmpty()) { %>
    <!-- No Assessments Message -->
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body items-center text-center py-12">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-24 w-24 text-base-300 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <h3 class="text-2xl font-bold text-base-content mb-2">No Upcoming Assessments</h3>
            <p class="text-base-content/70">You're all caught up! No assessments are due in the near future.</p>
        </div>
    </div>
    <% } else { %>

    <!-- Timeline View -->
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body">
            <h3 class="card-title text-2xl mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Upcoming Deadlines
            </h3>

            <div class="space-y-6">
                <%
                    Date currentDate = null;
                    Date now = new Date();
                    Calendar cal = Calendar.getInstance();

                    for (AssessmentDTO assessment : upcomingAssessments) {
                        Date assessmentDate = assessment.getDeadline();
                        cal.setTime(assessmentDate);
                        cal.set(Calendar.HOUR_OF_DAY, 0);
                        cal.set(Calendar.MINUTE, 0);
                        cal.set(Calendar.SECOND, 0);
                        cal.set(Calendar.MILLISECOND, 0);
                        Date assessmentDateOnly = cal.getTime();

                        // Calculate days until deadline
                        long diffMillis = assessmentDate.getTime() - now.getTime();
                        long daysUntil = diffMillis / (24 * 60 * 60 * 1000);

                        // Determine urgency level
                        String urgencyBadge = "";
                        String urgencyColor = "";
                        if (daysUntil == 0) {
                            urgencyBadge = "Due Today";
                            urgencyColor = "badge-error";
                        } else if (daysUntil == 1) {
                            urgencyBadge = "Due Tomorrow";
                            urgencyColor = "badge-error";
                        } else if (daysUntil <= 3) {
                            urgencyBadge = daysUntil + " days left";
                            urgencyColor = "badge-warning";
                        } else if (daysUntil <= 7) {
                            urgencyBadge = daysUntil + " days left";
                            urgencyColor = "badge-info";
                        } else {
                            urgencyBadge = daysUntil + " days left";
                            urgencyColor = "badge-ghost";
                        }

                        // Check if we need a new date header
                        if (currentDate == null || !assessmentDateOnly.equals(currentDate)) {
                            if (currentDate != null) {
                                // Close previous date group
                %>
                            </div>
                        </div>
                    </div>
                <%
                            }
                            currentDate = assessmentDateOnly;
                %>
                    <!-- Date Header -->
                    <div class="flex items-start gap-4">
                        <div class="flex flex-col items-center min-w-[100px]">
                            <div class="badge badge-lg badge-primary"><%= dayFormat.format(assessmentDate) %></div>
                            <div class="text-lg font-bold mt-1"><%= dateFormat.format(assessmentDate) %></div>
                        </div>
                        <div class="flex-1">
                            <div class="space-y-3">
                <%
                        }

                        // Assessment Card
                        boolean isSubmitted = assessment.getSubmission() != null;
                        String submissionBadge = isSubmitted ? "badge-success" : "badge-ghost";
                        String submissionText = isSubmitted ? "Submitted" : "Not Submitted";

                        String typeIcon = "";
                        String typeBadge = "";
                        if (assessment.getAssessmentType() == AssessmentType.QUIZ) {
                            typeIcon = "<svg xmlns=\"http://www.w3.org/2000/svg\" class=\"h-5 w-5\" fill=\"none\" viewBox=\"0 0 24 24\" stroke=\"currentColor\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z\" /></svg>";
                            typeBadge = "badge-secondary";
                        } else {
                            typeIcon = "<svg xmlns=\"http://www.w3.org/2000/svg\" class=\"h-5 w-5\" fill=\"none\" viewBox=\"0 0 24 24\" stroke=\"currentColor\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z\" /></svg>";
                            typeBadge = "badge-accent";
                        }
                %>
                                <div class="card bg-base-200 border border-base-300 hover:shadow-lg transition-shadow">
                                    <div class="card-body p-4">
                                        <div class="flex items-start justify-between">
                                            <div class="flex-1">
                                                <div class="flex items-center gap-2 mb-2">
                                                    <span class="badge <%= typeBadge %> gap-1">
                                                        <%= typeIcon %>
                                                        <%= assessment.getAssessmentType() %>
                                                    </span>
                                                    <span class="badge <%= urgencyColor %>"><%= urgencyBadge %></span>
                                                    <span class="badge <%= submissionBadge %>"><%= submissionText %></span>
                                                </div>
                                                <h4 class="font-bold text-lg"><%= assessment.getAssessmentName() %></h4>
                                                <p class="text-sm text-base-content/70 mt-1">
                                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                                    </svg>
                                                    <%= assessment.getClassName() != null ? assessment.getClassName() : "Unknown Class" %>
                                                </p>
                                                <% if (assessment.getInstructions() != null && !assessment.getInstructions().isEmpty()) { %>
                                                <p class="text-sm text-base-content/60 mt-2 line-clamp-2"><%= assessment.getInstructions() %></p>
                                                <% } %>
                                                <div class="flex items-center gap-2 mt-2 text-sm text-base-content/60">
                                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                    </svg>
                                                    Due at <%= timeFormat.format(assessment.getDeadline()) %>
                                                </div>
                                            </div>
                                            <div class="flex flex-col gap-2">
                                                <% if (!isSubmitted) { %>
                                                <a href="<%= contextPath %>/index.jsp?page=submit-assessment&assessmentId=<%= assessment.getAssessmentId() %>"
                                                   class="btn btn-primary btn-sm">
                                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                    </svg>
                                                    Submit
                                                </a>
                                                <% } else { %>
                                                <a href="<%= contextPath %>/index.jsp?page=view-submission&submissionId=<%= assessment.getSubmission().getSubmissionId() %>"
                                                   class="btn btn-success btn-sm btn-outline">
                                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                                    </svg>
                                                    View
                                                </a>
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                <%
                    }
                    // Close last date group
                    if (currentDate != null) {
                %>
                            </div>
                        </div>
                    </div>
                <%
                    }
                %>
            </div>
        </div>
    </div>
    <% } %>

    <!-- Quick Actions -->
    <div class="mt-6 flex gap-4 justify-center">
        <form method="post" action="<%= contextPath %>/api/calendar" style="display: inline;">
            <input type="hidden" name="action" value="export">
            <button type="submit" class="btn btn-primary">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                </svg>
                Export Calendar
            </button>
        </form>
        <a href="<%= contextPath %>/index.jsp?page=assignments" class="btn btn-outline">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
            </svg>
            View All Assignments
        </a>
        <a href="<%= contextPath %>/index.jsp?page=results" class="btn btn-outline">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
            View Results
        </a>
    </div>
</div>

