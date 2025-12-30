<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.AssessmentDTO" %>
<%@ page import="com.htetaung.lms.models.dto.StudentDTO" %>
<%@ page import="com.htetaung.lms.models.enums.AssessmentType" %>
<%@ page import="com.htetaung.lms.models.enums.FileFormats" %>
<%@ page import="java.util.List" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String assessmentIdString = request.getParameter("assessmentId");

    // Fetch assessment details if not already loaded
    if (request.getAttribute("assessment") == null && assessmentIdString != null) {
        request.setAttribute("includingPage", "/WEB-INF/views/lecturer/assessment-details.jsp");
        request.getRequestDispatcher("/api/assessments?requestedAssessmentId=" + assessmentIdString).include(request, response);
        return;
    }

    AssessmentDTO assessment = (AssessmentDTO) request.getAttribute("assessment");
    String contextPath = request.getContextPath();

    if (assessment == null) {
%>
<div class="alert alert-error">
    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
    <span>Assessment not found</span>
</div>
<%
        return;
    }

    boolean isQuiz = assessment.getAssessmentType().equals(AssessmentType.QUIZ);
    boolean isAssignment = assessment.getAssessmentType().equals(AssessmentType.ASSIGNMENT);
    List<StudentDTO> students = assessment.getRelatedClass() != null ? assessment.getRelatedClass().students : null;
%>

<div class="container mx-auto p-6">
    <!-- Header Section -->
    <div class="flex items-center justify-between pb-3 pt-3">
        <div>
            <h2 class="font-title font-bold text-3xl text-base-content"><%= assessment.getAssessmentName() %></h2>
            <p class="text-base-content/70 mt-1">Manage assessment details and student submissions</p>
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

    <!-- Assessment Information Card -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6 mt-6">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Assessment Information
            </h3>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Assessment Name</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
                        <%= assessment.getAssessmentName() %>
                    </div>
                </div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Assessment Type</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
                        <div class="badge <%= isQuiz ? "badge-secondary" : "badge-primary" %> badge-lg">
                            <%= assessment.getAssessmentType() %>
                        </div>
                    </div>
                </div>

                <div class="form-control lg:col-span-2">
                    <label class="label">
                        <span class="label-text font-semibold">Description</span>
                    </label>
                    <textarea class="textarea textarea-bordered bg-base-200 cursor-not-allowed h-24" readonly><%= assessment.getAssessmentDescription() %></textarea>
                </div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Class</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
                        <%= assessment.getRelatedClass() != null ? assessment.getRelatedClass().className : "N/A" %>
                    </div>
                </div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Deadline</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
                        <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(assessment.getDeadline()) %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <% if (isAssignment) { %>
    <!-- Assignment Specific Settings -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                Assignment Settings
            </h3>

            <form action="<%= contextPath %>/api/assessments" method="POST" class="space-y-4">
                <input type="hidden" name="_method" value="PUT">
                <input type="hidden" name="assessmentId" value="<%= assessment.getAssessmentId() %>">
                <input type="hidden" name="updateType" value="ALLOWED_FILE_TYPES">

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Allowed File Types <span class="text-error">*</span></span>
                    </label>
                    <select name="allowedFileTypes" multiple class="select select-bordered w-full h-40">
                        <% for (FileFormats format : FileFormats.values()) { %>
                        <option value="<%= format.name() %>"><%= format.name() %> - <%= format.toString() %></option>
                        <% } %>
                    </select>
                    <label class="label">
                        <span class="label-text-alt text-base-content/70">Hold Ctrl (Cmd on Mac) to select multiple file types</span>
                    </label>
                </div>

                <button type="submit" class="btn btn-primary text-white font-semibold">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    Save File Type Settings
                </button>
            </form>
        </div>
    </div>
    <% } %>

    <% if (isQuiz) { %>
    <!-- Quiz Questions Management -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
        <div class="card-body">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <h3 class="card-title text-primary">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Quiz Questions
                    </h3>
                    <p class="text-sm text-base-content/70 mt-1">Create and manage multiple choice questions</p>
                </div>
                <button type="button"
                        class="btn btn-primary text-white font-semibold"
                        onclick="create_question_modal.showModal()">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                    Add Question
                </button>
            </div>

            <!-- Questions List (TODO: Fetch from backend) -->
            <div id="questions-container" class="space-y-4">
                <div class="alert alert-info">
                    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span>No questions added yet. Click "Add Question" to create your first question.</span>
                </div>
            </div>
        </div>
    </div>
    <% } %>

    <!-- Student Submissions Table -->
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                Student Submissions
            </h3>

            <% if (students != null && !students.isEmpty()) { %>
            <div class="overflow-x-auto">
                <table class="table table-zebra table-pin-rows">
                    <thead>
                    <tr>
                        <th class="bg-base-200">#</th>
                        <th class="bg-base-200">Student ID</th>
                        <th class="bg-base-200">Student Name</th>
                        <th class="bg-base-200 text-center">Submission Status</th>
                        <th class="bg-base-200 text-center">Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        int index = 1;
                        for (StudentDTO student : students) {
                            // TODO: Check if student has submitted this assessment
                            boolean hasSubmitted = false;
                            String submissionId = "";
                    %>
                    <tr>
                        <td><%= index++ %></td>
                        <td><%= student.userId %></td>
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
                        <td class="text-center">
                            <% if (hasSubmitted) { %>
                            <div class="badge badge-success badge-lg">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                Submitted
                            </div>
                            <% } else { %>
                            <div class="badge badge-error badge-lg">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                </svg>
                                Not Submitted
                            </div>
                            <% } %>
                        </td>
                        <td class="text-center">
                            <% if (hasSubmitted) { %>
                            <a href="<%= contextPath %>/index.jsp?page=submission-details&submissionId=<%= submissionId %>"
                               class="btn btn-sm btn-info text-white">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                </svg>
                                View Submission
                            </a>
                            <% } else { %>
                            <span class="text-base-content/50">-</span>
                            <% } %>
                        </td>
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

<% if (isQuiz) { %>
<!-- Create Question Modal -->
<dialog id="create_question_modal" class="modal">
    <div class="modal-box w-11/12 max-w-3xl">
        <form method="dialog">
            <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
        </form>

        <h3 class="font-bold text-2xl text-primary mb-4">Create Quiz Question</h3>
        <p class="text-base-content/70 mb-6">Add a multiple choice question to this quiz</p>

        <form action="<%= contextPath %>/api/quiz-questions" method="POST" class="space-y-4">
            <input type="hidden" name="assessmentId" value="<%= assessment.getAssessmentId() %>">

            <!-- Question Text -->
            <div class="form-control">
                <label class="label">
                    <span class="label-text font-semibold">Question <span class="text-error">*</span></span>
                </label>
                <textarea name="questionText"
                          placeholder="Enter your question here..."
                          class="textarea textarea-bordered h-24 w-full"
                          required></textarea>
            </div>

            <!-- Options -->
            <div class="space-y-3">
                <label class="label">
                    <span class="label-text font-semibold">Answer Options <span class="text-error">*</span></span>
                </label>

                <% for (int i = 0; i < 4; i++) { %>
                <div class="form-control">
                    <div class="input-group">
                        <span class="bg-base-200 px-4 flex items-center font-semibold">Option <%= (char)('A' + i) %></span>
                        <input type="text"
                               name="option<%= i %>"
                               placeholder="Enter option <%= (char)('A' + i) %>"
                               class="input input-bordered w-full"
                               required>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Correct Answer -->
            <div class="form-control">
                <label class="label">
                    <span class="label-text font-semibold">Correct Answer <span class="text-error">*</span></span>
                </label>
                <select name="correctAnswerIndex" class="select select-bordered w-full" required>
                    <option value="" disabled selected>Select the correct answer</option>
                    <option value="0">Option A</option>
                    <option value="1">Option B</option>
                    <option value="2">Option C</option>
                    <option value="3">Option D</option>
                </select>
            </div>

            <!-- Submit Button -->
            <div class="modal-action">
                <button type="button"
                        class="btn btn-ghost"
                        onclick="create_question_modal.close()">
                    Cancel
                </button>
                <button type="submit" class="btn btn-primary text-white font-semibold">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                    Add Question
                </button>
            </div>
        </form>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>
<% } %>
