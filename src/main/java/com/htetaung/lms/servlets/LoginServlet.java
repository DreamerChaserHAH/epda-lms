package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.UserServiceFacade;
import com.htetaung.lms.models.User;
import com.htetaung.lms.exception.AuthenticationException;
import com.htetaung.lms.models.enums.UserRole;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "loginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @EJB
    private UserServiceFacade userServiceFacade;

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

        // Trim and validate input
        if (username == null || password == null || roleParam == null) {
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        username = username.trim();
        password = password.trim();
        roleParam = roleParam.trim();

        if (username.isEmpty() || password.isEmpty() || roleParam.isEmpty()) {
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        UserRole selectedRole;
        try {
            selectedRole = UserRole.valueOf(roleParam);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid role selected");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        try {
            // Authenticate user
            User user = userServiceFacade.authenticateUser(username, password, selectedRole);

            HttpSession session = request.getSession(true);
            session.setAttribute("username", user.getUsername());
            session.setAttribute("role", user.getRole());
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("authenticated", true);

            response.sendRedirect(request.getContextPath() + "/index.jsp");

        } catch (AuthenticationException e) {
            // Handle authentication failures (username not found, wrong password, wrong role)
            request.setAttribute("error", e.getMessage());
            request.setAttribute("username", username);
            request.setAttribute("role", roleParam);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } catch (Exception e) {
            // Handle unexpected exceptions
            request.setAttribute("error", "An unexpected error occurred during login");
            request.setAttribute("username", username);
            request.setAttribute("role", roleParam);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}

