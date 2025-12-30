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
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
            </svg>
            Print Report
        </button>
    </div>

    <!-- Report Navigation -->
    <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-8 print:hidden">
        <a href="?page=reports-academic-leader&type=student-performance" class="card <%= "student-performance".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path d="M12 14l9-5-9-5-9 5 9 5z" />
                    <path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222" />
                </svg>
                <h3 class="font-bold">Student Performance</h3>
            </div>
        </a>

        <a href="?page=reports-academic-leader&type=class-enrollment" class="card <%= "class-enrollment".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
                <h3 class="font-bold">Class Enrollment</h3>
            </div>
        </a>

        <a href="?page=reports-academic-leader&type=lecturer-performance" class="card <%= "lecturer-performance".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                <h3 class="font-bold">Lecturer Performance</h3>
            </div>
        </a>

        <a href="?page=reports-academic-leader&type=module-performance" class="card <%= "module-performance".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                </svg>
                <h3 class="font-bold">Module Performance</h3>
            </div>
        </a>

        <a href="?page=reports-academic-leader&type=student-satisfaction" class="card <%= "student-satisfaction".equals(reportType) ? "bg-primary text-white" : "bg-base-100 hover:bg-base-200" %> shadow border border-base-300 cursor-pointer transition-all">
            <div class="card-body p-4 text-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
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
            <svg xmlns="http://www.w3.org/2000/svg" class="h-24 w-24 mx-auto text-base-content/50 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
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

