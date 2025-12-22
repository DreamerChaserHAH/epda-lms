<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if user is authenticated
    if (session.getAttribute("authenticated") == null ||
            !(Boolean)session.getAttribute("authenticated")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String username = (String) session.getAttribute("username");
    String role = session.getAttribute("role") != null ?
            session.getAttribute("role").toString() : "STUDENT";
    
    // Get current page for active menu highlighting
    String currentPage = request.getParameter("page");
    if (currentPage == null) currentPage = "dashboard";
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | APU AMS</title>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <style>
        .menu-item {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem 1rem;
            border-radius: 0.5rem;
            transition: all 0.2s;
            text-decoration: none;
            color: #6b7280;
        }
        .menu-item:hover {
            background-color: #f3f4f6;
            color: #1f2937;
        }
        .menu-item.active {
            background-color: #dbeafe;
            color: #2563eb;
        }
        .menu-icon {
            width: 1.25rem;
            height: 1.25rem;
        }
    </style>
</head>
<body class="min-h-screen bg-base-200">
    <div class="flex h-screen">
        <!-- Sidebar -->
        <aside class="w-64 bg-white shadow-lg flex flex-col">
            <!-- Logo/Brand -->
            <div class="p-6 border-b">
                <h1 class="text-2xl font-bold text-primary">APU AMS</h1>
            </div>
            
            <!-- Navigation Menu -->
            <nav class="flex-1 p-4 space-y-2">
                <!-- Dashboard - Always visible -->
                <a href="?page=dashboard" class="menu-item <%= currentPage.equals("dashboard") ? "active" : "" %>">
                    <svg class="menu-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
                    </svg>
                    <span>Dashboard</span>
                </a>

                <% if ("ADMIN".equals(role)) { %>
                <!-- Admin-specific menu items -->
                <a href="?page=users" class="menu-item <%= currentPage.equals("users") ? "active" : "" %>">
                    <svg class="menu-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                    </svg>
                    <span>Users</span>
                </a>

                <a href="?page=modules" class="menu-item <%= currentPage.equals("modules") ? "active" : "" %>">
                    <svg class="menu-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
                    </svg>
                    <span>Modules</span>
                </a>

                <a href="?page=classes" class="menu-item <%= currentPage.equals("classes") ? "active" : "" %>">
                    <svg class="menu-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                    </svg>
                    <span>Classes</span>
                </a>

                <a href="?page=grading" class="menu-item <%= currentPage.equals("grading") ? "active" : "" %>">
                    <svg class="menu-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"/>
                    </svg>
                    <span>Grading System</span>
                </a>

                <a href="?page=reports" class="menu-item <%= currentPage.equals("reports") ? "active" : "" %>">
                    <svg class="menu-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                    </svg>
                    <span>Reports</span>
                </a>
                <% } %>

                <!-- Settings - Always visible -->
                <a href="?page=settings" class="menu-item <%= currentPage.equals("settings") ? "active" : "" %>">
                    <svg class="menu-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                    </svg>
                    <span>Settings</span>
                </a>

                <!-- Logout - Always visible -->
                <a href="${pageContext.request.contextPath}/logout" class="menu-item">
                    <svg class="menu-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                    </svg>
                    <span>Logout</span>
                </a>
            </nav>
        </aside>

        <!-- Main Content Area -->
        <main class="flex-1 overflow-y-auto">
            <div class="p-8">
                <%
                if ("dashboard".equals(currentPage)) {
                %>
                    <!-- Dashboard Content -->
                    <div class="mb-8">
                        <h1 class="text-3xl font-bold text-gray-800">Admin Dashboard</h1>
                        <p class="text-gray-600 mt-2">Welcome back, System Admin</p>
                    </div>

                    <!-- Dashboard Cards -->
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <!-- Manage Users Card -->
                        <div class="card bg-white shadow-lg hover:shadow-xl transition-shadow">
                            <div class="card-body">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="p-3 bg-blue-100 rounded-lg">
                                        <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                                        </svg>
                                    </div>
                                </div>
                                <h2 class="card-title text-gray-800">Manage Users</h2>
                                <p class="text-gray-600 text-sm">Create, edit, and delete user accounts</p>
                                <p class="text-blue-600 font-semibold mt-2">5 total users</p>
                            </div>
                        </div>

                        <!-- View Modules Card -->
                        <div class="card bg-white shadow-lg hover:shadow-xl transition-shadow">
                            <div class="card-body">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="p-3 bg-green-100 rounded-lg">
                                        <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
                                        </svg>
                                    </div>
                                </div>
                                <h2 class="card-title text-gray-800">View Modules</h2>
                                <p class="text-gray-600 text-sm">Browse all academic modules</p>
                                <p class="text-green-600 font-semibold mt-2">3 modules</p>
                            </div>
                        </div>

                        <!-- Create Classes Card -->
                        <div class="card bg-white shadow-lg hover:shadow-xl transition-shadow">
                            <div class="card-body">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="p-3 bg-purple-100 rounded-lg">
                                        <svg class="w-8 h-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                                        </svg>
                                    </div>
                                </div>
                                <h2 class="card-title text-gray-800">Create Classes</h2>
                                <p class="text-gray-600 text-sm">Assign students and lecturers to classes</p>
                                <p class="text-purple-600 font-semibold mt-2">3 classes</p>
                            </div>
                        </div>

                        <!-- Grading System Card -->
                        <div class="card bg-white shadow-lg hover:shadow-xl transition-shadow">
                            <div class="card-body">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="p-3 bg-orange-100 rounded-lg">
                                        <svg class="w-8 h-8 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"/>
                                        </svg>
                                    </div>
                                </div>
                                <h2 class="card-title text-gray-800">Grading System</h2>
                                <p class="text-gray-600 text-sm">Define grade boundaries and scales</p>
                                <p class="text-orange-600 font-semibold mt-2">10 grade levels</p>
                            </div>
                        </div>

                        <!-- View Reports Card -->
                        <div class="card bg-white shadow-lg hover:shadow-xl transition-shadow">
                            <div class="card-body">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="p-3 bg-red-100 rounded-lg">
                                        <svg class="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                                        </svg>
                                    </div>
                                </div>
                                <h2 class="card-title text-gray-800">View Reports</h2>
                                <p class="text-gray-600 text-sm">Access system-wide analytics</p>
                                <p class="text-red-600 font-semibold mt-2">5 total marks</p>
                            </div>
                        </div>

                        <!-- Settings Card -->
                        <div class="card bg-white shadow-lg hover:shadow-xl transition-shadow">
                            <div class="card-body">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="p-3 bg-gray-100 rounded-lg">
                                        <svg class="w-8 h-8 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                        </svg>
                                    </div>
                                </div>
                                <h2 class="card-title text-gray-800">Settings</h2>
                                <p class="text-gray-600 text-sm">Configure system preferences</p>
                            </div>
                        </div>
                    </div>

                <%
                } else {
                %>
                <jsp:include page="settings.jsp">
                    <jsp:param name="username" value="<%= username %>"/>
                </jsp:include>

                <%
                }
                %>
            </div>
        </main>
    </div>
</body>
</html>

