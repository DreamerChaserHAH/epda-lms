<%@ page import="com.htetaung.lms.models.enums.UserRole" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Authentication check
    if (session.getAttribute("authenticated") == null || !(Boolean)session.getAttribute("authenticated")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String username = (String) session.getAttribute("username");
    UserRole role = (UserRole) session.getAttribute("role");
    String userId_parameter = request.getParameter("userId");
    String currentPage = request.getParameter("page");
    if (currentPage == null) currentPage = "dashboard";

    // Page navigation helper class
    class Page {
        final String name;
        final String link;
        final String icon_filename;

        Page(String name, String link, String icon_filename) {
            this.name = name;
            this.link = link;
            this.icon_filename = icon_filename;
        }
    }

    // Role-based navigation menu
    Page[] availablePages;
    switch (role) {
        case ADMIN:
            availablePages = new Page[]{
                new Page("Users", "users", "users.png"),
                new Page("Lecturers", "lecturer-assignment", "assign.png"),
                new Page("Classes", "classes", "classes.png"),
                new Page("Grading System", "grading", "settings.png")
            };
            break;
        case ACADEMIC_LEADER:
            availablePages = new Page[]{
                new Page("Modules", "modules", "books.png"),
                new Page("Reports", "reports-academic-leader", "reports.png")
            };
            break;
        case LECTURER:
            availablePages = new Page[]{
                new Page("Classes", "classes", "classes.png")
            };
            break;
        case STUDENT:
            availablePages = new Page[]{
                new Page("Assignments", "assignments", "assign.png"),
                new Page("My Results", "results", "results.png"),
                new Page("Calendar", "calendar", "calendar.png")
            };
            break;
        default:
            availablePages = new Page[]{};
    }

%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>APU LMS - <%= UserRole.roleToString(role) %></title>
    <link rel="icon" type="image/jpg" href="${pageContext.request.contextPath}/images/logos/logo_apu.jpg"/>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <script type="module" src="https://unpkg.com/cally"></script>
</head>
<body class="h-screen bg-base-200">
    <div class="flex h-full">
        <!-- Sidebar Navigation -->
        <aside class="w-64 bg-base-100 shadow-xl flex flex-col">
            <!-- Brand Header -->
            <div class="px-6 py-8 border-b border-base-300">
                <h1 class="text-3xl font-bold text-primary">APU LMS</h1>
                <p class="text-sm text-base-content/60 mt-1"><%= UserRole.roleToString(role) %></p>
            </div>
            
            <!-- Navigation Menu -->
            <nav class="flex-1 overflow-y-auto p-4">
                <ul class="menu menu-sm gap-1">
                    <!-- Dashboard -->
                    <li>
                        <a href="?page=dashboard"
                           class="<%= currentPage.equals("dashboard") ? "active" : "" %>">
                            <img src="<%= request.getContextPath()%>/images/icons/dashboard.png"
                                 alt="" class="w-5 h-5">
                            <span>Dashboard</span>
                        </a>
                    </li>

                    <!-- Profile -->
                    <li>
                        <a href="?page=profile"
                           class="<%= currentPage.equals("profile") ? "active" : "" %>">
                            <img src="<%= request.getContextPath()%>/images/icons/profile.png"
                                 alt="" class="w-5 h-5">
                            <span>Profile</span>
                        </a>
                    </li>

                    <!-- Dynamic Pages -->
                    <% for(Page availablePage : availablePages) { %>
                    <li>
                        <a href="?page=<%= availablePage.link %>"
                           class="<%= currentPage.equals(availablePage.link) ? "active" : "" %>">
                            <img src="<%= request.getContextPath()%>/images/icons/<%= availablePage.icon_filename %>"
                                 alt="" class="w-5 h-5">
                            <span><%= availablePage.name %></span>
                        </a>
                    </li>
                    <% } %>

                    <!-- Divider -->
                    <li class="menu-title mt-4">
                        <span>System</span>
                    </li>

                    <!-- Settings -->
                    <li>
                        <a href="?page=settings"
                           class="<%= currentPage.equals("settings") ? "active" : "" %>">
                            <img src="<%= request.getContextPath()%>/images/icons/settings.png"
                                 alt="" class="w-5 h-5">
                            <span>Settings</span>
                        </a>
                    </li>

                    <!-- Logout -->
                    <li>
                        <a href="<%= request.getContextPath()%>/logout" class="text-error hover:bg-error/10">
                            <img src="<%= request.getContextPath()%>/images/icons/logout.png"
                                 alt="" class="w-5 h-5">
                            <span>Logout</span>
                        </a>
                    </li>
                </ul>
            </nav>
        </aside>

        <!-- Main Content Area -->
        <main class="flex-1 overflow-y-auto">
            <div class="container mx-auto p-6 max-w-7xl">
                <!-- Page Header -->
                <div class="mb-6">
                    <h1 class="text-3xl lg:text-4xl font-bold text-base-content">
                        <%= UserRole.roleToString(role) %> Portal
                    </h1>
                    <p class="text-base-content/70 mt-2">Welcome back, <%= username %>!</p>
                </div>

                <!-- Dynamic Content -->
                <c:set var="role" value="<%= UserRole.roleToString(role).toLowerCase() %>"/>
                <c:set var="pageToInclude" value="/WEB-INF/components/${role}/${param.page != null ? param.page : 'dashboard'}.jsp"/>
                <jsp:include page="${pageToInclude}">
                    <jsp:param name="userId" value="<%= userId_parameter %>"/>
                    <jsp:param name="username" value="<%= username %>"/>
                    <jsp:param name="contextPath" value="${pageContext.request.contextPath}"/>
                </jsp:include>

                <!-- Modal Messages -->
                <jsp:include page="/WEB-INF/components/modal-message.jsp"/>
            </div>
        </main>
    </div>
</body>
</html>

