<%@ page import="com.htetaung.lms.servlets.AcademicLeaderReportServlet.StudentPerformance" %>
<%@ page import="java.util.List" %>
<%
    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    Integer studentsWithSubmissions = (Integer) request.getAttribute("studentsWithSubmissions");
    Integer passedStudents = (Integer) request.getAttribute("passedStudents");
    Integer failedStudents = (Integer) request.getAttribute("failedStudents");
    Double overallAverage = (Double) request.getAttribute("overallAverage");
    Double passRate = (Double) request.getAttribute("passRate");
    List<StudentPerformance> studentPerformances = (List<StudentPerformance>) request.getAttribute("studentPerformances");

    if (totalStudents == null) totalStudents = 0;
    if (studentsWithSubmissions == null) studentsWithSubmissions = 0;
    if (passedStudents == null) passedStudents = 0;
    if (failedStudents == null) failedStudents = 0;
    if (overallAverage == null) overallAverage = 0.0;
    if (passRate == null) passRate = 0.0;
    if (studentPerformances == null) studentPerformances = new java.util.ArrayList<>();
%>

<div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
    <div class="card-body">
        <h2 class="card-title text-2xl mb-4">University-Wide Student Performance Report</h2>

        <!-- Summary Statistics -->
        <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-6">
            <div class="stat bg-base-200 rounded-lg p-4">
                <div class="stat-title">Total Students</div>
                <div class="stat-value text-2xl"><%= totalStudents %></div>
            </div>
            <div class="stat bg-info/20 rounded-lg p-4">
                <div class="stat-title">With Submissions</div>
                <div class="stat-value text-2xl text-info"><%= studentsWithSubmissions %></div>
            </div>
            <div class="stat bg-success/20 rounded-lg p-4">
                <div class="stat-title">Passed (≥50%)</div>
                <div class="stat-value text-2xl text-success"><%= passedStudents %></div>
            </div>
            <div class="stat bg-error/20 rounded-lg p-4">
                <div class="stat-title">Failed (<50%)</div>
                <div class="stat-value text-2xl text-error"><%= failedStudents %></div>
            </div>
            <div class="stat bg-warning/20 rounded-lg p-4">
                <div class="stat-title">Overall Average</div>
                <div class="stat-value text-2xl text-warning"><%= String.format("%.1f", overallAverage) %>%</div>
            </div>
            <div class="stat bg-primary/20 rounded-lg p-4">
                <div class="stat-title">Pass Rate</div>
                <div class="stat-value text-2xl text-primary"><%= String.format("%.1f", passRate) %>%</div>
            </div>
        </div>

        <!-- Performance Chart Placeholder -->
        <div class="alert alert-info mb-6">
            <img src="<%= request.getContextPath() %>/images/icons/info-circle.png"
                 alt="Info" class="w-6 h-6 shrink-0">
            <div>
                <h3 class="font-bold">Performance Distribution</h3>
                <div class="text-xs">Pass Rate: <%= String.format("%.1f", passRate) %>% | Average Score: <%= String.format("%.1f", overallAverage) %>%</div>
            </div>
        </div>

        <!-- Student Details Table -->
        <h3 class="font-bold text-xl mb-3">Student Performance Details</h3>
        <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
                <thead>
                    <tr>
                        <th>Student Name</th>
                        <th>Email</th>
                        <th>Submissions</th>
                        <th>Graded</th>
                        <th>Average Score</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (studentPerformances.isEmpty()) { %>
                    <tr>
                        <td colspan="6" class="text-center text-base-content/60 py-8">No student performance data available</td>
                    </tr>
                    <% } else { %>
                        <% for (StudentPerformance perf : studentPerformances) { %>
                        <tr>
                            <td class="font-semibold"><%= perf.studentName %></td>
                            <td><%= perf.studentEmail %></td>
                            <td><span class="badge badge-ghost"><%= perf.totalSubmissions %></span></td>
                            <td><span class="badge badge-info"><%= perf.gradedSubmissions %></span></td>
                            <td><span class="badge <%= perf.averageScore >= 80 ? "badge-success" : perf.averageScore >= 50 ? "badge-warning" : "badge-error" %>"><%= String.format("%.1f", perf.averageScore) %>%</span></td>
                            <td><span class="badge <%= "Passed".equals(perf.status) ? "badge-success" : "badge-error" %>"><%= perf.status %></span></td>
                        </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

