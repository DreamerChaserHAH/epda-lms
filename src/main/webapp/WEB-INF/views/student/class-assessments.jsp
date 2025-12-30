<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.ClassDTO" %>
<%@ page import="com.htetaung.lms.models.dto.AssessmentDTO" %>
<%@ page import="com.htetaung.lms.models.enums.AssessmentType" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String classId_String = request.getParameter("classId");
    Long studentId = (Long) request.getSession().getAttribute("userId");

    // Fetch class details if not already loaded
    if (request.getAttribute("classDetails") == null && classId_String != null) {
        request.setAttribute("includingPage", "/WEB-INF/views/student/class-assessments.jsp");
        request.getRequestDispatcher("/classes?classId=" + classId_String).include(request, response);
        return;
    }

    // Fetch assessments for this class if not already loaded
    if (request.getAttribute("assessments") == null && classId_String != null && studentId != null) {
        request.setAttribute("includingPage", "/WEB-INF/views/student/class-assessments.jsp");
        request.getRequestDispatcher("/api/assessments?classId=" + classId_String + "&studentId=" + studentId).include(request, response);
        return;
    }

    ClassDTO classDTO = (ClassDTO) request.getAttribute("classDetails");
    List<AssessmentDTO> assessments = (List<AssessmentDTO>) request.getAttribute("assessments");
    String contextPath = request.getContextPath();

    if (classDTO == null) {
%>
<div class="alert alert-error">
    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
    <span>Class not found</span>
</div>
<%
        return;
    }

    // Calculate assessment statistics
    int totalAssessments = assessments != null ? assessments.size() : 0;
    int quizCount = 0;
    int assignmentCount = 0;
    int overdue = 0;
    int pending = 0;
    Date now = new Date();

    if (assessments != null) {
        for (AssessmentDTO assessment : assessments) {
            if (assessment.getAssessmentType().equals(AssessmentType.QUIZ)) {
                quizCount++;
            } else {
                assignmentCount++;
            }

            if (assessment.getDeadline().before(now)) {
                overdue++;
            } else {
                pending++;
            }
        }
    }
%>

<div class="container mx-auto p-6">
    <!-- Header Section -->
    <div class="flex items-center justify-between pb-3 pt-3">
        <div>
            <h2 class="font-title font-bold text-3xl text-base-content"><%= classDTO.className %></h2>
            <p class="text-base-content/70 mt-1">View and submit your assessments</p>
        </div>
        <a href="<%= contextPath %>/index.jsp?page=assignments" class="btn btn-ghost btn-sm">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back to Classes
        </a>
    </div>

    <!-- Class Information Card -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6 mt-6">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Class Information
            </h3>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Class Name</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200">
                        <%= classDTO.className %>
                    </div>
                </div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Module</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200">
                        <%= classDTO.moduleDTO.moduleName %>
                    </div>
                </div>

                <% if (classDTO.moduleDTO.createdBy != null) { %>
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Academic Leader</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200">
                        <%= classDTO.moduleDTO.createdBy.fullname %>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Assessment Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                </div>
                <div class="stat-title">Total Assessments</div>
                <div class="stat-value text-primary"><%= totalAssessments %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div class="stat-title">Quizzes</div>
                <div class="stat-value text-secondary"><%= quizCount %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-accent">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                </div>
                <div class="stat-title">Assignments</div>
                <div class="stat-value text-accent"><%= assignmentCount %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-warning">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div class="stat-title">Pending</div>
                <div class="stat-value text-warning"><%= pending %></div>
            </div>
        </div>
    </div>

    <!-- Assessments List -->
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                </svg>
                Assessments
            </h3>

            <% if (assessments != null && !assessments.isEmpty()) { %>
            <div class="space-y-4">
                <% for (AssessmentDTO assessment : assessments) {
                    boolean isQuiz = assessment.getAssessmentType().equals(AssessmentType.QUIZ);
                    boolean isOverdue = assessment.getDeadline().before(now);
                    boolean hasSubmitted = assessment.isHasSubmitted(); // Use actual submission status

                    String statusBadgeClass = "";
                    String statusText = "";

                    if (hasSubmitted) {
                        statusBadgeClass = "badge-success";
                        statusText = "Submitted";
                    } else if (isOverdue) {
                        statusBadgeClass = "badge-error";
                        statusText = "Overdue";
                    } else {
                        statusBadgeClass = "badge-warning";
                        statusText = "Pending";
                    }
                %>
                <div class="card bg-base-200 border border-base-300">
                    <div class="card-body p-4">
                        <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                            <div class="flex-1">
                                <div class="flex items-center gap-3 mb-2">
                                    <h4 class="font-bold text-lg"><%= assessment.getAssessmentName() %></h4>
                                    <div class="badge <%= isQuiz ? "badge-secondary" : "badge-primary" %>">
                                        <%= assessment.getAssessmentType() %>
                                    </div>
                                    <div class="badge <%= statusBadgeClass %> badge-lg">
                                        <%= statusText %>
                                    </div>
                                </div>
                                <p class="text-sm text-base-content/70 mb-2"><%= assessment.getAssessmentDescription() %></p>
                                <div class="flex flex-wrap gap-2 text-sm">
                                    <div class="badge badge-outline <%= isOverdue ? "badge-error" : "" %>">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                        </svg>
                                        Due: <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(assessment.getDeadline()) %>
                                    </div>
                                    <% if (isQuiz) { %>
                                    <div class="badge badge-outline">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                        Duration: 10 min
                                    </div>
                                    <% } %>
                                </div>
                            </div>

                            <div class="flex flex-wrap gap-2">
                                <% if (!hasSubmitted && !isOverdue) { %>
                                <a href="<%= contextPath %>/index.jsp?page=submit-assessment&assessmentId=<%= assessment.getAssessmentId() %>"
                                   class="btn btn-sm btn-success text-white">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                                    </svg>
                                    Submit <%= isQuiz ? "Quiz" : "Assignment" %>
                                </a>
                                <% } else if (hasSubmitted) { %>
                                <a href="<%= contextPath %>/index.jsp?page=view-submission&assessmentId=<%= assessment.getAssessmentId() %>"
                                   class="btn btn-sm btn-info text-white">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                    View Submission
                                </a>
                                <% } %>

                                <a href="<%= contextPath %>/index.jsp?page=assessment-info&assessmentId=<%= assessment.getAssessmentId() %>"
                                   class="btn btn-sm btn-ghost">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    Details
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } else { %>
            <div class="alert alert-info">
                <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>No assessments available for this class yet.</span>
            </div>
            <% } %>
        </div>
    </div>
</div>

