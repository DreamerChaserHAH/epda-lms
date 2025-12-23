package com.htetaung.lms.servlets;

import com.htetaung.lms.ejb.*;
import com.htetaung.lms.entity.User.Role;
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
import java.util.Optional;

@WebServlet(name = "registrationServlet", urlPatterns = {"/register"})
public class UserRegistrationServlet extends HttpServlet {

    @EJB
    private UserFacade userFacade;

    @EJB
    private StudentFacade studentFacade;

    @EJB
    private AcademicLeaderFacade academicLeaderFacade;

    @EJB
    private LecturerFacade lecturerFacade;

    @EJB
    private AdminFacade adminFacade;

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
            String studentId = request.getParameter("studentId");
            String staffNumber = request.getParameter("staffNumber");
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

            Role role = Role.valueOf(roleParam);
            String passwordHash = hashPassword(password);

            // Register user based on role
            switch (role) {
                case STUDENT:
                    if (programmeId == null || programmeId.trim().isEmpty()) {
                        request.setAttribute("error", "Programme is required for students");
                        doGet(request, response);
                        return;
                    }

                    studentFacade.registerStudent(
                            username,
                            fullName,
                            passwordHash,
                            null
                    );
                    break;

                case LECTURER:
                    if (departmentId == null || departmentId.trim().isEmpty()) {
                        request.setAttribute("error", "Department is required for lecturers");
                        doGet(request, response);
                        return;
                    }
                    lecturerFacade.registerLecturer(
                            username,
                            fullName,
                            passwordHash,
                            null
                    );
                    break;

                case ACADEMIC_LEADER:
                    if (departmentId == null || programmeId == null ||
                            departmentId.trim().isEmpty() || programmeId.trim().isEmpty()) {
                        request.setAttribute("error", "Department and Programme are required");
                        doGet(request, response);
                        return;
                    }
                    academicLeaderFacade.registerAcademicLeader(
                            username,
                            fullName,
                            passwordHash,
                            null
                    );
                    break;

                case ADMIN:
                    adminFacade.registerAdmin(
                            username,
                            fullName,
                            passwordHash,
                            null,
                            0L
                    );
                    break;

                default:
                    request.setAttribute("error", "Invalid role");
                    doGet(request, response);
                    return;
            }

            // Success - redirect to login
            response.sendRedirect(request.getContextPath() + "/login?registered=true");

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid number format");
            doGet(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Registration failed: " + e.getMessage());
            doGet(request, response);
        }
    }

    // Security utility (stays in facade)
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Password hashing failed", e);
        }
    }
}
