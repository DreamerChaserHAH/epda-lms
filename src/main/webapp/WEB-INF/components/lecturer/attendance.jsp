<%--
  Attendance Marking Interface for Lecturers
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
        <h1 class="text-3xl font-bold text-gray-800 mb-2">Mark Attendance</h1>
        <p class="text-gray-600">Mark attendance for your classes</p>
    </div>

    <!-- Class Selection -->
    <div class="card bg-base-100 shadow-lg mb-6">
        <div class="card-body">
            <div class="flex gap-4 items-end">
                <div class="form-control flex-1">
                    <label class="label">
                        <span class="label-text font-semibold">Select Class</span>
                    </label>
                    <select id="classSelect" class="select select-bordered" onchange="loadClassStudents()">
                        <option value="">Select a class...</option>
                    </select>
                </div>
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Date</span>
                    </label>
                    <input type="date" id="attendanceDate" class="input input-bordered" 
                           value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" 
                           onchange="loadAttendanceForDate()" />
                </div>
                <button onclick="loadClassStudents()" class="btn btn-primary">Load Students</button>
            </div>
        </div>
    </div>

    <!-- Attendance Table -->
    <div class="card bg-base-100 shadow-lg">
        <div class="card-body">
            <div id="attendanceTableContainer">
                <div class="text-center p-8">
                    <p class="text-gray-500">Please select a class to mark attendance</p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    let currentClassId = null;
    let students = [];
    let attendanceData = {};
    const classApi = '<%= request.getContextPath() %>/api/classes';
    const attendanceApi = '<%= request.getContextPath() %>/api/attendance';
    const enrollmentApi = '<%= request.getContextPath() %>/api/enrollments';
    const userId = <%= userId != null ? userId : 0 %>;

    document.addEventListener('DOMContentLoaded', function() {
        loadLecturerClasses();
    });

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

    async function loadClassStudents() {
        currentClassId = document.getElementById('classSelect').value;
        const date = document.getElementById('attendanceDate').value;

        if (!currentClassId) {
            document.getElementById('attendanceTableContainer').innerHTML = 
                '<div class="text-center p-8"><p class="text-gray-500">Please select a class</p></div>';
            return;
        }

        try {
            // Load enrolled students
            const enrollResponse = await fetch(enrollmentApi + '?classId=' + currentClassId);
            if (enrollResponse.ok) {
                const enrollments = await enrollResponse.json();
                students = enrollments.map(function(e) {
                    return e.student;
                });

                // Load existing attendance for the date
                if (date) {
                    const attResponse = await fetch(attendanceApi + '?classId=' + currentClassId + '&date=' + date);
                    if (attResponse.ok) {
                        const attendance = await attResponse.json();
                        attendanceData = {};
                        attendance.forEach(function(a) {
                            attendanceData[a.studentId] = a;
                        });
                    }
                }

                renderAttendanceTable();
            }
        } catch (error) {
            console.error('Error loading students:', error);
            document.getElementById('attendanceTableContainer').innerHTML = 
                '<div class="text-center p-8 text-error">Error loading students</div>';
        }
    }

    async function loadAttendanceForDate() {
        if (currentClassId) {
            await loadClassStudents();
        }
    }

    function renderAttendanceTable() {
        const container = document.getElementById('attendanceTableContainer');
        const date = document.getElementById('attendanceDate').value;

        if (students.length === 0) {
            container.innerHTML = '<div class="text-center p-8"><p class="text-gray-500">No students enrolled in this class</p></div>';
            return;
        }

        let html = '<div class="overflow-x-auto">' +
            '<table class="table table-zebra w-full">' +
            '<thead>' +
            '<tr>' +
            '<th>Student ID</th>' +
            '<th>Name</th>' +
            '<th>Status</th>' +
            '<th>Notes</th>' +
            '<th>Actions</th>' +
            '</tr>' +
            '</thead>' +
            '<tbody>';

        students.forEach(function(student) {
            const existing = attendanceData[student.userId];
            const currentStatus = existing ? existing.status : 'ABSENT';
            
            html += '<tr>' +
                '<td>' + escapeHtml(student.studentId || student.userId) + '</td>' +
                '<td class="font-semibold">' + escapeHtml(student.fullName) + '</td>' +
                '<td>' +
                    '<select id="status_' + student.userId + '" class="select select-bordered select-sm">' +
                        '<option value="PRESENT"' + (currentStatus === 'PRESENT' ? ' selected' : '') + '>Present</option>' +
                        '<option value="ABSENT"' + (currentStatus === 'ABSENT' ? ' selected' : '') + '>Absent</option>' +
                        '<option value="LATE"' + (currentStatus === 'LATE' ? ' selected' : '') + '>Late</option>' +
                        '<option value="EXCUSED"' + (currentStatus === 'EXCUSED' ? ' selected' : '') + '>Excused</option>' +
                    '</select>' +
                '</td>' +
                '<td>' +
                    '<input type="text" id="notes_' + student.userId + '" class="input input-bordered input-sm w-full" ' +
                    'placeholder="Optional notes" value="' + (existing && existing.notes ? escapeHtml(existing.notes) : '') + '" />' +
                '</td>' +
                '<td>' +
                    '<button onclick="saveAttendance(' + student.userId + ')" class="btn btn-sm btn-primary">Save</button>' +
                '</td>' +
            '</tr>';
        });

        html += '</tbody></table></div>' +
            '<div class="mt-4 flex justify-end gap-2">' +
            '<button onclick="saveAllAttendance()" class="btn btn-primary">Save All</button>' +
            '<a href="?page=attendance_reports&classId=' + currentClassId + '" class="btn btn-info">View Reports</a>' +
            '</div>';

        container.innerHTML = html;
    }

    async function saveAttendance(studentId) {
        if (!currentClassId) {
            alert('Please select a class');
            return;
        }

        const date = document.getElementById('attendanceDate').value;
        if (!date) {
            alert('Please select a date');
            return;
        }

        const status = document.getElementById('status_' + studentId).value;
        const notes = document.getElementById('notes_' + studentId).value;

        try {
            const formData = new URLSearchParams();
            formData.append('classId', currentClassId);
            formData.append('studentId', studentId);
            formData.append('date', date);
            formData.append('status', status);
            if (notes) formData.append('notes', notes);

            const response = await fetch(attendanceApi, {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: formData.toString()
            });

            if (response.ok) {
                alert('Attendance saved successfully');
                await loadClassStudents();
            } else {
                const error = await response.json();
                alert('Error: ' + (error.error || 'Failed to save attendance'));
            }
        } catch (error) {
            console.error('Error saving attendance:', error);
            alert('Error saving attendance: ' + error.message);
        }
    }

    async function saveAllAttendance() {
        if (!currentClassId) {
            alert('Please select a class');
            return;
        }

        const date = document.getElementById('attendanceDate').value;
        if (!date) {
            alert('Please select a date');
            return;
        }

        const promises = students.map(function(student) {
            const studentId = student.userId;
            const status = document.getElementById('status_' + studentId).value;
            const notes = document.getElementById('notes_' + studentId).value;

            const formData = new URLSearchParams();
            formData.append('classId', currentClassId);
            formData.append('studentId', studentId);
            formData.append('date', date);
            formData.append('status', status);
            if (notes) formData.append('notes', notes);

            return fetch(attendanceApi, {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: formData.toString()
            });
        });

        try {
            await Promise.all(promises);
            alert('All attendance saved successfully');
            await loadClassStudents();
        } catch (error) {
            console.error('Error saving attendance:', error);
            alert('Error saving attendance: ' + error.message);
        }
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
</script>

