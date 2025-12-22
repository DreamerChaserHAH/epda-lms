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
    <title>Admin Dashboard | APU LMS</title>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="min-h-screen bg-gray-50">
    <!-- Navigation Bar -->
    <div class="navbar bg-primary text-white">
        <div class="flex-1">
            <a class="btn btn-ghost normal-case text-xl">APU LMS - Admin</a>
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
        <h1 class="text-3xl font-bold mb-6">Admin Dashboard</h1>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <!-- Card 1: User Management -->
            <div class="card bg-white shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">User Management</h2>
                    <p>Manage system users</p>
                    <div class="card-actions justify-end">
                        <button class="btn btn-primary">Manage Users</button>
                    </div>
                </div>
            </div>

            <!-- Card 2: System Settings -->
            <div class="card bg-white shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">System Settings</h2>
                    <p>Configure system parameters</p>
                    <div class="card-actions justify-end">
                        <button class="btn btn-primary">Settings</button>
                    </div>
                </div>
            </div>

            <!-- Card 3: Audit Logs -->
            <div class="card bg-white shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">Audit Logs</h2>
                    <p>View system activity logs</p>
                    <div class="card-actions justify-end">
                        <button class="btn btn-primary">View Logs</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if user is authenticated
    if (session.getAttribute("authenticated") == null ||
        !(Boolean)session.getAttribute("authenticated")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    username = (String) session.getAttribute("username");
    String role = session.getAttribute("role") != null ?
                  session.getAttribute("role").toString() : "STUDENT";
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard | APU LMS</title>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="min-h-screen bg-gray-50">
    <!-- Navigation Bar -->
    <div class="navbar bg-primary text-white">
        <div class="flex-1">
            <a class="btn btn-ghost normal-case text-xl">APU LMS - Student</a>
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
        <h1 class="text-3xl font-bold mb-6">Student Dashboard</h1>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <!-- Card 1: My Courses -->
            <div class="card bg-white shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">My Courses</h2>
                    <p>View and manage your enrolled courses</p>
                    <div class="card-actions justify-end">
                        <button class="btn btn-primary">View Courses</button>
                    </div>
                </div>
            </div>

            <!-- Card 2: Assignments -->
            <div class="card bg-white shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">Assignments</h2>
                    <p>Check your pending assignments</p>
                    <div class="card-actions justify-end">
                        <button class="btn btn-primary">View Assignments</button>
                    </div>
                </div>
            </div>

            <!-- Card 3: Grades -->
            <div class="card bg-white shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">Grades</h2>
                    <p>View your academic performance</p>
                    <div class="card-actions justify-end">
                        <button class="btn btn-primary">View Grades</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>

