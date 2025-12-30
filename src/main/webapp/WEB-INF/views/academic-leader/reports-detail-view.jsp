<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.servlets.AcademicLeaderReportServlet.*" %>
<%@ page import="java.util.*" %>
<%
    String reportType = request.getParameter("type");
    if (reportType == null) reportType = "overview";
    String contextPath = request.getContextPath();
%>

<div id="report-content" class="container mx-auto p-6">
    <!-- Header -->
    <div class="pb-6 flex justify-between items-center print:hidden">
        <div>
            <h1 class="font-title font-bold text-4xl text-base-content">Reports</h1>
            <p class="text-base-content/70 mt-2 text-lg">Comprehensive performance analytics for your modules</p>
        </div>
        <button onclick="printReport()" class="btn btn-primary">
            <img src="<%= request.getContextPath() %>/images/icons/print.png"
                 alt="Print" class="h-5 w-5 mr-2">
            Print Report
        </button>
    </div>

    <!-- Report Navigation -->
    <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-8 print:hidden">
        <a href="?page=reports-academic-leader&type=student-performance" class="card <%= "student-performance".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <img src="<%= request.getContextPath() %>/images/icons/users.png"
                     alt="Student Performance" class="h-8 w-8 mx-auto mb-2">
                <h3 class="font-bold">Student Performance</h3>
            </div>
        </a>

        <a href="?page=reports-academic-leader&type=class-enrollment" class="card <%= "class-enrollment".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <img src="<%= request.getContextPath() %>/images/icons/classes.png"
                     alt="Class Enrollment" class="h-8 w-8 mx-auto mb-2">
                <h3 class="font-bold">Class Enrollment</h3>
            </div>
        </a>

        <a href="?page=reports-academic-leader&type=lecturer-performance" class="card <%= "lecturer-performance".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <img src="<%= request.getContextPath() %>/images/icons/profile.png"
                     alt="Lecturer Performance" class="h-8 w-8 mx-auto mb-2">
                <h3 class="font-bold">Lecturer Performance</h3>
            </div>
        </a>

        <a href="?page=reports-academic-leader&type=module-performance" class="card <%= "module-performance".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <img src="<%= request.getContextPath() %>/images/icons/books.png"
                     alt="Module Performance" class="h-8 w-8 mx-auto mb-2">
                <h3 class="font-bold">Module Performance</h3>
            </div>
        </a>

        <a href="?page=reports-academic-leader&type=student-satisfaction" class="card <%= "student-satisfaction".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <img src="<%= request.getContextPath() %>/images/icons/results.png"
                     alt="Student Satisfaction" class="h-8 w-8 mx-auto mb-2">
                <h3 class="font-bold">Student Satisfaction</h3>
            </div>
        </a>
    </div>

    <!-- Report Content -->
    <% if ("student-performance".equals(reportType)) { %>
        <jsp:include page="reports/student-performance.jsp"/>
    <% } else if ("class-enrollment".equals(reportType)) { %>
        <jsp:include page="reports/class-enrollment.jsp"/>
    <% } else if ("lecturer-performance".equals(reportType)) { %>
        <jsp:include page="reports/lecturer-performance.jsp"/>
    <% } else if ("module-performance".equals(reportType)) { %>
        <jsp:include page="reports/module-performance.jsp"/>
    <% } else if ("student-satisfaction".equals(reportType)) { %>
        <jsp:include page="reports/student-satisfaction.jsp"/>
    <% } else { %>
        <!-- Overview -->
        <div class="text-center py-12">
            <img src="<%= request.getContextPath() %>/images/icons/reports.png"
                 alt="Reports" class="h-24 w-24 mx-auto mb-4 opacity-50">
            <h2 class="text-2xl font-bold mb-2">Select a Report Type</h2>
            <p class="text-base-content/70">Choose from the options above to view detailed analytics</p>
        </div>
    <% } %>
</div>

<script>
function printReport() {
    const reportContent = document.getElementById('report-content');
    const originalContents = document.body.innerHTML;
    const printContents = reportContent.innerHTML;

    // Replace body with report content
    document.body.innerHTML = printContents;

    // Add print styles
    const style = document.createElement('style');
    style.textContent = `
        @media print {
            body { padding: 20px; }
            .print\\:hidden { display: none !important; }
        }
    `;
    document.head.appendChild(style);

    // Print
    window.print();

    // Restore original content
    document.body.innerHTML = originalContents;

    // Reload to restore event listeners
    location.reload();
}
</script>

<style>
@media print {
    .print\\:hidden {
        display: none !important;
    }
    body {
        padding: 20px;
    }
}
</style>

