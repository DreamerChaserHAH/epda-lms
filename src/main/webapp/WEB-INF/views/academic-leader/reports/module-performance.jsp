<%@ page import="com.htetaung.lms.servlets.AcademicLeaderReportServlet.ModulePerformance" %>
<%@ page import="java.util.List" %>
<%
    List<ModulePerformance> modulePerformances = (List<ModulePerformance>) request.getAttribute("modulePerformances");
    if (modulePerformances == null) modulePerformances = new java.util.ArrayList<>();
%>

<div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
    <div class="card-body">
        <h2 class="card-title text-2xl mb-4">Module Performance Report</h2>
        <p class="text-base-content/70 mb-6">Detailed performance analysis for each module across semesters</p>

        <!-- Module Performance Table -->
        <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
                <thead>
                    <tr>
                        <th>Module Name</th>
                        <th>Managed By</th>
                        <th>Classes</th>
                        <th>Students</th>
                        <th>Assessments</th>
                        <th>Average Score</th>
                        <th>Performance Trend</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (modulePerformances.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="text-center text-base-content/60 py-8">No module data available</td>
                    </tr>
                    <% } else { %>
                        <% for (ModulePerformance perf : modulePerformances) { %>
                        <tr>
                            <td class="font-semibold"><%= perf.moduleName %></td>
                            <td><%= perf.managedBy %></td>
                            <td><span class="badge badge-primary"><%= perf.totalClasses %></span></td>
                            <td><span class="badge badge-info"><%= perf.totalStudents %></span></td>
                            <td><span class="badge badge-secondary"><%= perf.totalAssessments %></span></td>
                            <td>
                                <span class="badge badge-lg <%= perf.averageScore >= 70 ? "badge-success" : perf.averageScore >= 50 ? "badge-warning" : "badge-error" %>">
                                    <%= String.format("%.1f", perf.averageScore) %>%
                                </span>
                            </td>
                            <td>
                                <div class="flex items-center gap-2">
                                    <progress class="progress <%= perf.averageScore >= 70 ? "progress-success" : perf.averageScore >= 50 ? "progress-warning" : "progress-error" %> w-24" value="<%= perf.averageScore %>" max="100"></progress>
                                    <%
                                        String trend = "stable";
                                        String trendIcon = "→";
                                        String trendColor = "text-base-content";

                                        if (perf.averageScore >= 70) {
                                            trend = "improving";
                                            trendIcon = "↑";
                                            trendColor = "text-success";
                                        } else if (perf.averageScore < 50) {
                                            trend = "needs attention";
                                            trendIcon = "↓";
                                            trendColor = "text-error";
                                        }
                                    %>
                                    <span class="text-xl <%= trendColor %>"><%= trendIcon %></span>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>

        <% if (!modulePerformances.isEmpty()) { %>
        <!-- Module Statistics -->
        <div class="divider my-6">Overall Module Statistics</div>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <%
                int totalModules = modulePerformances.size();
                int totalClasses = 0;
                int totalStudents = 0;
                double avgModuleScore = 0;
                int excellentModules = 0;
                int goodModules = 0;
                int needsImprovement = 0;

                for (ModulePerformance perf : modulePerformances) {
                    totalClasses += perf.totalClasses;
                    totalStudents += perf.totalStudents;
                    avgModuleScore += perf.averageScore;

                    if (perf.averageScore >= 70) {
                        excellentModules++;
                    } else if (perf.averageScore >= 50) {
                        goodModules++;
                    } else {
                        needsImprovement++;
                    }
                }

                if (totalModules > 0) {
                    avgModuleScore /= totalModules;
                }
            %>
            <div class="stat bg-base-200 rounded-lg p-4">
                <div class="stat-title">Total Modules</div>
                <div class="stat-value text-2xl"><%= totalModules %></div>
            </div>
            <div class="stat bg-primary/10 rounded-lg p-4">
                <div class="stat-title">Total Classes</div>
                <div class="stat-value text-2xl text-primary"><%= totalClasses %></div>
            </div>
            <div class="stat bg-info/10 rounded-lg p-4">
                <div class="stat-title">Total Students</div>
                <div class="stat-value text-2xl text-info"><%= totalStudents %></div>
            </div>
            <div class="stat bg-success/10 rounded-lg p-4">
                <div class="stat-title">Avg Score</div>
                <div class="stat-value text-2xl text-success"><%= String.format("%.1f", avgModuleScore) %>%</div>
            </div>
        </div>

        <!-- Performance Categories -->
        <div class="divider my-6">Performance Categories</div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="card bg-success/10 border border-success">
                <div class="card-body">
                    <h3 class="font-bold text-success mb-2">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 inline mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Excellent (≥70%)
                    </h3>
                    <p class="text-3xl font-bold text-success"><%= excellentModules %></p>
                    <p class="text-sm text-success/70">modules performing excellently</p>
                </div>
            </div>

            <div class="card bg-warning/10 border border-warning">
                <div class="card-body">
                    <h3 class="font-bold text-warning mb-2">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 inline mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                        Good (50-69%)
                    </h3>
                    <p class="text-3xl font-bold text-warning"><%= goodModules %></p>
                    <p class="text-sm text-warning/70">modules performing adequately</p>
                </div>
            </div>

            <div class="card bg-error/10 border border-error">
                <div class="card-body">
                    <h3 class="font-bold text-error mb-2">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 inline mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Needs Improvement (<50%)
                    </h3>
                    <p class="text-3xl font-bold text-error"><%= needsImprovement %></p>
                    <p class="text-sm text-error/70">modules requiring attention</p>
                </div>
            </div>
        </div>

        <!-- Top & Bottom Performers -->
        <div class="divider my-6">Module Rankings</div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <%
                List<ModulePerformance> sortedByScore = new java.util.ArrayList<>(modulePerformances);
                sortedByScore.sort((a, b) -> Double.compare(b.averageScore, a.averageScore));

                List<ModulePerformance> topModules = sortedByScore.subList(0, Math.min(5, sortedByScore.size()));
                List<ModulePerformance> bottomModules = sortedByScore.subList(Math.max(0, sortedByScore.size() - 5), sortedByScore.size());
                java.util.Collections.reverse(bottomModules);
            %>

            <div class="card bg-success/5 border border-success/20">
                <div class="card-body">
                    <h3 class="font-bold text-success mb-3">🏆 Top 5 Performing Modules</h3>
                    <div class="space-y-2">
                        <% for (int i = 0; i < topModules.size(); i++) {
                            ModulePerformance module = topModules.get(i);
                        %>
                        <div class="flex justify-between items-center p-2 bg-base-100 rounded">
                            <div>
                                <span class="font-semibold text-sm"><%= (i+1) %>. <%= module.moduleName %></span>
                                <p class="text-xs text-base-content/70"><%= module.managedBy %></p>
                            </div>
                            <span class="badge badge-success"><%= String.format("%.1f", module.averageScore) %>%</span>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="card bg-warning/5 border border-warning/20">
                <div class="card-body">
                    <h3 class="font-bold text-warning mb-3">⚠️ Modules Needing Attention</h3>
                    <div class="space-y-2">
                        <% for (ModulePerformance module : bottomModules) { %>
                        <div class="flex justify-between items-center p-2 bg-base-100 rounded">
                            <div>
                                <span class="font-semibold text-sm"><%= module.moduleName %></span>
                                <p class="text-xs text-base-content/70"><%= module.managedBy %></p>
                            </div>
                            <span class="badge badge-warning"><%= String.format("%.1f", module.averageScore) %>%</span>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</div>

