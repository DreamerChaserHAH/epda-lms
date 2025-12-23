<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>User Registration - LMS</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 500px;
            margin: 50px auto;
            padding: 20px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input, select {
            width: 100%;
            padding: 8px;
            box-sizing: border-box;
        }
        .error {
            color: red;
            padding: 10px;
            background-color: #ffe6e6;
            border: 1px solid red;
            margin-bottom: 15px;
            border-radius: 4px;
        }
        .btn {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            cursor: pointer;
            width: 100%;
        }
        .btn:hover {
            background-color: #45a049;
        }
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
<h2>User Registration</h2>

<% if (request.getAttribute("error") != null) { %>
<div class="error">
    <%= request.getAttribute("error") %>
</div>
<% } %>

<form method="post" action="${pageContext.request.contextPath}/register">
    <div class="form-group">
        <label for="username">Username *</label>
        <input type="text" id="username" name="username" required/>
    </div>

    <div class="form-group">
        <label for="fullName">Full Name *</label>
        <input type="text" id="fullName" name="fullName" required/>
    </div>

    <div class="form-group">
        <label for="password">Password *</label>
        <input type="password" id="password" name="password" required/>
    </div>

    <div class="form-group">
        <label for="confirmPassword">Confirm Password *</label>
        <input type="password" id="confirmPassword" name="confirmPassword" required/>
    </div>

    <div class="form-group">
        <label for="role">Role *</label>
        <select id="role" name="role" required onchange="toggleRoleFields()">
            <option value="">Select Role</option>
            <option value="STUDENT">Student</option>
            <option value="LECTURER">Lecturer</option>
            <option value="ACADEMIC_LEADER">Academic Leader</option>
            <option value="ADMIN">Admin</option>
        </select>
    </div>

    <div id="studentFields" class="hidden">
        <div class="form-group">
            <label for="studentId">Student ID</label>
            <input type="text" id="studentId" name="studentId"/>
        </div>
        <div class="form-group">
            <label for="programmeIdStudent">Programme ID *</label>
            <input type="number" id="programmeIdStudent" name="programmeId"/>
        </div>
    </div>

    <div id="lecturerFields" class="hidden">
        <div class="form-group">
            <label for="staffNumber">Staff Number</label>
            <input type="text" id="staffNumber" name="staffNumber"/>
        </div>
        <div class="form-group">
            <label for="departmentIdLecturer">Department ID *</label>
            <input type="number" id="departmentIdLecturer" name="departmentId"/>
        </div>
    </div>

    <div id="academicLeaderFields" class="hidden">
        <div class="form-group">
            <label for="departmentIdAL">Department ID *</label>
            <input type="number" id="departmentIdAL" name="departmentId"/>
        </div>
        <div class="form-group">
            <label for="programmeIdAL">Programme ID *</label>
            <input type="number" id="programmeIdAL" name="programmeId"/>
        </div>
    </div>

    <button type="submit" class="btn">Register</button>
</form>

<p style="text-align: center; margin-top: 20px;">
    Already have an account? <a href="${pageContext.request.contextPath}/login">Login here</a>
</p>

<script>
    function toggleRoleFields() {
        const role = document.getElementById('role').value;

        // Hide all role-specific fields
        document.getElementById('studentFields').classList.add('hidden');
        document.getElementById('lecturerFields').classList.add('hidden');
        document.getElementById('academicLeaderFields').classList.add('hidden');

        // Show relevant fields based on role
        if (role === 'STUDENT') {
            document.getElementById('studentFields').classList.remove('hidden');
        } else if (role === 'LECTURER') {
            document.getElementById('lecturerFields').classList.remove('hidden');
        } else if (role === 'ACADEMIC_LEADER') {
            document.getElementById('academicLeaderFields').classList.remove('hidden');
        }
    }
</script>
</body>
</html>
