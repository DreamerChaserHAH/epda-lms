<%@ page import="com.htetaung.lms.models.User" %>
<%@ page import="com.htetaung.lms.models.enums.UserRole" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    // Check if user is authenticated
    if (session.getAttribute("authenticated") == null ||
            !(Boolean)session.getAttribute("authenticated")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String username = (String) session.getAttribute("username");
    UserRole role_object = (UserRole) session.getAttribute("role");
    String role = role_object != null ?
                UserRole.roleToString(role_object) : "student";
    
    // Get current page for active menu highlighting

    class Page {
        String name;
        String link;
        String icon_filename;

        Page(String name, String link, String icon_filename) {
            this.name = name;
            this.link = link;
            this.icon_filename = icon_filename;
        }
    }

    Page[] availablePages;
    switch (role) {
        case "ADMIN":
            //availablePages = new String[]{ "Users", "Modules", "Classes", "Grading Reports"};
            availablePages = new Page[]{
                    new Page("Users", "users", "users.png"),
                    new Page("Modules", "modules", "books.png"),
                    new Page("Classes", "classes", "classes.png"),
                    new Page("Grading Reports", "grading_reports", "reports.png")
            };
            break;
        case "AcademicLeader":
            //availablePages = new String[]{ "Modules", "Assign Lecturers"};
            availablePages = new Page[]{
                    new Page("Modules", "modules", "books.png"),
                    new Page("Assign Lecturers", "assign_lecturers", "assign.png")
            };
            break;
        case "Lecturer":
            //availablePages = new String[]{ "Modules"};
            availablePages = new Page[]{
                    new Page("Modules", "modules", "books.png"),
            };
            break;
        case "Student":
            availablePages = new Page[] {
                    new Page("My Results", "my_results", "results.png"),
                    new Page("Calendar", "calendar", "calendar.png"),
                    new Page("Assignments", "assignments", "upload.png")
            };
            break;
        default:
            availablePages = new Page[]{};
    }
    String currentPage = request.getParameter("page");
    if (currentPage == null) currentPage = "dashboard";
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>APU LMS</title>
    <link rel="icon" type="image/jpg" href="${pageContext.request.contextPath}/images/logos/logo_apu.jpg"/>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <script type="module" src="https://unpkg.com/cally"></script>
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
                    <img src="${pageContext.request.contextPath}/images/icons/dashboard.png" alt="Dashboard" class="menu-icon">
                    <span>Dashboard</span>
                </a>

                <a href="?page=profile" class="menu-item <%= currentPage.equals("profile") ? "active" : "" %>">
                    <img src="${pageContext.request.contextPath}/images/icons/profile.png" alt="Profile" class="menu-icon">
                    <span>Profile</span>
                </a>

                <% for(Page availablePage : availablePages) { %>
                <a href="?page=<%= availablePage.link %>" class="menu-item <%= currentPage.equals(availablePage.link) ? "active" : "" %>">
                    <img src="${pageContext.request.contextPath}/images/icons/<%= availablePage.icon_filename %>" alt="<%= availablePage.name %>" class="menu-icon">
                    <span><%= availablePage.name %></span>
                </a>
                <% } %>

                <!-- Settings - Always visible -->
                <a href="?page=settings" class="menu-item <%= currentPage.equals("settings") ? "active" : "" %>">
                    <img src="${pageContext.request.contextPath}/images/icons/settings.png" alt="Settings" class="menu-icon">
                    <span>Settings</span>
                </a>

                <!-- Logout - Always visible -->
                <a href="${pageContext.request.contextPath}/logout" class="menu-item">
                    <img src="${pageContext.request.contextPath}/images/icons/logout.png" alt="Logout" class="menu-icon">
                    <span>Logout</span>
                </a>
            </nav>
        </aside>

        <!-- Main Content Area -->
        <main class="flex-1 overflow-y-auto p-6">

            <h1 class="text-2xl md:text-3xl lg:text-4xl font-bold font-title pr-6"><%= role %> Interface</h1>
            <p class="text-lg text-gray-500 pr-6 pt-4 pb-4">Welcome back, <%= username %>!</p>

            <c:set var="role" value="<%= role.toLowerCase() %>"/>
            <c:set var="pageToInclude" value="/WEB-INF/components/${role}/${
                 param.page != null ? param.page : 'dashboard'
            }.jsp"/>
            <jsp:include page="${pageToInclude}">
                <jsp:param name="username" value="<%= username %>"/>
            </jsp:include>

        </main>
    </div>
</body>
</html>

