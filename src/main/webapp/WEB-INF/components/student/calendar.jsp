<%--
  Student Calendar View showing all assessments
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
<div class="p-6">
    <div class="mb-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-2">My Calendar</h1>
        <p class="text-gray-600">View all your assessments and deadlines</p>
    </div>

    <!-- Calendar View -->
    <div class="card bg-base-100 shadow-lg mb-6">
        <div class="card-body">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold" id="currentMonthYear"></h2>
                <div class="flex gap-2">
                    <button onclick="previousMonth()" class="btn btn-sm btn-ghost">← Previous</button>
                    <button onclick="goToToday()" class="btn btn-sm btn-primary">Today</button>
                    <button onclick="nextMonth()" class="btn btn-sm btn-ghost">Next →</button>
                </div>
            </div>
            <div id="calendarGrid" class="grid grid-cols-7 gap-2">
                <!-- Calendar will be generated here -->
            </div>
        </div>
    </div>

    <!-- Upcoming Assessments List -->
    <div class="card bg-base-100 shadow-lg">
        <div class="card-body">
            <h2 class="text-xl font-bold mb-4">Upcoming Assessments</h2>
            <div id="upcomingAssessments" class="space-y-3">
                <div class="text-center">
                    <span class="loading loading-spinner loading-lg"></span>
                    <p class="mt-2">Loading...</p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    let assessments = [];
    let currentDate = new Date();
    const apiBase = '<%= request.getContextPath() %>/api/assessments';

    document.addEventListener('DOMContentLoaded', function() {
        loadAssessments();
    });

    async function loadAssessments() {
        try {
            const response = await fetch(apiBase);
            if (!response.ok) throw new Error('Failed to load assessments');
            
            const allAssessments = await response.json();
            assessments = allAssessments.filter(a => 
                a.visibility === 'PUBLIC' || a.visibility === 'RESTRICTED'
            );
            
            renderCalendar();
            renderUpcomingAssessments();
        } catch (error) {
            console.error('Error loading assessments:', error);
        }
    }

    function renderCalendar() {
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth();
        
        document.getElementById('currentMonthYear').textContent = 
            currentDate.toLocaleString('default', { month: 'long', year: 'numeric' });
        
        const firstDay = new Date(year, month, 1);
        const lastDay = new Date(year, month + 1, 0);
        const daysInMonth = lastDay.getDate();
        const startingDayOfWeek = firstDay.getDay();
        
        const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        let html = '<div class="font-bold text-center p-2 border-b">' + 
            dayNames.map(d => '<div>' + d + '</div>').join('') + 
        '</div>';
        
        // Empty cells for days before month starts
        for (let i = 0; i < startingDayOfWeek; i++) {
            html += '<div class="aspect-square"></div>';
        }
        
        // Days of the month
        for (let day = 1; day <= daysInMonth; day++) {
            const date = new Date(year, month, day);
            const dateStr = formatDateForCalendar(date);
            const dayAssessments = assessments.filter(a => {
                const deadline = new Date(a.deadline);
                return deadline.toDateString() === date.toDateString();
            });
            
            let dayHtml = '<div class="aspect-square border border-gray-200 p-1 hover:bg-base-200 cursor-pointer" onclick="showDayDetails(\'' + dateStr + '\')">';
            dayHtml += '<div class="font-semibold text-sm">' + day + '</div>';
            if (dayAssessments.length > 0) {
                dayHtml += '<div class="text-xs space-y-1 mt-1">';
                dayAssessments.slice(0, 2).forEach(function(a) {
                    const typeColor = a.assessmentType === 'QUIZ' ? 'badge-warning' :
                                    a.assessmentType === 'EXAM' ? 'badge-error' :
                                    a.assessmentType === 'ASSIGNMENT' ? 'badge-info' : 'badge-secondary';
                    dayHtml += '<div class="badge badge-xs ' + typeColor + '">' + 
                        escapeHtml(a.name.substring(0, 15)) + (a.name.length > 15 ? '...' : '') + 
                    '</div>';
                });
                if (dayAssessments.length > 2) {
                    dayHtml += '<div class="text-xs text-gray-500">+' + (dayAssessments.length - 2) + ' more</div>';
                }
                dayHtml += '</div>';
            }
            dayHtml += '</div>';
            html += dayHtml;
        }
        
        document.getElementById('calendarGrid').innerHTML = html;
    }

    function renderUpcomingAssessments() {
        const now = new Date();
        const upcoming = assessments
            .filter(a => new Date(a.deadline) >= now)
            .sort(function(a, b) {
                return new Date(a.deadline) - new Date(b.deadline);
            })
            .slice(0, 10);
        
        const container = document.getElementById('upcomingAssessments');
        if (upcoming.length === 0) {
            container.innerHTML = '<p class="text-gray-500">No upcoming assessments</p>';
            return;
        }
        
        container.innerHTML = upcoming.map(function(a) {
            const deadline = new Date(a.deadline);
            const daysLeft = Math.ceil((deadline - now) / (1000 * 60 * 60 * 24));
            const typeColor = a.assessmentType === 'QUIZ' ? 'badge-warning' :
                            a.assessmentType === 'EXAM' ? 'badge-error' :
                            a.assessmentType === 'ASSIGNMENT' ? 'badge-info' : 'badge-secondary';
            
            return '<div class="flex items-center justify-between p-3 border border-gray-200 rounded-lg hover:bg-base-200">' +
                '<div class="flex-1">' +
                    '<div class="flex items-center gap-2 mb-1">' +
                        '<span class="badge ' + typeColor + '">' + a.assessmentType + '</span>' +
                        '<span class="font-semibold">' + escapeHtml(a.name) + '</span>' +
                    '</div>' +
                    '<div class="text-sm text-gray-500">' + formatDate(a.deadline) + '</div>' +
                '</div>' +
                '<div class="text-right">' +
                    '<div class="font-bold text-lg">' + daysLeft + '</div>' +
                    '<div class="text-xs text-gray-500">day' + (daysLeft !== 1 ? 's' : '') + ' left</div>' +
                '</div>' +
            '</div>';
        }).join('');
    }

    function previousMonth() {
        currentDate.setMonth(currentDate.getMonth() - 1);
        renderCalendar();
    }

    function nextMonth() {
        currentDate.setMonth(currentDate.getMonth() + 1);
        renderCalendar();
    }

    function goToToday() {
        currentDate = new Date();
        renderCalendar();
    }

    function showDayDetails(dateStr) {
        const date = new Date(dateStr);
        const dayAssessments = assessments.filter(a => {
            const deadline = new Date(a.deadline);
            return deadline.toDateString() === date.toDateString();
        });
        
        if (dayAssessments.length === 0) {
            alert('No assessments on ' + date.toLocaleDateString());
            return;
        }
        
        const details = dayAssessments.map(function(a) {
            return a.assessmentType + ': ' + a.name + ' (Deadline: ' + formatDate(a.deadline) + ')';
        }).join('\n');
        
        alert('Assessments on ' + date.toLocaleDateString() + ':\n\n' + details);
    }

    function formatDate(dateString) {
        if (!dateString) return '-';
        const date = typeof dateString === 'string' ? new Date(dateString) : dateString;
        return date.toLocaleString();
    }

    function formatDateForCalendar(date) {
        return date.getFullYear() + '-' + 
               String(date.getMonth() + 1).padStart(2, '0') + '-' + 
               String(date.getDate()).padStart(2, '0');
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
</script>
