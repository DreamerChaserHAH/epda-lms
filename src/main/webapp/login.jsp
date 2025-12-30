<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Redirect if already authenticated
    if (session.getAttribute("authenticated") != null && (Boolean)session.getAttribute("authenticated")) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>APU LMS | Login</title>
    <link rel="icon" type="image/jpg" href="${pageContext.request.contextPath}/images/logos/logo_apu.jpg"/>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="min-h-screen bg-base-200 flex items-center justify-center p-4">
    <!-- Login Card -->
    <div class="card w-full max-w-md bg-base-100 shadow-2xl">
        <div class="card-body">
            <!-- Logo and Title -->
            <div class="text-center mb-6">
                <div class="flex justify-center mb-4">
                    <div class="avatar placeholder">
                        <div class="bg-primary text-primary-content rounded-2xl w-20">
                            <img src="${pageContext.request.contextPath}/images/icons/books.png"
                                 alt="APU LMS" class="w-10 h-10">
                        </div>
                    </div>
                </div>
                <h1 class="text-3xl font-bold text-base-content mb-2">APU LMS</h1>
                <p class="text-base-content/70">Academic Management System</p>
            </div>

            <!-- Error Alert -->
            <% if (request.getAttribute("error") != null) { %>
            <div role="alert" class="alert alert-error mb-4">
                <img src="${pageContext.request.contextPath}/images/icons/error.png"
                     alt="Error" class="w-6 h-6 shrink-0">
                <span><%= request.getAttribute("error") %></span>
            </div>
            <% } %>

            <!-- Login Form -->
            <form method="post" action="${pageContext.request.contextPath}/login" class="space-y-4">
                <!-- Username -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text">Username</span>
                    </label>
                    <input type="text"
                           name="username"
                           placeholder="Enter your username"
                           class="input input-bordered w-full focus:input-primary"
                           required
                           autofocus />
                </div>

                <!-- Password -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text">Password</span>
                    </label>
                    <input type="password"
                           name="password"
                           placeholder="Enter your password"
                           class="input input-bordered w-full focus:input-primary"
                           required />
                </div>

                <!-- Role Selection -->
                <div class="form-control">
                    <label class="label">
                        <span class="label-text">Role</span>
                    </label>
                    <select name="role" class="select select-bordered w-full focus:select-primary" required>
                        <option value="STUDENT">Student</option>
                        <option value="LECTURER">Lecturer</option>
                        <option value="ACADEMIC_LEADER">Academic Leader</option>
                        <option value="ADMIN">Administrator</option>
                    </select>
                </div>

                <!-- Submit Button -->
                <div class="form-control mt-6">
                    <button type="submit" class="btn btn-primary w-full">
                        <img src="${pageContext.request.contextPath}/images/icons/login-arrow.png"
                             alt="Login" class="h-5 w-5 mr-2">
                        Sign In
                    </button>
                </div>
            </form>

            <!-- Demo Credentials -->
            <div class="divider">Demo Credentials</div>
            <div class="bg-base-200 rounded-lg p-4">
                <div class="grid grid-cols-2 gap-3 text-sm">
                    <div class="space-y-1">
                        <div class="flex items-center gap-2">
                            <div class="badge badge-primary badge-sm">Admin</div>
                            <code class="text-xs">admin / admin123</code>
                        </div>
                        <div class="flex items-center gap-2">
                            <div class="badge badge-secondary badge-sm">Leader</div>
                            <code class="text-xs">leader / leader123</code>
                        </div>
                    </div>
                    <div class="space-y-1">
                        <div class="flex items-center gap-2">
                            <div class="badge badge-accent badge-sm">Lecturer</div>
                            <code class="text-xs">lecturer / lecturer123</code>
                        </div>
                        <div class="flex items-center gap-2">
                            <div class="badge badge-info badge-sm">Student</div>
                            <code class="text-xs">student / student123</code>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <div class="text-center mt-4">
                <p class="text-xs text-base-content/60">
                    © 2025 Asia Pacific University. All rights reserved.
                </p>
            </div>
        </div>
    </div>
</body>
</html>
