<%@ page import="com.htetaung.lms.servlets.AcademicLeaderReportServlet.LecturerPerformance" %>
<%@ page import="java.util.List" %>
<%
    List<LecturerPerformance> lecturerPerformances = (List<LecturerPerformance>) request.getAttribute("lecturerPerformances");
    if (lecturerPerformances == null) lecturerPerformances = new java.util.ArrayList<>();
%>

<div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
    <div class="card-body">
        <h2 class="card-title text-2xl mb-4">Lecturer Performance Report</h2>
        <p class="text-base-content/70 mb-6">Comprehensive overview of lecturer teaching effectiveness and grading efficiency</p>

        <!-- Lecturer Performance Table -->
        <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
                <thead>
                    <tr>
                        <th>Lecturer Name</th>
                        <th>Email</th>
                        <th>Classes</th>
                        <th>Students</th>
                        <th>Assessments</th>
                        <th>Submissions</th>
                        <th>Graded</th>
                        <th>Pending</th>
                        <th>Grading Rate</th>
                        <th>Avg Score</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (lecturerPerformances.isEmpty()) { %>
                    <tr>
                        <td colspan="10" class="text-center text-base-content/60 py-8">No lecturer data available</td>
                    </tr>
                    <% } else { %>
                        <% for (LecturerPerformance perf : lecturerPerformances) { %>
                        <tr>
                            <td class="font-semibold"><%= perf.lecturerName %></td>
                            <td class="text-sm"><%= perf.lecturerEmail %></td>
                            <td><span class="badge badge-primary"><%= perf.totalClasses %></span></td>
                            <td><span class="badge badge-info"><%= perf.totalStudents %></span></td>
                            <td><span class="badge badge-secondary"><%= perf.totalAssessments %></span></td>
                            <td><span class="badge badge-ghost"><%= perf.totalSubmissions %></span></td>
                            <td><span class="badge badge-success"><%= perf.gradedSubmissions %></span></td>
                            <td><span class="badge badge-warning"><%= perf.pendingSubmissions %></span></td>
                            <td>
                                <div class="flex items-center gap-2">
                                    <progress class="progress <%= perf.gradingRate >= 80 ? "progress-success" : perf.gradingRate >= 50 ? "progress-warning" : "progress-error" %> w-16" value="<%= perf.gradingRate %>" max="100"></progress>
                                    <span class="text-xs"><%= String.format("%.0f", perf.gradingRate) %>%</span>
                                </div>
                            </td>
                            <td><span class="badge <%= perf.averageScore >= 70 ? "badge-success" : perf.averageScore >= 50 ? "badge-warning" : "badge-error" %>"><%= String.format("%.1f", perf.averageScore) %>%</span></td>
                        </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>

        <% if (!lecturerPerformances.isEmpty()) { %>
        <!-- Summary Statistics -->
        <div class="divider my-6">Summary Statistics</div>
        <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
            <%
                int totalLecturers = lecturerPerformances.size();
                int totalClasses = 0;
                int totalStudents = 0;
                int totalSubmissions = 0;
                int totalGraded = 0;
                double avgGradingRate = 0;

                for (LecturerPerformance perf : lecturerPerformances) {
                    totalClasses += perf.totalClasses;
                    totalStudents += perf.totalStudents;
                    totalSubmissions += perf.totalSubmissions;
                    totalGraded += perf.gradedSubmissions;
                    avgGradingRate += perf.gradingRate;
                }

                if (totalLecturers > 0) {
                    avgGradingRate /= totalLecturers;
                }
            %>
            <div class="stat bg-base-200 rounded-lg p-4">
                <div class="stat-title">Total Lecturers</div>
                <div class="stat-value text-2xl"><%= totalLecturers %></div>
            </div>
            <div class="stat bg-primary/10 rounded-lg p-4">
                <div class="stat-title">Total Classes</div>
                <div class="stat-value text-2xl text-primary"><%= totalClasses %></div>
            </div>
            <div class="stat bg-info/10 rounded-lg p-4">
                <div class="stat-title">Total Students</div>
                <div class="stat-value text-2xl text-info"><%= totalStudents %></div>
            </div>
            <div class="stat bg-secondary/10 rounded-lg p-4">
                <div class="stat-title">Total Submissions</div>
                <div class="stat-value text-2xl text-secondary"><%= totalSubmissions %></div>
            </div>
            <div class="stat bg-success/10 rounded-lg p-4">
                <div class="stat-title">Avg Grading Rate</div>
                <div class="stat-value text-2xl text-success"><%= String.format("%.1f", avgGradingRate) %>%</div>
            </div>
        </div>

        <!-- Top Performers -->
        <div class="divider my-6">Top Performing Lecturers</div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <%
                List<LecturerPerformance> topByGrading = new java.util.ArrayList<>(lecturerPerformances);
                topByGrading.sort((a, b) -> Double.compare(b.gradingRate, a.gradingRate));

                List<LecturerPerformance> topByScore = new java.util.ArrayList<>(lecturerPerformances);
                topByScore.sort((a, b) -> Double.compare(b.averageScore, a.averageScore));
            %>

            <div class="card bg-success/10 border border-success">
                <div class="card-body p-4">
                    <h3 class="font-bold text-success mb-2">🏆 Best Grading Rate</h3>
                    <% if (!topByGrading.isEmpty()) {
                        LecturerPerformance top = topByGrading.get(0);
                    %>
                        <p class="font-semibold"><%= top.lecturerName %></p>
                        <p class="text-sm text-success"><%= String.format("%.1f", top.gradingRate) %>% grading rate</p>
                    <% } %>
                </div>
            </div>

            <div class="card bg-warning/10 border border-warning">
                <div class="card-body p-4">
                    <h3 class="font-bold text-warning mb-2">⭐ Best Average Score</h3>
                    <% if (!topByScore.isEmpty()) {
                        LecturerPerformance top = topByScore.get(0);
                    %>
                        <p class="font-semibold"><%= top.lecturerName %></p>
                        <p class="text-sm text-warning"><%= String.format("%.1f", top.averageScore) %>% average score</p>
                    <% } %>
                </div>
            </div>

            <div class="card bg-info/10 border border-info">
                <div class="card-body p-4">
                    <h3 class="font-bold text-info mb-2">📚 Most Active</h3>
                    <%
                        List<LecturerPerformance> topByClasses = new java.util.ArrayList<>(lecturerPerformances);
                        topByClasses.sort((a, b) -> Integer.compare(b.totalClasses, a.totalClasses));
                        if (!topByClasses.isEmpty()) {
                            LecturerPerformance top = topByClasses.get(0);
                    %>
                        <p class="font-semibold"><%= top.lecturerName %></p>
                        <p class="text-sm text-info"><%= top.totalClasses %> classes taught</p>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</div>

