<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if user is authenticated
    if (session.getAttribute("authenticated") == null ||
        !(Boolean)session.getAttribute("authenticated")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Academic Leader Dashboard | APU LMS</title>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="min-h-screen bg-gray-50">
    <!-- Navigation Bar -->
    <div class="navbar bg-primary text-white">
        <div class="flex-1">
            <a class="btn btn-ghost normal-case text-xl">APU LMS - Academic Leader</a>
        </div>
        <div class="flex-none">
            <div class="dropdown dropdown-end">
                <label tabindex="0" class="btn btn-ghost">
                    Welcome, <%= username %>
                </label>
                <ul tabindex="0" class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52 text-gray-700">
                    <li><a href="${pageContext.request.contextPath}/logout">Logout</a></li>
                </ul>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6">Academic Leader Dashboard</h1>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <!-- Card 1: Program Management -->
            <div class="card bg-white shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">Program Management</h2>
                    <p>Manage academic programs</p>
                    <div class="card-actions justify-end">
                        <button class="btn btn-primary">View Programs</button>
                    </div>
                </div>
            </div>

            <!-- Card 2: Course Approval -->
            <div class="card bg-white shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">Course Approval</h2>
                    <p>Approve course offerings</p>
                    <div class="card-actions justify-end">
                        <button class="btn btn-primary">Review Courses</button>
                    </div>
                </div>
            </div>

            <!-- Card 3: Reports -->
            <div class="card bg-white shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">Academic Reports</h2>
                    <p>View performance analytics</p>
                    <div class="card-actions justify-end">
                        <button class="btn btn-primary">View Reports</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>

