package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.*;
import com.htetaung.lms.ejbs.services.UserServiceFacade;
import com.htetaung.lms.models.enums.Gender;
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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
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
            String genderParam = request.getParameter("gender");

            // New fields
            String dateOfBirthStr = request.getParameter("dateOfBirth");
            String ic = request.getParameter("ic");
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String address = request.getParameter("address");

            String programmeId = request.getParameter("programmeId");
            String departmentId = request.getParameter("departmentId");

            // Validate input - update to include new required fields
            if (username == null || username.trim().isEmpty() ||
                    fullName == null || fullName.trim().isEmpty() ||
                    password == null || password.trim().isEmpty() ||
                    dateOfBirthStr == null || dateOfBirthStr.trim().isEmpty() ||
                    ic == null || ic.trim().isEmpty() ||
                    email == null || email.trim().isEmpty() ||
                    phoneNumber == null || phoneNumber.trim().isEmpty() ||
                    address == null || address.trim().isEmpty() ||
                    roleParam == null || roleParam.trim().isEmpty() ||
                    genderParam == null || genderParam.trim().isEmpty()
            ) {
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

            Date dateOfBirth = null;
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                sdf.setLenient(false);
                dateOfBirth = sdf.parse(dateOfBirthStr);
            } catch (ParseException e) {
                request.setAttribute("error", "Invalid date format");
                doGet(request, response);
                return;
            }

            UserRole role = UserRole.valueOf(roleParam);
            Gender gender = Gender.valueOf(genderParam);
            HashMap<String, String> additionalInfo = new HashMap<String, String>();

            // Existing role-based validation logic remains the same...
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
                    if (departmentId == null || departmentId.trim().isEmpty()) {
                        request.setAttribute("error", "Department is required for Lecturer");
                        doGet(request, response);
                        return;
                    }
                    additionalInfo.put("departmentId", departmentId);
                }
                case STUDENT -> {
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

            // Update CreateUser call with all 11 parameters
            userServiceFacade.CreateUser(
                    username,
                    fullName,
                    dateOfBirth,
                    ic,
                    email,
                    phoneNumber,
                    address,
                    password,
                    role,
                    gender,
                    additionalInfo,
                    ""
            );

            request.getSession().setAttribute("messageType", "SUCCESS");
            request.getSession().setAttribute("messageContent", "User registered successfully");

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Wrong Number Format: " + e.getMessage());
        } catch (Exception e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "User Registration Failed: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=users");
    }

}
