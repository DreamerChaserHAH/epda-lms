<%@ page import="com.htetaung.lms.servlets.AcademicLeaderReportServlet.AssessmentFeedback" %>
<%@ page import="java.util.List" %>
<%
    List<AssessmentFeedback> assessmentFeedbacks = (List<AssessmentFeedback>) request.getAttribute("assessmentFeedbacks");
    if (assessmentFeedbacks == null) assessmentFeedbacks = new java.util.ArrayList<>();
%>

<div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
    <div class="card-body">
        <h2 class="card-title text-2xl mb-4">Student Satisfaction & Assessment Difficulty Report</h2>
        <p class="text-base-content/70 mb-6">Analysis of assessment difficulty levels based on student performance to guide curriculum adjustments</p>

        <!-- Difficulty Legend -->
        <div class="alert mb-6">
            <img src="<%= request.getContextPath() %>/images/icons/info-circle.png"
                 alt="Info" class="w-6 h-6 shrink-0">
            <div class="flex-1">
                <h3 class="font-bold">Difficulty Level Classification</h3>
                <div class="grid grid-cols-2 md:grid-cols-4 gap-2 mt-2">
                    <div class="badge badge-success">Too Easy (≥80%)</div>
                    <div class="badge badge-info">Appropriate (60-79%)</div>
                    <div class="badge badge-warning">Challenging (40-59%)</div>
                    <div class="badge badge-error">Too Difficult (<40%)</div>
                </div>
            </div>
        </div>

        <!-- Assessment Feedback Table -->
        <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
                <thead>
                    <tr>
                        <th>Assessment</th>
                        <th>Class</th>
                        <th>Module</th>
                        <th>Submissions</th>
                        <th>Avg Score</th>
                        <th>Difficulty Level</th>
                        <th>Recommendation</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (assessmentFeedbacks.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="text-center text-base-content/60 py-8">No assessment feedback data available</td>
                    </tr>
                    <% } else { %>
                        <% for (AssessmentFeedback feedback : assessmentFeedbacks) { %>
                        <tr>
                            <td class="font-semibold"><%= feedback.assessmentName %></td>
                            <td><%= feedback.className %></td>
                            <td><%= feedback.moduleName %></td>
                            <td><span class="badge badge-ghost"><%= feedback.totalSubmissions %></span></td>
                            <td><span class="badge badge-lg <%= feedback.averageScore >= 70 ? "badge-success" : feedback.averageScore >= 50 ? "badge-warning" : "badge-error" %>"><%= String.format("%.1f", feedback.averageScore) %>%</span></td>
                            <td>
                                <%
                                    String badgeClass = "badge-info";
                                    if ("Too Easy".equals(feedback.difficultyLevel)) {
                                        badgeClass = "badge-success";
                                    } else if ("Too Difficult".equals(feedback.difficultyLevel)) {
                                        badgeClass = "badge-error";
                                    } else if ("Challenging".equals(feedback.difficultyLevel)) {
                                        badgeClass = "badge-warning";
                                    }
                                %>
                                <span class="badge <%= badgeClass %>"><%= feedback.difficultyLevel %></span>
                            </td>
                            <td class="text-sm max-w-xs"><%= feedback.recommendation %></td>
                        </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>

        <% if (!assessmentFeedbacks.isEmpty()) { %>
        <!-- Difficulty Distribution -->
        <div class="divider my-6">Difficulty Distribution</div>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <%
                int tooEasy = 0;
                int appropriate = 0;
                int challenging = 0;
                int tooDifficult = 0;

                for (AssessmentFeedback feedback : assessmentFeedbacks) {
                    if ("Too Easy".equals(feedback.difficultyLevel)) {
                        tooEasy++;
                    } else if ("Appropriate".equals(feedback.difficultyLevel)) {
                        appropriate++;
                    } else if ("Challenging".equals(feedback.difficultyLevel)) {
                        challenging++;
                    } else if ("Too Difficult".equals(feedback.difficultyLevel)) {
                        tooDifficult++;
                    }
                }

                int total = assessmentFeedbacks.size();
            %>
            <div class="stat bg-success/10 rounded-lg p-4">
                <div class="stat-title">Too Easy</div>
                <div class="stat-value text-2xl text-success"><%= tooEasy %></div>
                <div class="stat-desc"><%= total > 0 ? String.format("%.1f", (tooEasy * 100.0 / total)) : "0" %>% of assessments</div>
            </div>
            <div class="stat bg-info/10 rounded-lg p-4">
                <div class="stat-title">Appropriate</div>
                <div class="stat-value text-2xl text-info"><%= appropriate %></div>
                <div class="stat-desc"><%= total > 0 ? String.format("%.1f", (appropriate * 100.0 / total)) : "0" %>% of assessments</div>
            </div>
            <div class="stat bg-warning/10 rounded-lg p-4">
                <div class="stat-title">Challenging</div>
                <div class="stat-value text-2xl text-warning"><%= challenging %></div>
                <div class="stat-desc"><%= total > 0 ? String.format("%.1f", (challenging * 100.0 / total)) : "0" %>% of assessments</div>
            </div>
            <div class="stat bg-error/10 rounded-lg p-4">
                <div class="stat-title">Too Difficult</div>
                <div class="stat-value text-2xl text-error"><%= tooDifficult %></div>
                <div class="stat-desc"><%= total > 0 ? String.format("%.1f", (tooDifficult * 100.0 / total)) : "0" %>% of assessments</div>
            </div>
        </div>

        <!-- Recommendations Summary -->
        <div class="divider my-6">Action Items</div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Assessments Needing Adjustment -->
            <div class="card bg-warning/5 border border-warning/20">
                <div class="card-body">
                    <h3 class="font-bold text-warning mb-3">⚠️ Assessments Needing Difficulty Adjustment</h3>
                    <div class="space-y-2">
                        <%
                            int count = 0;
                            for (AssessmentFeedback feedback : assessmentFeedbacks) {
                                if ("Too Easy".equals(feedback.difficultyLevel) || "Too Difficult".equals(feedback.difficultyLevel)) {
                                    count++;
                                    if (count <= 5) {
                        %>
                        <div class="p-3 bg-base-100 rounded">
                            <div class="flex justify-between items-start">
                                <div>
                                    <p class="font-semibold text-sm"><%= feedback.assessmentName %></p>
                                    <p class="text-xs text-base-content/70"><%= feedback.className %> - <%= feedback.moduleName %></p>
                                </div>
                                <span class="badge <%= "Too Easy".equals(feedback.difficultyLevel) ? "badge-success" : "badge-error" %> badge-sm"><%= feedback.difficultyLevel %></span>
                            </div>
                            <p class="text-xs mt-2 text-warning"><%= feedback.recommendation %></p>
                        </div>
                        <%
                                    }
                                }
                            }
                            if (count == 0) {
                        %>
                        <p class="text-center text-base-content/60 py-4">No assessments need adjustment</p>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Well-Balanced Assessments -->
            <div class="card bg-success/5 border border-success/20">
                <div class="card-body">
                    <h3 class="font-bold text-success mb-3">✅ Well-Balanced Assessments</h3>
                    <div class="space-y-2">
                        <%
                            int balancedCount = 0;
                            for (AssessmentFeedback feedback : assessmentFeedbacks) {
                                if ("Appropriate".equals(feedback.difficultyLevel) || "Challenging".equals(feedback.difficultyLevel)) {
                                    balancedCount++;
                                    if (balancedCount <= 5) {
                        %>
                        <div class="p-3 bg-base-100 rounded">
                            <div class="flex justify-between items-start">
                                <div>
                                    <p class="font-semibold text-sm"><%= feedback.assessmentName %></p>
                                    <p class="text-xs text-base-content/70"><%= feedback.className %> - <%= feedback.moduleName %></p>
                                </div>
                                <span class="badge <%= "Appropriate".equals(feedback.difficultyLevel) ? "badge-info" : "badge-warning" %> badge-sm"><%= feedback.difficultyLevel %></span>
                            </div>
                            <p class="text-xs mt-2 text-success"><%= feedback.recommendation %></p>
                        </div>
                        <%
                                    }
                                }
                            }
                            if (balancedCount == 0) {
                        %>
                        <p class="text-center text-base-content/60 py-4">No well-balanced assessments found</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Overall Satisfaction Metrics -->
        <div class="divider my-6">Overall Satisfaction Metrics</div>
        <div class="alert alert-info">
            <img src="<%= request.getContextPath() %>/images/icons/info-circle.png"
                 alt="Info" class="w-6 h-6 shrink-0">
            <div>
                <h3 class="font-bold">Assessment Balance Score</h3>
                <%
                    double balanceScore = total > 0 ? ((appropriate + challenging) * 100.0 / total) : 0;
                    String balanceRating = balanceScore >= 80 ? "Excellent" : balanceScore >= 60 ? "Good" : balanceScore >= 40 ? "Fair" : "Needs Improvement";
                %>
                <div class="text-xs mt-2">
                    <span class="font-bold"><%= String.format("%.1f", balanceScore) %>%</span> of assessments are appropriately balanced
                    - Rating: <span class="badge <%= balanceScore >= 80 ? "badge-success" : balanceScore >= 60 ? "badge-info" : balanceScore >= 40 ? "badge-warning" : "badge-error" %>"><%= balanceRating %></span>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</div>

