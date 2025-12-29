<%--
  Attendance Reports for Lecturers
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
            session.getAttribute("role").toString() : "LECTURER";
    Long userId = (Long) session.getAttribute("userId");
%>
<div class="p-6">
    <div class="mb-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-2">Attendance Reports</h1>
        <p class="text-gray-600">View attendance statistics and reports</p>
    </div>

    <!-- Class Selection -->
    <div class="card bg-base-100 shadow-lg mb-6">
        <div class="card-body">
            <div class="flex gap-4 items-end">
                <div class="form-control flex-1">
                    <label class="label">
                        <span class="label-text font-semibold">Select Class</span>
                    </label>
                    <select id="classSelect" class="select select-bordered" onchange="loadReports()">
                        <option value="">Select a class...</option>
                    </select>
                </div>
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">From Date</span>
                    </label>
                    <input type="date" id="fromDate" class="input input-bordered" onchange="loadReports()" />
                </div>
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">To Date</span>
                    </label>
                    <input type="date" id="toDate" class="input input-bordered" onchange="loadReports()" />
                </div>
                <button onclick="exportReport()" class="btn btn-primary">Export CSV</button>
            </div>
        </div>
    </div>

    <!-- Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div class="card bg-base-100 shadow-lg">
            <div class="card-body">
                <h3 class="card-title text-gray-500 text-sm">Total Students</h3>
                <p class="text-3xl font-bold" id="totalStudents">-</p>
            </div>
        </div>
        <div class="card bg-base-100 shadow-lg">
            <div class="card-body">
                <h3 class="card-title text-gray-500 text-sm">Average Attendance</h3>
                <p class="text-3xl font-bold" id="avgAttendance">-</p>
            </div>
        </div>
        <div class="card bg-base-100 shadow-lg">
            <div class="card-body">
                <h3 class="card-title text-gray-500 text-sm">Total Classes</h3>
                <p class="text-3xl font-bold" id="totalClasses">-</p>
            </div>
        </div>
        <div class="card bg-base-100 shadow-lg">
            <div class="card-body">
                <h3 class="card-title text-gray-500 text-sm">Low Attendance</h3>
                <p class="text-3xl font-bold text-error" id="lowAttendance">-</p>
            </div>
        </div>
    </div>

    <!-- Attendance Table -->
    <div class="card bg-base-100 shadow-lg">
        <div class="card-body">
            <div class="overflow-x-auto">
                <table class="table table-zebra w-full">
                    <thead>
                        <tr>
                            <th>Student ID</th>
                            <th>Name</th>
                            <th>Present</th>
                            <th>Absent</th>
                            <th>Late</th>
                            <th>Excused</th>
                            <th>Total</th>
                            <th>Attendance %</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="reportsTableBody">
                        <tr>
                            <td colspan="9" class="text-center">
                                <span class="loading loading-spinner loading-lg"></span>
                                <p class="mt-2">Select a class to view reports</p>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    let currentClassId = null;
    let attendanceData = [];
    const classApi = '<%= request.getContextPath() %>/api/classes';
    const attendanceApi = '<%= request.getContextPath() %>/api/attendance';
    const enrollmentApi = '<%= request.getContextPath() %>/api/enrollments';
    const userId = <%= userId != null ? userId : 0 %>;

    document.addEventListener('DOMContentLoaded', function() {
        loadLecturerClasses();
        // Set default dates (current month)
        const now = new Date();
        const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
        const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        document.getElementById('fromDate').value = formatDateInput(firstDay);
        document.getElementById('toDate').value = formatDateInput(lastDay);
    });

    function formatDateInput(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return year + '-' + month + '-' + day;
    }

    async function loadLecturerClasses() {
        try {
            const response = await fetch(classApi + '?lecturerId=' + userId);
            if (response.ok) {
                const classes = await response.json();
                const select = document.getElementById('classSelect');
                select.innerHTML = '<option value="">Select a class...</option>' +
                    classes.map(function(c) {
                        return '<option value="' + c.id + '">' + escapeHtml(c.name) + 
                               ' (' + escapeHtml(c.classCode) + ')</option>';
                    }).join('');
            }
        } catch (error) {
            console.error('Error loading classes:', error);
        }
    }

    async function loadReports() {
        currentClassId = document.getElementById('classSelect').value;
        const fromDate = document.getElementById('fromDate').value;
        const toDate = document.getElementById('toDate').value;

        if (!currentClassId) {
            document.getElementById('reportsTableBody').innerHTML = 
                '<tr><td colspan="9" class="text-center">Please select a class</td></tr>';
            return;
        }

        try {
            // Load all attendance for the class
            const response = await fetch(attendanceApi + '?classId=' + currentClassId);
            if (response.ok) {
                attendanceData = await response.json();
                
                // Filter by date range if provided
                if (fromDate && toDate) {
                    const from = new Date(fromDate);
                    const to = new Date(toDate);
                    attendanceData = attendanceData.filter(function(a) {
                        const attDate = new Date(a.attendanceDate);
                        return attDate >= from && attDate <= to;
                    });
                }

                // Load students
                const enrollResponse = await fetch(enrollmentApi + '?classId=' + currentClassId);
                if (enrollResponse.ok) {
                    const enrollments = await enrollResponse.json();
                    const students = enrollments.map(function(e) {
                        return e.student;
                    });

                    renderReports(students);
                    updateStatistics(students);
                }
            }
        } catch (error) {
            console.error('Error loading reports:', error);
            document.getElementById('reportsTableBody').innerHTML = 
                '<tr><td colspan="9" class="text-center text-error">Error loading reports</td></tr>';
        }
    }

    function renderReports(students) {
        const tbody = document.getElementById('reportsTableBody');

        if (students.length === 0) {
            tbody.innerHTML = '<tr><td colspan="9" class="text-center">No students enrolled</td></tr>';
            return;
        }

        tbody.innerHTML = students.map(function(student) {
            const studentAttendance = attendanceData.filter(function(a) {
                return a.studentId === student.userId;
            });

            const present = studentAttendance.filter(function(a) {
                return a.status === 'PRESENT';
            }).length;
            const absent = studentAttendance.filter(function(a) {
                return a.status === 'ABSENT';
            }).length;
            const late = studentAttendance.filter(function(a) {
                return a.status === 'LATE';
            }).length;
            const excused = studentAttendance.filter(function(a) {
                return a.status === 'EXCUSED';
            }).length;
            const total = studentAttendance.length;
            const attendancePercent = total > 0 ? Math.round(((present + late) / total) * 100) : 0;
            const percentClass = attendancePercent >= 80 ? 'text-success' : 
                               attendancePercent >= 60 ? 'text-warning' : 'text-error';

            return '<tr>' +
                '<td>' + escapeHtml(student.studentId || student.userId) + '</td>' +
                '<td class="font-semibold">' + escapeHtml(student.fullName) + '</td>' +
                '<td><span class="badge badge-success">' + present + '</span></td>' +
                '<td><span class="badge badge-error">' + absent + '</span></td>' +
                '<td><span class="badge badge-warning">' + late + '</span></td>' +
                '<td><span class="badge badge-info">' + excused + '</span></td>' +
                '<td>' + total + '</td>' +
                '<td><span class="font-bold ' + percentClass + '">' + attendancePercent + '%</span></td>' +
                '<td>' +
                    '<button onclick="viewStudentDetails(' + student.userId + ')" class="btn btn-sm btn-primary">Details</button>' +
                '</td>' +
            '</tr>';
        }).join('');
    }

    function updateStatistics(students) {
        document.getElementById('totalStudents').textContent = students.length;
        
        if (students.length === 0) {
            document.getElementById('avgAttendance').textContent = '-';
            document.getElementById('totalClasses').textContent = '-';
            document.getElementById('lowAttendance').textContent = '-';
            return;
        }

        // Calculate unique dates
        const uniqueDates = [...new Set(attendanceData.map(function(a) {
            return a.attendanceDate;
        }))];
        document.getElementById('totalClasses').textContent = uniqueDates.length;

        // Calculate average attendance
        let totalPercent = 0;
        let lowAttendanceCount = 0;
        students.forEach(function(student) {
            const studentAttendance = attendanceData.filter(function(a) {
                return a.studentId === student.userId;
            });
            const present = studentAttendance.filter(function(a) {
                return a.status === 'PRESENT' || a.status === 'LATE';
            }).length;
            const total = studentAttendance.length;
            const percent = total > 0 ? (present / total) * 100 : 0;
            totalPercent += percent;
            if (percent < 75) lowAttendanceCount++;
        });

        const avgPercent = students.length > 0 ? Math.round(totalPercent / students.length) : 0;
        document.getElementById('avgAttendance').textContent = avgPercent + '%';
        document.getElementById('lowAttendance').textContent = lowAttendanceCount;
    }

    function viewStudentDetails(studentId) {
        const studentAttendance = attendanceData.filter(function(a) {
            return a.studentId === studentId;
        });
        
        if (studentAttendance.length === 0) {
            alert('No attendance records for this student');
            return;
        }

        let details = 'Attendance Details:\n\n';
        studentAttendance.forEach(function(a) {
            details += a.attendanceDate + ': ' + a.status + 
                      (a.notes ? ' (' + a.notes + ')' : '') + '\n';
        });
        
        alert(details);
    }

    function exportReport() {
        if (!currentClassId) {
            alert('Please select a class');
            return;
        }

        // Create CSV content
        let csv = 'Student ID,Name,Present,Absent,Late,Excused,Total,Attendance %\n';
        
        const students = Array.from(document.querySelectorAll('#reportsTableBody tr')).map(function(row) {
            const cells = row.querySelectorAll('td');
            if (cells.length > 0) {
                return {
                    id: cells[0].textContent.trim(),
                    name: cells[1].textContent.trim(),
                    present: cells[2].textContent.trim(),
                    absent: cells[3].textContent.trim(),
                    late: cells[4].textContent.trim(),
                    excused: cells[5].textContent.trim(),
                    total: cells[6].textContent.trim(),
                    percent: cells[7].textContent.trim()
                };
            }
            return null;
        }).filter(function(s) {
            return s !== null;
        });

        students.forEach(function(s) {
            csv += s.id + ',' + s.name + ',' + s.present + ',' + s.absent + ',' + 
                   s.late + ',' + s.excused + ',' + s.total + ',' + s.percent + '\n';
        });

        // Download CSV
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'attendance_report_' + currentClassId + '_' + new Date().toISOString().split('T')[0] + '.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
</script>

