<%@ page import="com.htetaung.lms.servlets.AcademicLeaderReportServlet.ClassEnrollment" %>
<%@ page import="java.util.List" %>
<%
    List<ClassEnrollment> classEnrollments = (List<ClassEnrollment>) request.getAttribute("classEnrollments");
    if (classEnrollments == null) classEnrollments = new java.util.ArrayList<>();

    // Debug info
    System.out.println("DEBUG: Class Enrollment Report - classEnrollments is null: " + (request.getAttribute("classEnrollments") == null));
    System.out.println("DEBUG: Class Enrollment Report - classEnrollments size: " + classEnrollments.size());
%>

<div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
    <div class="card-body">
        <h2 class="card-title text-2xl mb-4">Class Enrollment Report</h2>
        <p class="text-base-content/70 mb-6">Monitor class capacity and enrollment rates (Found <%= classEnrollments.size() %> classes)</p>

        <!-- Class Enrollment Table -->
        <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
                <thead>
                    <tr>
                        <th>Class Name</th>
                        <th>Module</th>
                        <th>Lecturer</th>
                        <th>Students</th>
                        <th>Capacity</th>
                        <th>Enrollment Rate</th>
                        <th>Assessments</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (classEnrollments.isEmpty()) { %>
                    <tr>
                        <td colspan="8" class="text-center text-base-content/60 py-8">No class enrollment data available</td>
                    </tr>
                    <% } else { %>
                        <% for (ClassEnrollment enrollment : classEnrollments) { %>
                        <tr>
                            <td class="font-semibold"><%= enrollment.className %></td>
                            <td><%= enrollment.moduleName %></td>
                            <td><%= enrollment.lecturerName %></td>
                            <td><span class="badge badge-info"><%= enrollment.totalStudents %></span></td>
                            <td><span class="badge badge-ghost"><%= enrollment.capacity %></span></td>
                            <td>
                                <div class="flex items-center gap-2">
                                    <progress class="progress <%= enrollment.enrollmentRate >= 80 ? "progress-success" : enrollment.enrollmentRate >= 50 ? "progress-warning" : "progress-error" %> w-20" value="<%= enrollment.enrollmentRate %>" max="100"></progress>
                                    <span class="text-xs"><%= String.format("%.0f", enrollment.enrollmentRate) %>%</span>
                                </div>
                            </td>
                            <td><span class="badge badge-secondary"><%= enrollment.totalAssessments %></span></td>
                            <td>
                                <%
                                    String statusClass = "badge-success";
                                    String statusText = "Available";
                                    if (enrollment.enrollmentRate >= 100) {
                                        statusClass = "badge-error";
                                        statusText = "Full";
                                    } else if (enrollment.enrollmentRate >= 80) {
                                        statusClass = "badge-warning";
                                        statusText = "Near Full";
                                    }
                                %>
                                <span class="badge <%= statusClass %>"><%= statusText %></span>
                            </td>
                        </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>

        <% if (!classEnrollments.isEmpty()) { %>
        <!-- Summary Statistics -->
        <div class="divider my-6">Summary Statistics</div>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <%
                int totalClasses = classEnrollments.size();
                int totalStudents = 0;
                int fullClasses = 0;
                int nearFullClasses = 0;
                double avgEnrollmentRate = 0;

                for (ClassEnrollment enrollment : classEnrollments) {
                    totalStudents += enrollment.totalStudents;
                    avgEnrollmentRate += enrollment.enrollmentRate;

                    if (enrollment.enrollmentRate >= 100) {
                        fullClasses++;
                    } else if (enrollment.enrollmentRate >= 80) {
                        nearFullClasses++;
                    }
                }

                if (totalClasses > 0) {
                    avgEnrollmentRate /= totalClasses;
                }
            %>
            <div class="stat bg-base-200 rounded-lg p-4">
                <div class="stat-title">Total Classes</div>
                <div class="stat-value text-2xl"><%= totalClasses %></div>
            </div>
            <div class="stat bg-info/10 rounded-lg p-4">
                <div class="stat-title">Total Students</div>
                <div class="stat-value text-2xl text-info"><%= totalStudents %></div>
            </div>
            <div class="stat bg-success/10 rounded-lg p-4">
                <div class="stat-title">Avg Enrollment</div>
                <div class="stat-value text-2xl text-success"><%= String.format("%.1f", avgEnrollmentRate) %>%</div>
            </div>
            <div class="stat bg-warning/10 rounded-lg p-4">
                <div class="stat-title">Full/Near Full</div>
                <div class="stat-value text-2xl text-warning"><%= fullClasses + nearFullClasses %></div>
            </div>
        </div>

        <!-- Capacity Analysis -->
        <div class="divider my-6">Capacity Analysis</div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <%
                int availableClasses = totalClasses - fullClasses - nearFullClasses;
            %>
            <div class="card bg-success/10 border border-success">
                <div class="card-body p-4">
                    <h3 class="font-bold text-success mb-2">✅ Available Capacity</h3>
                    <p class="text-3xl font-bold text-success"><%= availableClasses %></p>
                    <p class="text-sm text-success/70">classes with available seats</p>
                </div>
            </div>

            <div class="card bg-warning/10 border border-warning">
                <div class="card-body p-4">
                    <h3 class="font-bold text-warning mb-2">⚠️ Near Full</h3>
                    <p class="text-3xl font-bold text-warning"><%= nearFullClasses %></p>
                    <p class="text-sm text-warning/70">classes at 80-99% capacity</p>
                </div>
            </div>

            <div class="card bg-error/10 border border-error">
                <div class="card-body p-4">
                    <h3 class="font-bold text-error mb-2">🚫 Full</h3>
                    <p class="text-3xl font-bold text-error"><%= fullClasses %></p>
                    <p class="text-sm text-error/70">classes at full capacity</p>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</div>

