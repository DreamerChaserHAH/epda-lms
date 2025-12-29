package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.UserServiceFacade;
import com.htetaung.lms.models.dto.UserDTO;
import com.htetaung.lms.models.enums.Gender;
import com.htetaung.lms.models.enums.UserRole;
import com.htetaung.lms.utils.MessageModal;
import com.htetaung.lms.utils.RequestParameterProcessor;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

@WebServlet(name = "userManagementServlet", urlPatterns = {
        "/api/users"
})
public class UserManagementServlet extends HttpServlet {

    @EJB
    private UserServiceFacade userServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String includingPage = (String) request.getAttribute("includingPage");
        String userIdString = RequestParameterProcessor.getStringValue("requestedUserId", request, "");

        if (userIdString != null && !userIdString.isEmpty()) {
            Long userId = Long.parseLong(userIdString);

            try {
                UserDTO userDTO = userServiceFacade.GetUser(userId);
                if (userDTO == null) {
                    MessageModal.DisplayErrorMessage("User Not Found with ID: " + userId, request);
                    return;
                }

                request.setAttribute("userProfile", userDTO);

                String targetPage = (includingPage != null && !includingPage.isEmpty())
                        ? includingPage
                        : "/WEB-INF/views/common/profile-fragment.jsp";

                request.getRequestDispatcher(targetPage).include(request, response);
                return;
            }catch(Exception ex){
                MessageModal.DisplayErrorMessage("Error Fetching User Profile: " + ex.getMessage(), request);
            }
        }

        // GET /api/users or /api/users/ - List users (pathInfo = null or "/")
        String pagination_string = RequestParameterProcessor.getStringValue("pagination", request, "1");
        String search_query = RequestParameterProcessor.getStringValue("searchQuery", request, "");
        String filter_field = RequestParameterProcessor.getStringValue("filterField", request, "");

        int pagination = Integer.parseInt(pagination_string);

        if (search_query == null || search_query.isEmpty()) {
            List<UserDTO> users = userServiceFacade.getUsers(pagination);
            request.setAttribute("users", users);
            request.setAttribute("currentPage", pagination);
        } else {
            if (filter_field == null || filter_field.isEmpty()) {
                filter_field = "fullName";
            }

            List<UserDTO> users = switch (filter_field) {
                case "username" -> userServiceFacade.searchUsersByUsername(search_query, pagination);
                case "role" -> userServiceFacade.searchUsersByRole(search_query, pagination);
                default -> userServiceFacade.searchUsersByFullName(search_query, pagination);
            };

            request.setAttribute("users", users);
            request.setAttribute("currentPage", pagination);
            request.setAttribute("searchQuery", search_query);
            request.setAttribute("filterField", filter_field);
        }

        String targetPage = (includingPage != null && !includingPage.isEmpty())
                ? includingPage
                : "/WEB-INF/views/admin/user-table-fragment.jsp";

        request.getRequestDispatcher(targetPage).include(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String includingPage = (String) request.getAttribute("includingPage");

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
                MessageModal.DisplayErrorMessage("All fields are required", request);
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
                    MessageModal.DisplayErrorMessage("Invalid role selected", request);
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

            MessageModal.DisplaySuccessMessage("User registered successfully", request);

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Wrong Number Format", request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("User Registration Failed", request);
        }
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=users");
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Parse user ID
            Long userId = Long.parseLong(request.getParameter("userId"));

            // Basic information
            String username = request.getParameter("username");
            String fullName = request.getParameter("fullName");
            String role = request.getParameter("role");
            String genderParam = request.getParameter("gender");

            // Parse date of birth
            String dateOfBirthStr = request.getParameter("dateOfBirth");
            Date dateOfBirth = null;
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                sdf.setLenient(false);
                dateOfBirth = sdf.parse(dateOfBirthStr);
            } catch (ParseException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date format");
                return;
            }

            // Contact and identification information
            String ic = request.getParameter("ic");
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String address = request.getParameter("address");

            // Optional password
            String password = request.getParameter("password");

            // Parse enums
            UserRole userRole = UserRole.valueOf(role.toUpperCase());
            Gender gender = Gender.valueOf(genderParam.toUpperCase());

            // Update user - check if password is provided
            if (password != null && !password.isEmpty()) {
                // Update with password
                userServiceFacade.UpdateUserWithPassword(
                        userId,
                        username,
                        fullName,
                        dateOfBirth,
                        ic,
                        email,
                        phoneNumber,
                        address,
                        password,
                        userRole,
                        gender,
                        ""
                );
            } else {
                // Update without password
                userServiceFacade.UpdateUser(
                        userId,
                        username,
                        fullName,
                        dateOfBirth,
                        ic,
                        email,
                        phoneNumber,
                        address,
                        userRole,
                        gender,
                        ""
                );
            }

            request.getSession().setAttribute("messageType", "SUCCESS");
            request.getSession().setAttribute("messageContent", "User with ID " + userId + " updated successfully");

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Invalid User ID Input");
        } catch (IllegalArgumentException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Invalid Gender Input");
        } catch (Exception e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Error Updating User: " + e.getMessage());
        }
        // Get the referer URL or default to profile page
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=users");
        }
    }


    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("userId");
        if (userId != null && !userId.isEmpty()) {
            Long userId_long = Long.parseLong(userId);
            userServiceFacade.DeleteUser(userId_long, "");

            request.getSession().setAttribute("messageType", "SUCCESS");
            request.getSession().setAttribute("messageContent", "User with " + userId + " deleted successfully");
            //request.getRequestDispatcher("/index.jsp?page=users").forward(request, response);
        } else {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "User ID is required for deletion");
        }
        response.sendRedirect("/index.jsp?page=users");
    }
}
