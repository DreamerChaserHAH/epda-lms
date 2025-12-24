package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.*;
import com.htetaung.lms.ejbs.services.UserServiceFacade;
import com.htetaung.lms.models.enums.UserRole;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "registrationServlet", urlPatterns = {"/register"})
public class UserRegistrationServlet extends HttpServlet {

    @EJB
    public UserServiceFacade userServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String fullName = request.getParameter("fullName");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            String roleParam = request.getParameter("role");

            String programmeId = request.getParameter("programmeId");
            String departmentId = request.getParameter("departmentId");

            // Validate input
            if (username == null || username.trim().isEmpty() ||
                    fullName == null || fullName.trim().isEmpty() ||
                    password == null || password.trim().isEmpty() ||
                    roleParam == null) {
                request.setAttribute("error", "All fields are required");
                doGet(request, response);
                return;
            }

            // Validate password match
            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Passwords do not match");
                doGet(request, response);
                return;
            }

            UserRole role = UserRole.valueOf(roleParam);
            HashMap<String, String> additionalInfo = new HashMap<String, String>();
            switch (role){
                case ADMIN -> {
                    additionalInfo.put("departmentId", "0");
                }
                case ACADEMIC_LEADER -> {
                    if (departmentId == null || departmentId.trim().isEmpty()) {
                        request.setAttribute("error", "Department is required for Academic Leader");
                        doGet(request, response);
                        return;
                    }
                    if (programmeId == null || programmeId.trim().isEmpty()) {
                        request.setAttribute("error", "Programme is required for Academic Leader");
                        doGet(request, response);
                        return;
                    }
                    additionalInfo.put("departmentId", departmentId);
                    additionalInfo.put("programmeId", programmeId);
                }
                case LECTURER -> {
                    /// check department id
                    if (departmentId == null || departmentId.trim().isEmpty()) {
                        request.setAttribute("error", "Department is required for Lecturer");
                        doGet(request, response);
                        return;
                    }
                    additionalInfo.put("departmentId", departmentId);
                }
                case STUDENT -> {
                    ///  check programme id
                    if (programmeId == null || programmeId.trim().isEmpty()) {
                        request.setAttribute("error", "Programme is required for Student");
                        doGet(request, response);
                        return;
                    }
                    additionalInfo.put("programmeId", programmeId);
                }
                default -> {
                    request.setAttribute("error", "Invalid role selected");
                    doGet(request, response);
                    return;
                }
            }

            userServiceFacade.CreateUser(
                    username,
                    fullName,
                    password,
                    role,
                    additionalInfo,
                    ""
            );

            // Success - redirect to login
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=users&message=registration_success");

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid number format");
            doGet(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Registration failed: " + e.getMessage());
            doGet(request, response);
        }
    }
}
