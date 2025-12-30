<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<ModuleDTO> managedModules = (List<ModuleDTO>) request.getAttribute("managedModules");
    List<ClassDTO> allClasses = (List<ClassDTO>) request.getAttribute("allClasses");
    List<LecturerDTO> lecturers = (List<LecturerDTO>) request.getAttribute("lecturers");
    List<StudentDTO> students = (List<StudentDTO>) request.getAttribute("students");
    List<AssessmentDTO> allAssessments = (List<AssessmentDTO>) request.getAttribute("allAssessments");
    Map<Long, List<SubmissionDTO>> assessmentSubmissions = (Map<Long, List<SubmissionDTO>>) request.getAttribute("assessmentSubmissions");

    Integer totalModules = (Integer) request.getAttribute("totalModules");
    Integer totalClasses = (Integer) request.getAttribute("totalClasses");
    Integer totalLecturers = (Integer) request.getAttribute("totalLecturers");
    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    Integer totalAssessments = (Integer) request.getAttribute("totalAssessments");
    Integer totalSubmissions = (Integer) request.getAttribute("totalSubmissions");
    Integer gradedSubmissions = (Integer) request.getAttribute("gradedSubmissions");
    Integer pendingSubmissions = (Integer) request.getAttribute("pendingSubmissions");
    Double averageScore = (Double) request.getAttribute("averageScore");

    String contextPath = request.getContextPath();
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");

    if (managedModules == null) managedModules = new ArrayList<>();
    if (allClasses == null) allClasses = new ArrayList<>();
    if (lecturers == null) lecturers = new ArrayList<>();
    if (students == null) students = new ArrayList<>();
    if (allAssessments == null) allAssessments = new ArrayList<>();
    if (assessmentSubmissions == null) assessmentSubmissions = new HashMap<>();
    if (totalModules == null) totalModules = 0;
    if (totalClasses == null) totalClasses = 0;
    if (totalLecturers == null) totalLecturers = 0;
    if (totalStudents == null) totalStudents = 0;
    if (totalAssessments == null) totalAssessments = 0;
    if (totalSubmissions == null) totalSubmissions = 0;
    if (gradedSubmissions == null) gradedSubmissions = 0;
    if (pendingSubmissions == null) pendingSubmissions = 0;
    if (averageScore == null) averageScore = 0.0;
%>

<div class="container mx-auto p-6">
    <!-- Header -->
    <div class="pb-6 flex justify-between items-center">
        <div>
            <h1 class="font-title font-bold text-4xl text-base-content">Academic Reports</h1>
            <p class="text-base-content/70 mt-2 text-lg">Comprehensive stakeholder information and analytics</p>
        </div>
        <button onclick="window.print()" class="btn btn-primary">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
            </svg>
            Print Report
        </button>
    </div>

    <!-- Summary Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-6 mb-8">
        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                </div>
                <div class="stat-title">Modules</div>
                <div class="stat-value text-primary"><%= totalModules %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                </div>
                <div class="stat-title">Classes</div>
                <div class="stat-value text-secondary"><%= totalClasses %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-accent">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                </div>
                <div class="stat-title">Lecturers</div>
                <div class="stat-value text-accent"><%= totalLecturers %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-info">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path d="M12 14l9-5-9-5-9 5 9 5z" />
                        <path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222" />
                    </svg>
                </div>
                <div class="stat-title">Students</div>
                <div class="stat-value text-info"><%= totalStudents %></div>
            </div>
        </div>

        <div class="stats shadow border border-base-300">
            <div class="stat">
                <div class="stat-figure text-warning">
                    <svg xmlns="http://www.w3.org/2000/svg" class="inline-block w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                    </svg>
                </div>
                <div class="stat-title">Avg Score</div>
                <div class="stat-value text-warning"><%= String.format("%.1f", averageScore) %></div>
            </div>
        </div>
    </div>

    <!-- Assessment Performance -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
        <div class="card-body">
            <h2 class="card-title text-2xl mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
                Assessment & Submission Overview
            </h2>
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div class="stat bg-base-200 rounded-lg p-4">
                    <div class="stat-title">Total Assessments</div>
                    <div class="stat-value text-2xl"><%= totalAssessments %></div>
                </div>
                <div class="stat bg-base-200 rounded-lg p-4">
                    <div class="stat-title">Total Submissions</div>
                    <div class="stat-value text-2xl"><%= totalSubmissions %></div>
                </div>
                <div class="stat bg-success/20 rounded-lg p-4">
                    <div class="stat-title">Graded</div>
                    <div class="stat-value text-2xl text-success"><%= gradedSubmissions %></div>
                </div>
                <div class="stat bg-warning/20 rounded-lg p-4">
                    <div class="stat-title">Pending</div>
                    <div class="stat-value text-2xl text-warning"><%= pendingSubmissions %></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabs for Different Reports -->
    <div class="tabs tabs-boxed mb-4">
        <a class="tab tab-active" onclick="showTab('modules')">Modules</a>
        <a class="tab" onclick="showTab('classes')">Classes</a>
        <a class="tab" onclick="showTab('lecturers')">Lecturers</a>
        <a class="tab" onclick="showTab('students')">Students</a>
        <a class="tab" onclick="showTab('assessments')">Assessments</a>
    </div>

    <!-- Modules Report -->
    <div id="modules-tab" class="tab-content">
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">Modules Report</h2>
                <div class="overflow-x-auto">
                    <table class="table table-zebra w-full">
                        <thead>
                            <tr>
                                <th>Module Name</th>
                                <th>Managed By</th>
                                <th>Classes</th>
                                <th>Students Enrolled</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (ModuleDTO module : managedModules) {
                                int classCount = 0;
                                int studentCount = 0;
                                for (ClassDTO classDTO : allClasses) {
                                    if (classDTO.moduleDTO != null && classDTO.moduleDTO.moduleId.equals(module.moduleId)) {
                                        classCount++;
                                        studentCount += classDTO.students != null ? classDTO.students.size() : 0;
                                    }
                                }
                            %>
                            <tr>
                                <td class="font-semibold"><%= module.moduleName %></td>
                                <td><%= module.managedBy != null ? module.managedBy.fullname : "Unassigned" %></td>
                                <td><span class="badge badge-primary"><%= classCount %></span></td>
                                <td><span class="badge badge-info"><%= studentCount %></span></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Classes Report -->
    <div id="classes-tab" class="tab-content hidden">
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">Classes Report</h2>
                <div class="overflow-x-auto">
                    <table class="table table-zebra w-full">
                        <thead>
                            <tr>
                                <th>Class Name</th>
                                <th>Module</th>
                                <th>Students</th>
                                <th>Assessments</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (ClassDTO classDTO : allClasses) {
                                int assessmentCount = 0;
                                for (AssessmentDTO assessment : allAssessments) {
                                    if (assessment.getRelatedClass() != null && assessment.getRelatedClass().classId.equals(classDTO.classId)) {
                                        assessmentCount++;
                                    }
                                }
                            %>
                            <tr>
                                <td class="font-semibold"><%= classDTO.className %></td>
                                <td><%= classDTO.moduleDTO != null ? classDTO.moduleDTO.moduleName : "N/A" %></td>
                                <td><span class="badge badge-info"><%= classDTO.students != null ? classDTO.students.size() : 0 %></span></td>
                                <td><span class="badge badge-secondary"><%= assessmentCount %></span></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Lecturers Report -->
    <div id="lecturers-tab" class="tab-content hidden">
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">Lecturers Report</h2>
                <div class="overflow-x-auto">
                    <table class="table table-zebra w-full">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Modules Managed</th>
                                <th>Classes</th>
                                <th>Students</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (LecturerDTO lecturer : lecturers) {
                                int moduleCount = 0;
                                int classCount = 0;
                                Set<Long> studentSet = new HashSet<>();

                                for (ModuleDTO module : managedModules) {
                                    if (module.managedBy != null && module.managedBy.userId.equals(lecturer.userId)) {
                                        moduleCount++;
                                        for (ClassDTO classDTO : allClasses) {
                                            if (classDTO.moduleDTO != null && classDTO.moduleDTO.moduleId.equals(module.moduleId)) {
                                                classCount++;
                                                if (classDTO.students != null) {
                                                    for (StudentDTO student : classDTO.students) {
                                                        studentSet.add(student.userId);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            %>
                            <tr>
                                <td class="font-semibold"><%= lecturer.fullname %></td>
                                <td><span class="badge badge-primary"><%= moduleCount %></span></td>
                                <td><span class="badge badge-secondary"><%= classCount %></span></td>
                                <td><span class="badge badge-info"><%= studentSet.size() %></span></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Students Report -->
    <div id="students-tab" class="tab-content hidden">
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">Students Report</h2>
                <div class="overflow-x-auto">
                    <table class="table table-zebra w-full">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Classes Enrolled</th>
                                <th>Submissions</th>
                                <th>Avg Score</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (StudentDTO student : students) {
                                int enrolledCount = 0;
                                int submissionCount = 0;
                                double totalScore = 0;
                                int scoredCount = 0;

                                for (ClassDTO classDTO : allClasses) {
                                    if (classDTO.students != null) {
                                        for (StudentDTO s : classDTO.students) {
                                            if (s.userId.equals(student.userId)) {
                                                enrolledCount++;
                                                break;
                                            }
                                        }
                                    }
                                }

                                for (List<SubmissionDTO> submissions : assessmentSubmissions.values()) {
                                    for (SubmissionDTO sub : submissions) {
                                        if (sub.getStudentId() != null && sub.getStudentId().equals(student.userId)) {
                                            submissionCount++;
                                            if (sub.getScore() != null && sub.getScore() > 0) {
                                                totalScore += sub.getScore();
                                                scoredCount++;
                                            }
                                        }
                                    }
                                }

                                double avgScore = scoredCount > 0 ? totalScore / scoredCount : 0;
                            %>
                            <tr>
                                <td class="font-semibold"><%= student.fullname %></td>
                                <td><%= student.email %></td>
                                <td><span class="badge badge-primary"><%= enrolledCount %></span></td>
                                <td><span class="badge badge-secondary"><%= submissionCount %></span></td>
                                <td><span class="badge badge-success"><%= String.format("%.1f", avgScore) %></span></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Assessments Report -->
    <div id="assessments-tab" class="tab-content hidden">
        <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
                <h2 class="card-title text-2xl mb-4">Assessments Report</h2>
                <div class="overflow-x-auto">
                    <table class="table table-zebra w-full">
                        <thead>
                            <tr>
                                <th>Assessment</th>
                                <th>Class</th>
                                <th>Type</th>
                                <th>Deadline</th>
                                <th>Submissions</th>
                                <th>Avg Score</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (AssessmentDTO assessment : allAssessments) {
                                List<SubmissionDTO> submissions = assessmentSubmissions.get(assessment.getAssessmentId());
                                int subCount = submissions != null ? submissions.size() : 0;
                                double totalScore = 0;
                                int scoredCount = 0;

                                if (submissions != null) {
                                    for (SubmissionDTO sub : submissions) {
                                        if (sub.getScore() != null && sub.getScore() > 0) {
                                            totalScore += sub.getScore();
                                            scoredCount++;
                                        }
                                    }
                                }

                                double avgScore = scoredCount > 0 ? totalScore / scoredCount : 0;
                            %>
                            <tr>
                                <td class="font-semibold"><%= assessment.getAssessmentName() %></td>
                                <td><%= assessment.getRelatedClass() != null ? assessment.getRelatedClass().className : "N/A" %></td>
                                <td><span class="badge <%= assessment.getAssessmentType().toString().equals("QUIZ") ? "badge-secondary" : "badge-accent" %>"><%= assessment.getAssessmentType() %></span></td>
                                <td><%= assessment.getDeadline() != null ? dateFormat.format(assessment.getDeadline()) : "N/A" %></td>
                                <td><span class="badge badge-info"><%= subCount %></span></td>
                                <td><span class="badge badge-success"><%= String.format("%.1f", avgScore) %></span></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function showTab(tabName) {
    // Hide all tabs
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.add('hidden');
    });

    // Remove active class from all tab buttons
    document.querySelectorAll('.tab').forEach(tab => {
        tab.classList.remove('tab-active');
    });

    // Show selected tab
    document.getElementById(tabName + '-tab').classList.remove('hidden');

    // Add active class to clicked tab
    event.target.classList.add('tab-active');
}
</script>

<style>
@media print {
    .navbar, .drawer, .btn, .tabs {
        display: none !important;
    }

    .tab-content {
        display: block !important;
    }
}
</style>

