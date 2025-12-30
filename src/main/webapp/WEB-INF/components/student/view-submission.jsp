<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.AssessmentDTO" %>
<%
    String contextPath = request.getContextPath();
    String assessmentId = request.getParameter("assessmentId");
    Long studentId = (Long) request.getSession().getAttribute("userId");

    // Fetch assessment with submission info
    if (assessmentId != null && !assessmentId.isEmpty()) {
        if (request.getAttribute("assessment") == null) {
            request.setAttribute("includingPage", "/WEB-INF/components/student/view-submission.jsp");
            request.getRequestDispatcher("/api/assessments?requestedAssessmentId=" + assessmentId + "&studentId=" + studentId).include(request, response);
            return;
        }

        AssessmentDTO assessment = (AssessmentDTO) request.getAttribute("assessment");

        if (assessment != null) {
%>
<div class="container mx-auto p-6">
    <!-- Header Section -->
    <div class="flex items-center justify-between pb-3 pt-3">
        <div>
            <h2 class="font-title font-bold text-3xl text-base-content">Submission Results</h2>
            <p class="text-base-content/70 mt-1"><%= assessment.getAssessmentName() %></p>
        </div>
        <button type="button"
                class="btn btn-ghost btn-sm"
                onclick="window.history.back()">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back
        </button>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Assessment Info -->
        <div class="lg:col-span-1">
            <div class="card bg-base-100 shadow-xl border border-base-300">
                <div class="card-body">
                    <h3 class="card-title text-primary mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Assessment Info
                    </h3>

                    <div class="space-y-4">
                        <div>
                            <label class="text-sm font-semibold text-base-content/70">Type</label>
                            <p class="text-base-content font-medium"><%= assessment.getAssessmentType() %></p>
                        </div>

                        <div>
                            <label class="text-sm font-semibold text-base-content/70">Class</label>
                            <p class="text-base-content font-medium"><%= assessment.getRelatedClass().className %></p>
                        </div>

                        <div>
                            <label class="text-sm font-semibold text-base-content/70">Deadline</label>
                            <p class="text-base-content font-medium">
                                <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(assessment.getDeadline()) %>
                            </p>
                        </div>

                        <div class="divider"></div>

                        <div>
                            <label class="text-sm font-semibold text-base-content/70">Status</label>
                            <div class="badge badge-success badge-lg mt-2">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                Submitted
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Results Card -->
        <div class="lg:col-span-2">
            <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
                <div class="card-body">
                    <h3 class="card-title text-primary mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Your Results
                    </h3>

                    <% if (assessment.getScore() != null) { %>
                    <!-- Score Display -->
                    <div class="stats shadow bg-base-200 mb-6">
                        <div class="stat place-items-center">
                            <div class="stat-title">Your Score</div>
                            <div class="stat-value text-primary text-6xl"><%= assessment.getScore() %>%</div>
                            <div class="stat-desc mt-2">
                                <span class="badge badge-accent badge-lg">Grade: <%= assessment.getGradeSymbol() != null ? assessment.getGradeSymbol() : "UNCATEGORIZED" %></span>
                            </div>
                            <div class="stat-desc mt-2">
                                <% if (assessment.getScore() >= 80) { %>
                                <span class="text-success font-bold">Excellent!</span>
                                <% } else if (assessment.getScore() >= 60) { %>
                                <span class="text-warning font-bold">Good Job!</span>
                                <% } else if (assessment.getScore() >= 40) { %>
                                <span class="text-warning font-bold">Keep Practicing</span>
                                <% } else { %>
                                <span class="text-error font-bold">Needs Improvement</span>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="alert alert-info">
                        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <span>Your submission is being graded. Please check back later.</span>
                    </div>
                    <% } %>

                    <!-- Feedback Section -->
                    <% if (assessment.getFeedbackText() != null && !assessment.getFeedbackText().isEmpty()) { %>
                    <div class="divider"></div>

                    <h4 class="font-bold text-lg mb-3">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
                        </svg>
                        Instructor Feedback
                    </h4>

                    <div class="bg-base-200 p-4 rounded-lg">
                        <p class="text-base-content whitespace-pre-wrap"><%= assessment.getFeedbackText() %></p>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Performance Breakdown (for Quiz) -->
            <% if (assessment.getAssessmentType().toString().equals("QUIZ") && assessment.getScore() != null) { %>
            <div class="card bg-base-100 shadow-xl border border-base-300">
                <div class="card-body">
                    <h3 class="card-title text-primary mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                        Performance Analysis
                    </h3>

                    <div class="space-y-3">
                        <div class="flex justify-between items-center p-3 bg-base-200 rounded-lg">
                            <span class="font-semibold">Grade</span>
                            <span class="text-lg font-bold">
                                <% if (assessment.getScore() >= 80) { %>
                                A
                                <% } else if (assessment.getScore() >= 70) { %>
                                B
                                <% } else if (assessment.getScore() >= 60) { %>
                                C
                                <% } else if (assessment.getScore() >= 50) { %>
                                D
                                <% } else { %>
                                F
                                <% } %>
                            </span>
                        </div>

                        <div class="alert alert-success">
                            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <span>Quiz automatically graded upon submission</span>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>
<%
        } else {
%>
<div class="alert alert-error m-6">
    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
    <span>Assessment not found</span>
</div>
<%
        }
    } else {
%>
<div class="alert alert-warning m-6">
    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
    </svg>
    <span>No assessment selected</span>
</div>
<%
    }
%>

