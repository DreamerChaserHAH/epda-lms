<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.ClassDTO" %>
<%@ page import="com.htetaung.lms.models.dto.StudentDTO" %>
<%@ page import="com.htetaung.lms.models.dto.AssessmentDTO" %>
<%@ page import="com.htetaung.lms.models.enums.Visibility" %>
<%@ page import="java.util.List" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String classId_String = request.getParameter("classId");

    // Fetch class details if not already loaded
    if (request.getAttribute("classDetails") == null && classId_String != null) {
        request.setAttribute("includingPage", "/WEB-INF/views/lecturer/class-details.jsp");
        request.getRequestDispatcher("/classes?classId=" + classId_String).include(request, response);
        return;
    }

    // Fetch assessments for this class if not already loaded
    if (request.getAttribute("assessments") == null && classId_String != null) {
        request.setAttribute("includingPage", "/WEB-INF/views/lecturer/class-details.jsp");
        request.getRequestDispatcher("/api/assessments?classId=" + classId_String).include(request, response);
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
%>

<div class="container mx-auto p-6">
    <!-- Header Section -->
    <div class="flex items-center justify-between pb-3 pt-3">
        <div>
            <h2 class="font-title font-bold text-3xl text-base-content"><%= classDTO.className %></h2>
            <p class="text-base-content/70 mt-1">View class information and track student assessment submissions</p>
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

    <!-- Class Information Section (Read-only) -->
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
                    <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
                        <%= classDTO.className %>
                    </div>
                </div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Module</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
                        <%= classDTO.moduleDTO.moduleName %>
                    </div>
                </div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Total Students</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
                        <div class="badge badge-primary badge-lg font-semibold">
                            <%= classDTO.studentCount != null ? classDTO.studentCount : 0 %>
                        </div>
                    </div>
                </div>

                <% if (classDTO.moduleDTO.createdBy != null) { %>
                <div class="form-control lg:col-span-2">
                    <label class="label">
                        <span class="label-text font-semibold">Academic Leader</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
                        <%= classDTO.moduleDTO.createdBy.fullname %>
                    </div>
                </div>
                <% } %>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Total Assessments</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
                        <div class="badge badge-secondary badge-lg font-semibold">
                            <%= assessments != null ? assessments.size() : 0 %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Stats -->
    <% if (assessments != null && !assessments.isEmpty() && classDTO.students != null && !classDTO.students.isEmpty()) { %>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                </div>
                <div class="stat-title">Total Assessments</div>
                <div class="stat-value text-primary"><%= assessments.size() %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                </div>
                <div class="stat-title">Enrolled Students</div>
                <div class="stat-value text-secondary"><%= classDTO.students.size() %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-accent">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                    </svg>
                </div>
                <div class="stat-title">Total Expected Submissions</div>
                <div class="stat-value text-accent"><%= assessments.size() * classDTO.students.size() %></div>
            </div>
        </div>
    </div>
    <% } %>

    <!-- Create Assessment Section -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
        <div class="card-body">
            <div class="flex items-center justify-between">
                <div>
                    <h3 class="card-title text-primary">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        Assessments
                    </h3>
                    <p class="text-sm text-base-content/70 mt-1">Create and manage assessments for this class</p>
                </div>
                <button type="button"
                        class="btn btn-primary text-white font-semibold"
                        onclick="create_assessment_modal.showModal()">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                    Create Assessment
                </button>
            </div>
        </div>
    </div>

    <!-- Assessments List Section -->
    <% if (assessments != null && !assessments.isEmpty()) { %>
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                </svg>
                Assessment Management
            </h3>

            <div class="space-y-4">
                <% for (AssessmentDTO assessment : assessments) {
                    Visibility visibility = assessment.getVisibility() != null ? assessment.getVisibility() : Visibility.PRIVATE;
                    String visibilityBadgeClass = "";
                    String visibilityIcon = "";

                    switch (visibility) {
                        case PUBLIC:
                            visibilityBadgeClass = "badge-success";
                            visibilityIcon = "M15 12a3 3 0 11-6 0 3 3 0 016 0z M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z";
                            break;
                        case PROTECTED:
                            visibilityBadgeClass = "badge-warning";
                            visibilityIcon = "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z";
                            break;
                        case PRIVATE:
                        default:
                            visibilityBadgeClass = "badge-error";
                            visibilityIcon = "M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21";
                            break;
                    }
                %>
                <div class="card bg-base-200 border border-base-300">
                    <div class="card-body p-4">
                        <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                            <div class="flex-1">
                                <div class="flex items-center gap-3 mb-2">
                                    <h4 class="font-bold text-lg"><%= assessment.getAssessmentName() %></h4>
                                    <div class="badge <%= assessment.getAssessmentType().equals(com.htetaung.lms.models.enums.AssessmentType.QUIZ) ? "badge-secondary" : "badge-primary" %>">
                                        <%= assessment.getAssessmentType() %>
                                    </div>
                                    <div class="badge <%= visibilityBadgeClass %> gap-1">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="<%= visibilityIcon %>" />
                                        </svg>
                                        <%= visibility %>
                                    </div>
                                </div>
                                <p class="text-sm text-base-content/70 mb-2"><%= assessment.getAssessmentDescription() %></p>
                                <div class="flex flex-wrap gap-2 text-sm">
                                    <div class="badge badge-outline">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                        </svg>
                                        Due: <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(assessment.getDeadline()) %>
                                    </div>
                                    <% if (assessment.getAssessmentType().equals(com.htetaung.lms.models.enums.AssessmentType.QUIZ)) { %>
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
                                <a href="<%= contextPath %>/index.jsp?page=classes&assessmentId=<%= assessment.getAssessmentId() %>"
                                   class="btn btn-sm btn-info text-white">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                    View
                                </a>
                                <button type="button"
                                        class="btn btn-sm btn-warning"
                                        onclick="openEditModal(<%= assessment.getAssessmentId() %>, '<%= assessment.getAssessmentName().replace("'", "\\'") %>', '<%= assessment.getAssessmentDescription().replace("'", "\\'").replace("\n", "\\n") %>', '<%= assessment.getAssessmentType() %>', '<%= new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(assessment.getDeadline()) %>', '<%= visibility %>')">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                    </svg>
                                    Edit
                                </button>
                                <button type="button"
                                        class="btn btn-sm btn-error text-white"
                                        onclick="confirmDelete(<%= assessment.getAssessmentId() %>, '<%= assessment.getAssessmentName().replace("'", "\\'") %>')">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                    </svg>
                                    Delete
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>
    <% } %>

    <!-- Student Submissions Table -->
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                Student Assessment Submissions
            </h3>

            <% if (classDTO.students != null && !classDTO.students.isEmpty()) { %>
            <div class="overflow-x-auto">
                <table class="table table-zebra table-pin-rows">
                    <thead>
                    <tr>
                        <th class="bg-base-200">#</th>
                        <th class="bg-base-200">Student Name</th>
                        <% if (assessments != null) {
                            for (AssessmentDTO assessment : assessments) { %>
                        <th class="bg-base-200 text-center">
                            <div class="tooltip" data-tip="<%= assessment.getAssessmentName() %>">
                                <%= assessment.getAssessmentName().length() > 20 ? assessment.getAssessmentName().substring(0, 17) + "..." : assessment.getAssessmentName() %>
                            </div>
                        </th>
                        <% }
                        } %>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        int index = 1;
                        for (StudentDTO student : classDTO.students) {
                    %>
                    <tr>
                        <td><%= index++ %></td>
                        <td>
                            <div class="flex items-center gap-3">
                                <div class="avatar placeholder">
                                    <div class="bg-primary text-primary-content rounded-full w-10">
                                        <span class="text-sm"><%= student.fullname.substring(0, 1).toUpperCase() %></span>
                                    </div>
                                </div>
                                <div>
                                    <div class="font-bold"><%= student.fullname %></div>
                                    <div class="text-sm opacity-50"><%= student.email %></div>
                                </div>
                            </div>
                        </td>
                        <% if (assessments != null) {
                            for (AssessmentDTO assessment : assessments) {
                                // TODO: Check if student has submitted this assessment
                                boolean hasSubmitted = false;
                        %>
                        <td class="text-center">
                            <% if (hasSubmitted) { %>
                            <div class="badge badge-success">Submitted</div>
                            <% } else { %>
                            <div class="badge badge-error">Pending</div>
                            <% } %>
                        </td>
                        <% }
                        } %>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } else { %>
            <div class="alert alert-info">
                <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>No students enrolled in this class yet.</span>
            </div>
            <% } %>
        </div>
    </div>
</div>

<!-- Create Assessment Modal (Visibility defaults to PRIVATE) -->
<dialog id="create_assessment_modal" class="modal">
    <div class="modal-box w-11/12 max-w-2xl">
        <form method="dialog">
            <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
        </form>

        <h3 class="font-bold text-2xl text-primary mb-4">Create New Assessment</h3>
        <p class="text-base-content/70 mb-6">Fill in the details to create a new assessment for this class</p>

        <form action="<%= contextPath %>/api/assessments" method="POST" class="space-y-4">
            <!-- Hidden fields -->
            <input type="hidden" name="relatedClassId" value="<%= classDTO.classId %>">
            <input type="hidden" name="lecturerId" value="<%= request.getSession().getAttribute("userId") %>">
            <input type="hidden" name="visibility" value="PRIVATE">

            <!-- Assessment Name -->
            <div class="form-control">
                <label class="label">
                    <span class="label-text font-semibold">Assessment Name <span class="text-error">*</span></span>
                </label>
                <input type="text"
                       name="assessmentName"
                       placeholder="e.g., Midterm Exam, Final Project"
                       class="input input-bordered w-full"
                       required>
            </div>

            <!-- Assessment Description -->
            <div class="form-control">
                <label class="label">
                    <span class="label-text font-semibold">Description <span class="text-error">*</span></span>
                </label>
                <textarea name="assessmentDescription"
                          placeholder="Provide detailed instructions and requirements for this assessment"
                          class="textarea textarea-bordered h-24 w-full"
                          required></textarea>
            </div>

            <!-- Assessment Type and Deadline Row -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <!-- Assessment Type -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Assessment Type <span class="text-error">*</span></span>
                    </label>
                    <select name="assessmentType" class="select select-bordered w-full" required>
                        <option value="" disabled selected>Select type</option>
                        <option value="ASSIGNMENT">Assignment</option>
                        <option value="QUIZ">Quiz</option>
                    </select>
                </div>

                <!-- Deadline -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Deadline <span class="text-error">*</span></span>
                    </label>
                    <input type="datetime-local"
                           name="deadline"
                           class="input input-bordered w-full"
                           required>
                </div>
            </div>

            <!-- Submit Button -->
            <div class="modal-action">
                <button type="button"
                        class="btn btn-ghost"
                        onclick="create_assessment_modal.close()">
                    Cancel
                </button>
                <button type="submit" class="btn btn-primary text-white font-semibold">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                    Create Assessment
                </button>
            </div>
        </form>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>

<!-- Edit Assessment Modal (With Visibility Field) -->
<dialog id="edit_assessment_modal" class="modal">
    <div class="modal-box w-11/12 max-w-2xl">
        <form method="dialog">
            <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
        </form>

        <h3 class="font-bold text-2xl text-warning mb-4">Edit Assessment</h3>
        <p class="text-base-content/70 mb-6">Update the assessment details</p>

        <form action="<%= contextPath %>/api/assessments" method="POST" class="space-y-4">
            <input type="hidden" name="_method" value="PUT">
            <input type="hidden" name="assessmentId" id="edit_assessmentId">
            <input type="hidden" name="relatedClassId" value="<%= classDTO.classId %>">

            <!-- Assessment Name -->
            <div class="form-control">
                <label class="label">
                    <span class="label-text font-semibold">Assessment Name <span class="text-error">*</span></span>
                </label>
                <input type="text"
                       name="assessmentName"
                       id="edit_assessmentName"
                       placeholder="e.g., Midterm Exam, Final Project"
                       class="input input-bordered w-full"
                       required>
            </div>

            <!-- Assessment Description -->
            <div class="form-control">
                <label class="label">
                    <span class="label-text font-semibold">Description <span class="text-error">*</span></span>
                </label>
                <textarea name="assessmentDescription"
                          id="edit_assessmentDescription"
                          placeholder="Provide detailed instructions and requirements for this assessment"
                          class="textarea textarea-bordered h-24 w-full"
                          required></textarea>
            </div>

            <!-- Assessment Type, Deadline, and Visibility Row -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <!-- Assessment Type -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Type <span class="text-error">*</span></span>
                    </label>
                    <select name="assessmentType" id="edit_assessmentType" class="select select-bordered w-full" required>
                        <option value="" disabled>Select type</option>
                        <option value="ASSIGNMENT">Assignment</option>
                        <option value="QUIZ">Quiz</option>
                    </select>
                </div>

                <!-- Deadline -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Deadline <span class="text-error">*</span></span>
                    </label>
                    <input type="datetime-local"
                           name="deadline"
                           id="edit_deadline"
                           class="input input-bordered w-full"
                           required>
                </div>

                <!-- Visibility -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Visibility <span class="text-error">*</span></span>
                    </label>
                    <select name="visibility" id="edit_visibility" class="select select-bordered w-full" required>
                        <option value="PUBLIC">Public</option>
                        <option value="PROTECTED">Protected</option>
                        <option value="PRIVATE">Private</option>
                    </select>
                    <label class="label">
                        <span class="label-text-alt text-base-content/70">
                            <strong>Public:</strong> All students | <strong>Protected:</strong> Selected students | <strong>Private:</strong> Hidden
                        </span>
                    </label>
                </div>
            </div>

            <!-- Submit Button -->
            <div class="modal-action">
                <button type="button"
                        class="btn btn-ghost"
                        onclick="edit_assessment_modal.close()">
                    Cancel
                </button>
                <button type="submit" class="btn btn-warning text-white font-semibold">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    Update Assessment
                </button>
            </div>
        </form>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>

<!-- Delete Confirmation Modal -->
<dialog id="delete_assessment_modal" class="modal">
    <div class="modal-box">
        <h3 class="font-bold text-2xl text-error mb-4">Delete Assessment?</h3>
        <p class="text-base-content/70 mb-4">Are you sure you want to delete "<span id="delete_assessmentName" class="font-semibold"></span>"?</p>
        <p class="text-sm text-error mb-6">This action cannot be undone. All related submissions will also be deleted.</p>

        <form action="<%= contextPath %>/api/assessments" method="POST">
            <input type="hidden" name="_method" value="DELETE">
            <input type="hidden" name="assessmentId" id="delete_assessmentId">
            <input type="hidden" name="relatedClassId" value="<%= classDTO.classId %>">

            <div class="modal-action">
                <button type="button"
                        class="btn btn-ghost"
                        onclick="delete_assessment_modal.close()">
                    Cancel
                </button>
                <button type="submit" class="btn btn-error text-white font-semibold">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Delete Assessment
                </button>
            </div>
        </form>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>

<script>
    function openEditModal(id, name, description, type, deadline, visibility) {
        document.getElementById('edit_assessmentId').value = id;
        document.getElementById('edit_assessmentName').value = name;
        document.getElementById('edit_assessmentDescription').value = description;
        document.getElementById('edit_assessmentType').value = type;
        document.getElementById('edit_deadline').value = deadline;
        document.getElementById('edit_visibility').value = visibility;
        edit_assessment_modal.showModal();
    }

    function confirmDelete(id, name) {
        document.getElementById('delete_assessmentId').value = id;
        document.getElementById('delete_assessmentName').textContent = name;
        delete_assessment_modal.showModal();
    }
</script>
