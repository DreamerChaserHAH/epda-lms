<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.SubmissionDTO" %>
<%@ page import="com.htetaung.lms.models.dto.AssignmentSubmissionDTO" %>
<%@ page import="com.htetaung.lms.models.dto.QuizSubmissionDTO" %>
<%@ page import="com.htetaung.lms.models.dto.QuizIndividualQuestionDTO" %>
<%@ page import="com.htetaung.lms.models.dto.FileSubmittedDTO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%
    String contextPath = request.getContextPath();
    String submissionIdStr = request.getParameter("submissionId");

    if (submissionIdStr == null || submissionIdStr.isEmpty()) {
%>
<div class="alert alert-warning m-6">
    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
    </svg>
    <span>No submission selected</span>
</div>
<%
        return;
    }

    // Fetch submission details if not already loaded
    if (request.getAttribute("submission") == null) {
        request.setAttribute("includingPage", "/WEB-INF/components/lecturer/view-submission-lecturer.jsp");
        request.getRequestDispatcher("/api/submission-details?submissionId=" + submissionIdStr).include(request, response);
        return;
    }

    SubmissionDTO submission = (SubmissionDTO) request.getAttribute("submission");

    if (submission == null) {
%>
<div class="alert alert-error m-6">
    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
    <span>Submission not found</span>
</div>
<%
        return;
    }

    boolean isGraded = "GRADED".equals(submission.getGradingStatus());
    SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    String submittedAtStr = submission.getSubmittedAt() != null ? formatter.format(submission.getSubmittedAt()) : "N/A";
%>
<div class="container mx-auto p-6">
    <!-- Header Section -->
    <div class="flex items-center justify-between pb-3 pt-3">
        <div>
            <h2 class="font-title font-bold text-3xl text-base-content">View Submission</h2>
            <p class="text-base-content/70 mt-1">Submission ID: <%= submissionIdStr %></p>
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
        <!-- Student Info Card -->
        <div class="lg:col-span-1">
            <div class="card bg-base-100 shadow-xl border border-base-300">
                <div class="card-body">
                    <h3 class="card-title text-primary mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                        Student Information
                    </h3>

                    <div class="space-y-4">
                        <div class="flex items-center gap-3">
                            <div class="avatar placeholder">
                                <div class="bg-primary text-primary-content rounded-full w-16">
                                    <span class="text-2xl"><%= submission.getStudentName() != null ? submission.getStudentName().substring(0,1).toUpperCase() : "?" %></span>
                                </div>
                            </div>
                            <div>
                                <p class="font-bold text-lg"><%= submission.getStudentName() != null ? submission.getStudentName() : "Unknown" %></p>
                                <p class="text-sm text-base-content/70"><%= submission.getStudentEmail() != null ? submission.getStudentEmail() : "" %></p>
                            </div>
                        </div>

                        <div class="divider"></div>

                        <div>
                            <label class="text-sm font-semibold text-base-content/70">Submission Status</label>
                            <div class="badge badge-success badge-lg mt-2">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                Submitted
                            </div>
                        </div>

                        <div>
                            <label class="text-sm font-semibold text-base-content/70">Submitted At</label>
                            <p class="text-base-content font-medium"><%= submittedAtStr %></p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="card bg-base-100 shadow-xl border border-base-300 mt-6">
                <div class="card-body">
                    <h3 class="card-title text-primary text-sm mb-3">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                        </svg>
                        Quick Actions
                    </h3>

                    <div class="space-y-2">
                        <% if (!isGraded) { %>
                        <button type="button"
                                class="btn btn-success btn-block text-white"
                                onclick="openGradeModal()">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                            </svg>
                            Grade Submission
                        </button>
                        <% } else { %>
                        <button type="button"
                                class="btn btn-warning btn-block"
                                onclick="openGradeModal()">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                            </svg>
                            Update Grade
                        </button>
                        <% } %>

                        <button type="button"
                                class="btn btn-outline btn-block"
                                onclick="window.print()">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                            </svg>
                            Print
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Submission Content -->
        <div class="lg:col-span-2">
            <!-- Current Score Card (if graded) -->
            <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
                <div class="card-body">
                    <h3 class="card-title text-primary mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Grading Status
                    </h3>

                    <% if (isGraded) { %>
                    <div class="alert alert-success">
                        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <div>
                            <h4 class="font-bold">Graded</h4>
                            <p class="text-sm">This submission has been graded.</p>
                        </div>
                    </div>

                    <div class="divider"></div>

                    <div class="grid grid-cols-3 gap-4 mt-4">
                        <div class="stat bg-base-200 rounded-lg">
                            <div class="stat-title">Score</div>
                            <div class="stat-value text-primary"><%= submission.getScore() != null ? submission.getScore() : 0 %></div>
                            <div class="stat-desc">Out of 100</div>
                        </div>
                        <div class="stat bg-base-200 rounded-lg">
                            <div class="stat-title">Grade</div>
                            <div class="stat-value text-accent text-2xl">
                                <%= submission.getGradeSymbol() != null ? submission.getGradeSymbol() : "UNCATEGORIZED" %>
                            </div>
                            <div class="stat-desc">Grade Category</div>
                        </div>
                        <div class="stat bg-base-200 rounded-lg">
                            <div class="stat-title">Status</div>
                            <div class="stat-value text-success text-2xl">
                                <% if (submission.getScore() != null && submission.getScore() >= 50) { %>
                                PASS
                                <% } else { %>
                                FAIL
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <div class="mt-4">
                        <label class="text-sm font-semibold text-base-content/70">Feedback</label>
                        <div class="bg-base-200 p-4 rounded-lg mt-2">
                            <p class="text-base-content"><%= submission.getFeedbackText() != null ? submission.getFeedbackText() : "No feedback provided" %></p>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="alert alert-warning">
                        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                        <div>
                            <h4 class="font-bold">Not Graded Yet</h4>
                            <p class="text-sm">This submission has not been graded. Click "Grade Submission" to provide feedback and score.</p>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Submission Details -->
            <div class="card bg-base-100 shadow-xl border border-base-300">
                <div class="card-body">
                    <h3 class="card-title text-primary mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        Submission Content
                    </h3>

                    <% if (submission instanceof AssignmentSubmissionDTO) {
                        AssignmentSubmissionDTO assignmentSubmission = (AssignmentSubmissionDTO) submission;
                    %>
                    <div class="alert alert-info mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <span><strong>Type:</strong> Assignment Submission</span>
                    </div>

                    <div class="overflow-x-auto">
                        <h4 class="font-semibold mb-3">Submitted Files:</h4>
                        <% if (assignmentSubmission.getFilesSubmitted() != null && !assignmentSubmission.getFilesSubmitted().isEmpty()) { %>
                        <table class="table table-zebra w-full">
                            <thead>
                                <tr>
                                    <th>File Name</th>
                                    <th>Format</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (FileSubmittedDTO file : assignmentSubmission.getFilesSubmitted()) { %>
                                <tr>
                                    <td><%= file.getFileName() %></td>
                                    <td><span class="badge badge-primary"><%= file.getFileFormat() %></span></td>
                                    <td>
                                        <a href="<%= contextPath %>/api/download-file?fileId=<%= file.getId() %>"
                                           class="btn btn-sm btn-ghost">
                                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                                            </svg>
                                            Download
                                        </a>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } else { %>
                        <p class="text-base-content/50 text-center py-4">No files submitted</p>
                        <% } %>
                    </div>

                    <% } else if (submission instanceof QuizSubmissionDTO) {
                        QuizSubmissionDTO quizSubmission = (QuizSubmissionDTO) submission;
                    %>
                    <div class="alert alert-info mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <span><strong>Type:</strong> Quiz Submission</span>
                    </div>

                    <div class="grid grid-cols-3 gap-4 mb-6">
                        <div class="stat bg-base-200 rounded-lg">
                            <div class="stat-title">Total Questions</div>
                            <div class="stat-value text-primary"><%= quizSubmission.getTotalQuestions() != null ? quizSubmission.getTotalQuestions() : 0 %></div>
                        </div>
                        <div class="stat bg-base-200 rounded-lg">
                            <div class="stat-title">Correct Answers</div>
                            <div class="stat-value text-success"><%= quizSubmission.getCorrectAnswers() != null ? quizSubmission.getCorrectAnswers() : 0 %></div>
                        </div>
                        <div class="stat bg-base-200 rounded-lg">
                            <div class="stat-title">Score</div>
                            <div class="stat-value text-accent"><%= submission.getScore() != null ? submission.getScore() : 0 %>%</div>
                        </div>
                    </div>

                    <h4 class="font-semibold mb-3">Student's Answers:</h4>
                    <%
                        List<QuizIndividualQuestionDTO> quizQuestions = (List<QuizIndividualQuestionDTO>) request.getAttribute("quizQuestions");
                        if (quizQuestions != null && !quizQuestions.isEmpty() && quizSubmission.getSelectedOptions() != null) {
                            int questionNumber = 1;
                            for (QuizIndividualQuestionDTO question : quizQuestions) {
                                Integer selectedOption = quizSubmission.getSelectedOptions().get(question.getQuizQuestionId().intValue());
                                boolean isCorrect = selectedOption != null && selectedOption.equals(question.getCorrectAnswerIndex());
                    %>
                    <div class="card bg-base-200 border <%= isCorrect ? "border-success" : "border-error" %> mb-4">
                        <div class="card-body p-4">
                            <div class="flex items-start justify-between mb-3">
                                <h5 class="font-semibold text-base">
                                    Question <%= questionNumber++ %>: <%= question.getQuestionText() %>
                                </h5>
                                <% if (isCorrect) { %>
                                <span class="badge badge-success gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    Correct
                                </span>
                                <% } else { %>
                                <span class="badge badge-error gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                    </svg>
                                    Incorrect
                                </span>
                                <% } %>
                            </div>

                            <div class="space-y-2">
                                <%
                                    if (question.getOptions() != null) {
                                        for (int i = 0; i < question.getOptions().size(); i++) {
                                            String option = question.getOptions().get(i);
                                            boolean isStudentChoice = selectedOption != null && selectedOption == i;
                                            boolean isCorrectAnswer = i == question.getCorrectAnswerIndex();
                                            String optionClass = "";
                                            String icon = "";

                                            if (isStudentChoice && isCorrectAnswer) {
                                                optionClass = "bg-success text-success-content";
                                                icon = "✓";
                                            } else if (isStudentChoice && !isCorrectAnswer) {
                                                optionClass = "bg-error text-error-content";
                                                icon = "✗";
                                            } else if (!isStudentChoice && isCorrectAnswer) {
                                                optionClass = "bg-success/20 border border-success";
                                                icon = "✓";
                                            } else {
                                                optionClass = "bg-base-100";
                                            }
                                %>
                                <div class="flex items-center gap-2 p-3 rounded-lg <%= optionClass %>">
                                    <span class="font-semibold"><%= (char)('A' + i) %>.</span>
                                    <span class="flex-1"><%= option %></span>
                                    <% if (isStudentChoice || isCorrectAnswer) { %>
                                    <span class="font-bold text-lg"><%= icon %></span>
                                    <% } %>
                                    <% if (isStudentChoice && !isCorrectAnswer) { %>
                                    <span class="text-xs opacity-70">(Student's choice)</span>
                                    <% } else if (!isStudentChoice && isCorrectAnswer) { %>
                                    <span class="text-xs opacity-70">(Correct answer)</span>
                                    <% } %>
                                </div>
                                <%
                                        }
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div class="bg-base-200 p-4 rounded-lg">
                        <p class="text-base-content/50">No quiz questions or answers available</p>
                    </div>
                    <%
                        }
                    %>

                    <% } else { %>
                    <div class="text-center py-8 text-base-content/50">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        <p class="text-lg font-semibold">Submission ID: <%= submissionIdStr %></p>
                        <p class="text-sm mt-2">Unable to determine submission type</p>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Grading Modal -->
<dialog id="grade_modal" class="modal">
    <div class="modal-box max-w-2xl">
        <h3 class="font-bold text-lg mb-4"><%= isGraded ? "Update Grade" : "Grade Submission" %></h3>

        <form method="POST" action="<%= contextPath %>/api/grade-submission">
            <input type="hidden" name="submissionId" value="<%= submissionIdStr %>">

            <div class="form-control mb-4">
                <label class="label">
                    <span class="label-text font-semibold">Score (0-100)</span>
                </label>
                <input type="number"
                       name="score"
                       min="0"
                       max="100"
                       class="input input-bordered"
                       placeholder="Enter score"
                       value="<%= isGraded && submission.getScore() != null ? submission.getScore() : "" %>"
                       required>
            </div>

            <div class="form-control mb-4">
                <label class="label">
                    <span class="label-text font-semibold">Feedback</span>
                </label>
                <textarea name="feedback"
                          class="textarea textarea-bordered h-32"
                          placeholder="Provide feedback to the student..."
                          required><%= isGraded && submission.getFeedbackText() != null ? submission.getFeedbackText() : "" %></textarea>
            </div>

            <div class="modal-action">
                <button type="button" class="btn" onclick="document.getElementById('grade_modal').close()">Cancel</button>
                <button type="submit" class="btn btn-success text-white">
                    <%= isGraded ? "Update Grade" : "Submit Grade" %>
                </button>
            </div>
        </form>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>

<script>
    function openGradeModal() {
        document.getElementById('grade_modal').showModal();
    }
</script>

