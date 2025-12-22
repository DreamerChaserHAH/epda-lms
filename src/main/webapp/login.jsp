<%@ page import="com.htetaung.lms.entity.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if user is authenticated
    if (session.getAttribute("authenticated") != null) {
        if ((Boolean)session.getAttribute("authenticated")) {
            User.Role role = (User.Role) session.getAttribute("role");
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>APU LMS | Login</title>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="min-h-screen bg-gray-50 flex items-center justify-center p-4">
    <div class="card w-full max-w-md bg-white shadow-xl">
        <div class="card-body">
            <!-- Logo and Title -->
            <div class="text-center mb-6">
                <div class="flex justify-center mb-4">
                    <div class="bg-primary rounded-2xl p-4 w-20 h-20 flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-10 h-10 text-white">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25" />
                        </svg>
                    </div>
                </div>
                <h1 class="text-2xl font-semibold text-gray-800 mb-2">APU Academic Management System</h1>
                <p class="text-gray-500">Sign in to continue</p>
            </div>

            <!-- Error Message -->
            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error shadow-lg mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span><%= request.getAttribute("error") %></span>
            </div>
            <% } %>

            <!-- Login Form -->
            <form method="post" action="${pageContext.request.contextPath}/login" class="space-y-4">
                <!-- Username Field -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text text-gray-700">Username</span>
                    </label>
                    <input type="text" name="username" placeholder="Enter your username" 
                           class="input input-bordered w-full" required />
                </div>

                <!-- Password Field -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text text-gray-700">Password</span>
                    </label>
                    <input type="password" name="password" placeholder="Enter your password" 
                           class="input input-bordered w-full" required />
                </div>

                <!-- Role Selection -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text text-gray-700">Role</span>
                    </label>
                    <select name="role" class="select select-bordered w-full" required>
                        <option value="STUDENT">Student</option>
                        <option value="LECTURER">Lecturer</option>
                        <option value="LEADER">Academic Leader</option>
                        <option value="ADMIN">Admin</option>
                    </select>
                </div>

                <!-- Sign In Button -->
                <div class="form-control mt-6">
                    <button type="submit" class="btn btn-primary w-full text-white">Sign In</button>
                </div>
            </form>

            <!-- Demo Credentials -->
            <div class="mt-6 bg-gray-50 rounded-lg p-4">
                <p class="text-sm font-semibold text-gray-700 mb-2">Demo Credentials:</p>
                <div class="text-sm text-gray-600 space-y-1">
                    <p>Admin: admin / admin123</p>
                    <p>Leader: leader / leader123</p>
                    <p>Lecturer: lecturer / lecturer123</p>
                    <p>Student: student / student123</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
