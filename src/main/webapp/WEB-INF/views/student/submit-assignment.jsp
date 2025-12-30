<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.AssessmentDTO" %>
<%@ page import="com.htetaung.lms.models.enums.FileFormats" %>
<%@ page import="java.util.List" %>
<%
    AssessmentDTO assessment = (AssessmentDTO) request.getAttribute("assessment");
    String contextPath = request.getContextPath();
    Long studentId = (Long) request.getSession().getAttribute("userId");

    if (assessment == null) {
        response.sendRedirect(contextPath + "/index.jsp?page=assignments");
        return;
    }
%>

<div class="container mx-auto p-6">
    <!-- Header Section -->
    <div class="flex items-center justify-between pb-3 pt-3">
        <div>
            <h2 class="font-title font-bold text-3xl text-base-content">Submit Assignment</h2>
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
        <!-- Assignment Details Card -->
        <div class="lg:col-span-1">
            <div class="card bg-base-100 shadow-xl border border-base-300 sticky top-6">
                <div class="card-body">
                    <h3 class="card-title text-primary mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Assignment Details
                    </h3>

                    <div class="space-y-4">
                        <div>
                            <label class="text-sm font-semibold text-base-content/70">Class</label>
                            <p class="text-base-content font-medium"><%= assessment.getRelatedClass().className %></p>
                        </div>

                        <div>
                            <label class="text-sm font-semibold text-base-content/70">Module</label>
                            <p class="text-base-content font-medium"><%= assessment.getRelatedClass().moduleDTO.moduleName %></p>
                        </div>

                        <div>
                            <label class="text-sm font-semibold text-base-content/70">Deadline</label>
                            <p class="text-error font-bold">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(assessment.getDeadline()) %>
                            </p>
                        </div>

                        <div class="divider"></div>

                        <div>
                            <label class="text-sm font-semibold text-base-content/70 mb-2 block">Description</label>
                            <div class="bg-base-200 p-3 rounded-lg">
                                <p class="text-sm text-base-content"><%= assessment.getAssessmentDescription() %></p>
                            </div>
                        </div>

                        <div class="alert alert-info">
                            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <span class="text-sm">Make sure to submit before the deadline!</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Submission Form Card -->
        <div class="lg:col-span-2">
            <div class="card bg-base-100 shadow-xl border border-base-300">
                <div class="card-body">
                    <h3 class="card-title text-primary mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        Submit Your Work
                    </h3>

                    <form action="<%= contextPath %>/api/submit-assignment" method="POST" enctype="multipart/form-data" class="space-y-6">
                        <input type="hidden" name="assessmentId" value="<%= assessment.getAssessmentId() %>">
                        <input type="hidden" name="studentId" value="<%= studentId %>">

                        <!-- File Upload Section -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text font-semibold text-lg">Upload Your Files <span class="text-error">*</span></span>
                            </label>
                            <input type="file"
                                   name="submissionFiles"
                                   class="file-input file-input-bordered file-input-primary w-full"
                                   required
                                   multiple
                                   id="fileInput"
                                   accept="<%= request.getAttribute("acceptFormats") != null ? request.getAttribute("acceptFormats") : "*/*" %>">
                            <label class="label">
                                <span class="label-text-alt text-base-content/70">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    Allowed formats:
                                    <%
                                        // Get allowed formats from assessment DTO
                                        String allowedFormatsStr = "All formats";
                                        String acceptFormats = "*/*";
                                        if (assessment.getAllowedFileFormats() != null && !assessment.getAllowedFileFormats().isEmpty()) {
                                            allowedFormatsStr = assessment.getAllowedFileFormats().stream()
                                                .map(FileFormats::name)
                                                .collect(java.util.stream.Collectors.joining(", "));
                                            // Create accept attribute for file input
                                            acceptFormats = assessment.getAllowedFileFormats().stream()
                                                .map(f -> {
                                                    switch(f) {
                                                        case PDF: return ".pdf";
                                                        case DOCX: return ".doc,.docx";
                                                        case TXT: return ".txt";
                                                        case ZIP: return ".zip";
                                                        case RAR: return ".rar";
                                                        default: return "";
                                                    }
                                                })
                                                .filter(s -> !s.isEmpty())
                                                .collect(java.util.stream.Collectors.joining(","));
                                        }
                                        request.setAttribute("acceptFormats", acceptFormats);
                                        request.setAttribute("allowedFormatsDisplay", allowedFormatsStr);
                                    %>
                                    <strong><%= allowedFormatsStr %></strong> | Max size per file: 10MB | Multiple files allowed
                                </span>
                            </label>
                            <!-- Selected files preview -->
                            <div id="fileList" class="mt-2 space-y-2"></div>
                        </div>

                        <!-- Comments/Notes Section -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text font-semibold text-lg">Comments (Optional)</span>
                            </label>
                            <textarea name="comments"
                                      class="textarea textarea-bordered textarea-lg h-32"
                                      placeholder="Add any comments or notes about your submission..."></textarea>
                            <label class="label">
                                <span class="label-text-alt text-base-content/70">Any additional information you'd like to share with your instructor</span>
                            </label>
                        </div>

                        <!-- Submission Guidelines -->
                        <div class="alert alert-warning">
                            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                            <div>
                                <h4 class="font-bold">Before Submitting:</h4>
                                <ul class="list-disc list-inside text-sm mt-2">
                                    <li>Double-check your file for completeness</li>
                                    <li>Ensure your name is on your work</li>
                                    <li>Verify the file format is correct</li>
                                    <li>Once submitted, you cannot edit your submission</li>
                                </ul>
                            </div>
                        </div>

                        <!-- Academic Integrity Checkbox -->
                        <div class="form-control">
                            <label class="label cursor-pointer justify-start gap-3">
                                <input type="checkbox" name="academicIntegrity" class="checkbox checkbox-primary" required>
                                <span class="label-text">
                                    I certify that this submission is my own work and I have not plagiarized or cheated in any way
                                    <span class="text-error">*</span>
                                </span>
                            </label>
                        </div>

                        <div class="divider"></div>

                        <!-- Action Buttons -->
                        <div class="flex justify-end gap-3">
                            <button type="button"
                                    class="btn btn-ghost"
                                    onclick="window.history.back()">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                </svg>
                                Cancel
                            </button>
                            <button type="submit" class="btn btn-success text-white">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                Submit Assignment
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // File upload handling with preview
    const fileInput = document.getElementById('fileInput');
    const fileList = document.getElementById('fileList');
    const maxSize = 10 * 1024 * 1024; // 10MB in bytes

    fileInput.addEventListener('change', function(e) {
        const files = Array.from(e.target.files);
        fileList.innerHTML = '';

        if (files.length === 0) {
            return;
        }

        let hasError = false;
        files.forEach((file, index) => {
            const fileDiv = document.createElement('div');
            fileDiv.className = 'flex items-center justify-between p-3 bg-base-200 rounded-lg';

            const fileInfo = document.createElement('div');
            fileInfo.className = 'flex items-center gap-3';

            // File icon
            const icon = document.createElement('svg');
            icon.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
            icon.className = 'h-6 w-6 text-primary';
            icon.setAttribute('fill', 'none');
            icon.setAttribute('viewBox', '0 0 24 24');
            icon.setAttribute('stroke', 'currentColor');
            icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />';

            const textDiv = document.createElement('div');
            const fileName = document.createElement('div');
            fileName.className = 'font-semibold text-sm';
            fileName.textContent = file.name;

            const fileSize = document.createElement('div');
            fileSize.className = 'text-xs text-base-content/70';
            fileSize.textContent = formatFileSize(file.size);

            // Check file size
            if (file.size > maxSize) {
                fileSize.className = 'text-xs text-error font-bold';
                fileSize.textContent = 'File too large! ' + formatFileSize(file.size);
                hasError = true;
            }

            textDiv.appendChild(fileName);
            textDiv.appendChild(fileSize);
            fileInfo.appendChild(icon);
            fileInfo.appendChild(textDiv);
            fileDiv.appendChild(fileInfo);

            // Status badge
            const badge = document.createElement('span');
            badge.className = file.size <= maxSize ? 'badge badge-success' : 'badge badge-error';
            badge.textContent = file.size <= maxSize ? 'Ready' : 'Too Large';
            fileDiv.appendChild(badge);

            fileList.appendChild(fileDiv);
        });

        if (hasError) {
            alert('Some files exceed the 10MB size limit. Please remove or replace them before submitting.');
        }
    });

    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    }

    // Confirm before submission
    document.querySelector('form').addEventListener('submit', function(e) {
        const files = fileInput.files;

        // Check if any file exceeds size limit
        for (let file of files) {
            if (file.size > maxSize) {
                alert('Please remove files that exceed the 10MB size limit before submitting.');
                e.preventDefault();
                return;
            }
        }

        if (!confirm('Are you sure you want to submit this assignment with ' + files.length + ' file(s)? You will not be able to edit it after submission.')) {
            e.preventDefault();
        }
    });
</script>

