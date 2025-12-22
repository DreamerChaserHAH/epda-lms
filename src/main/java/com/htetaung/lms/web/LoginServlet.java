package com.htetaung.lms.web;

import com.htetaung.lms.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "loginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    // Demo credentials storage (in a real application, use a database)
    private static final Map<String, UserCredential> DEMO_USERS = new HashMap<>();

    static {
        DEMO_USERS.put("admin", new UserCredential("admin", "admin123", User.Role.ADMIN));
        DEMO_USERS.put("leader", new UserCredential("leader", "leader123", User.Role.LEADER));
        DEMO_USERS.put("lecturer", new UserCredential("lecturer", "lecturer123", User.Role.LECTURER));
        DEMO_USERS.put("student", new UserCredential("student", "student123", User.Role.STUDENT));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to login page
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String roleParam = request.getParameter("role");

        // Validate input
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            roleParam == null || roleParam.trim().isEmpty()) {

            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        try {
            User.Role selectedRole = User.Role.valueOf(roleParam);

            // Authenticate user
            UserCredential userCred = DEMO_USERS.get(username.toLowerCase());

            if (userCred != null && userCred.password.equals(password) &&
                userCred.role == selectedRole) {

                // Authentication successful
                HttpSession session = request.getSession(true);
                session.setAttribute("username", username);
                session.setAttribute("role", selectedRole);
                session.setAttribute("authenticated", true);

                // Redirect to appropriate dashboard based on role
                String redirectUrl = getDashboardUrl(selectedRole);
                response.sendRedirect(request.getContextPath());

            } else {
                // Authentication failed
                request.setAttribute("error", "Invalid username, password, or role");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid role selected");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private String getDashboardUrl(User.Role role) {
        return switch (role) {
            case ADMIN -> "/admin/dashboard";
            case LEADER -> "/leader/dashboard";
            case LECTURER -> "/lecturer/dashboard";
            case STUDENT -> "/student/dashboard";
        };
    }

    // Inner class to store demo credentials
    private static class UserCredential {
        String username;
        String password;
        User.Role role;

        UserCredential(String username, String password, User.Role role) {
            this.username = username;
            this.password = password;
            this.role = role;
        }
    }
}

