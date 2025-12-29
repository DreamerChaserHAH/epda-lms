<%--
  Created by IntelliJ IDEA.
  User: victor
  Date: 12/23/25
  Time: 3:29 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    // Check if user is authenticated
    if (session.getAttribute("authenticated") == null ||
            !(Boolean)session.getAttribute("authenticated")) {
        return;
    }

    String username = (String) session.getAttribute("username");
    String role = session.getAttribute("role") != null ?
            session.getAttribute("role").toString() : "STUDENT";
    Long userId = (Long) session.getAttribute("userId");
%>
<div>
    <div class="flex flex-row gap-6 w-full pb-4">
        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <div class="card-body">
                <b class="card-title text-gray-500">Enrolled Modules</b>
                <p class="text-3xl font-bold" id="enrolledModulesCount">-</p>
            </div>
        </div>
        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <div class="card-body">
                <b class="card-title text-gray-500">Total Assessments</b>
                <p class="text-3xl font-bold" id="totalAssessmentsCount">-</p>
            </div>
        </div>
        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <div class="card-body">
                <b class="card-title text-gray-500">Completed Assessments</b>
                <p class="text-3xl font-bold" id="completedAssessmentsCount">-</p>
            </div>
        </div>
    </div>

    <div class="flex flex-row gap-6 w-full pb-4">
        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <a href="<%=request.getContextPath()%>/index.jsp?page=profile">
                <div class="card-body">
                    <div class="avatar">
                        <div class="w-24 rounded">
                            <img src="<%= request.getContextPath()%>/images/icons/profile.png" />
                        </div>
                    </div>
                    <b class="card-title">Edit Profile</b>
                    <p>Update your personal information</p>
                </div>
            </a>
        </div>

        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <a href="<%=request.getContextPath()%>/index.jsp?page=results">
                <div class="card-body">
                    <div class="avatar">
                        <div class="w-24 rounded">
                            <img src="<%= request.getContextPath()%>/images/icons/results.png" />
                        </div>
                    </div>
                    <b class="card-title">View Results</b>
                    <p>Check your assessment grades</p>
                </div>
            </a>
        </div>

        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <a href="<%=request.getContextPath()%>/index.jsp?page=assignments">
                <div class="card-body">
                    <div class="avatar">
                        <div class="w-24 rounded">
                            <img src="<%= request.getContextPath()%>/images/icons/upload.png" />
                        </div>
                    </div>
                    <b class="card-title">My Assignments</b>
                    <p>View and submit assessments</p>
                </div>
            </a>
        </div>
    </div>

    <!-- Recent Assessments Section -->
    <h2 class="font-title font-bold pb-3 pt-3 text-2xl">Recent Assessments</h2>
    <div id="recentAssessments" class="mb-6">
        <div class="text-center">
            <span class="loading loading-spinner loading-lg"></span>
            <p class="mt-2">Loading assessments...</p>
        </div>
    </div>

    <h2 class="font-title font-bold pb-3 pt-3 text-2xl">My Modules</h2>
    <div>
        <div class="flex flex-row flex-wrap gap-6">
            <div class="card border border-gray-200 w-128 bg-base-100 card-l shadow-l">
                <div class="card-body">
                    <b class="card-title text-gray-500">CS101</b>
                    <p class="text-2xl font-bold">Introduction to Computer Science</p>
                    <p>Lecturer: XXX</p>
                    <p>Schedule: Mon/Wed 10:00-12:00</p>
                </div>
            </div>
            <div class="card border border-gray-200 w-128 bg-base-100 card-l shadow-l">
                <div class="card-body">
                    <b class="card-title text-gray-500">CS101</b>
                    <p class="text-2xl font-bold">Introduction to Computer Science</p>
                    <p>Lecturer: XXX</p>
                    <p>Schedule: Mon/Wed 10:00-12:00</p>
                </div>
            </div>
            <div class="card border border-gray-200 w-128 bg-base-100 card-l shadow-l">
                <div class="card-body">
                    <b class="card-title text-gray-500">CS101</b>
                    <p class="text-2xl font-bold">Introduction to Computer Science</p>
                    <p>Lecturer: XXX</p>
                    <p>Schedule: Mon/Wed 10:00-12:00</p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const apiBase = '<%= request.getContextPath() %>/api/assessments';
    const userId = <%= userId != null ? userId : 0 %>;

    // Load assessment statistics and recent assessments
    document.addEventListener('DOMContentLoaded', function() {
        loadAssessmentStats();
        loadRecentAssessments();
    });

    // Load assessment statistics
    async function loadAssessmentStats() {
        try {
            const response = await fetch(apiBase);
            if (!response.ok) throw new Error('Failed to load assessments');
            
            const allAssessments = await response.json();
            // Filter to show only PUBLIC assessments for students
            const studentAssessments = allAssessments.filter(a => 
                a.visibility === 'PUBLIC' || a.visibility === 'RESTRICTED'
            );
            
            // Load submissions
            const stored = localStorage.getItem('studentSubmissions_' + userId);
            const submissions = stored ? JSON.parse(stored) : {};
            const submittedIds = Object.keys(submissions).map(Number);
            
            // Update counts
            document.getElementById('totalAssessmentsCount').textContent = studentAssessments.length;
            document.getElementById('completedAssessmentsCount').textContent = submittedIds.length;
            document.getElementById('enrolledModulesCount').textContent = '12'; // Placeholder
        } catch (error) {
            console.error('Error loading assessment stats:', error);
            document.getElementById('totalAssessmentsCount').textContent = '0';
            document.getElementById('completedAssessmentsCount').textContent = '0';
        }
    }

    // Load recent assessments
    async function loadRecentAssessments() {
        try {
            const response = await fetch(apiBase);
            if (!response.ok) throw new Error('Failed to load assessments');
            
            const allAssessments = await response.json();
            const studentAssessments = allAssessments.filter(a => 
                a.visibility === 'PUBLIC' || a.visibility === 'RESTRICTED'
            );
            
            // Sort by deadline (upcoming first)
            studentAssessments.sort(function(a, b) {
                return new Date(a.deadline) - new Date(b.deadline);
            });
            
            // Show top 6 recent assessments
            const recent = studentAssessments.slice(0, 6);
            
            const container = document.getElementById('recentAssessments');
            if (recent.length === 0) {
                container.innerHTML = '<p class="text-gray-500">No assessments available</p>';
                return;
            }
            
            // Load submissions
            const stored = localStorage.getItem('studentSubmissions_' + userId);
            const submissions = stored ? JSON.parse(stored) : {};
            
            container.innerHTML = '<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">' +
                recent.map(function(assessment) {
                    const id = assessment.id;
                    const name = escapeHtml(assessment.name || '');
                    const type = assessment.assessmentType || '';
                    const deadline = formatDate(assessment.deadline);
                    const isOverdue = new Date(assessment.deadline) < new Date();
                    const hasSubmission = submissions[id] != null;
                    const statusClass = hasSubmission ? 'badge-success' : 
                                       isOverdue ? 'badge-error' : 'badge-warning';
                    const statusText = hasSubmission ? 'Submitted' : 
                                      isOverdue ? 'Overdue' : 'Pending';
                    
                    return '<div class="card bg-base-100 shadow border border-gray-200">' +
                        '<div class="card-body p-4">' +
                            '<div class="flex justify-between items-start mb-2">' +
                                '<h3 class="font-semibold text-sm">' + name + '</h3>' +
                                '<span class="badge badge-sm ' + statusClass + '">' + statusText + '</span>' +
                            '</div>' +
                            '<div class="text-xs text-gray-500 space-y-1">' +
                                '<div><strong>Type:</strong> ' + type + '</div>' +
                                '<div><strong>Deadline:</strong> ' + deadline + '</div>' +
                            '</div>' +
                            '<div class="card-actions justify-end mt-2">' +
                                '<a href="<%=request.getContextPath()%>/index.jsp?page=assignments" class="btn btn-xs btn-primary">View Details</a>' +
                            '</div>' +
                        '</div>' +
                    '</div>';
                }).join('') +
                '</div>' +
                '<div class="mt-4 text-center">' +
                    '<a href="<%=request.getContextPath()%>/index.jsp?page=assignments" class="btn btn-primary">View All Assignments</a>' +
                '</div>';
        } catch (error) {
            console.error('Error loading recent assessments:', error);
            document.getElementById('recentAssessments').innerHTML = 
                '<p class="text-error">Error loading assessments</p>';
        }
    }

    function formatDate(dateString) {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleString();
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
</script>
