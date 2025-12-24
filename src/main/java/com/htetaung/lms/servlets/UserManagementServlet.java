package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.UserServiceFacade;
import com.htetaung.lms.models.dto.UserDTO;
import com.htetaung.lms.models.enums.UserRole;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "userManagementServlet", urlPatterns = {"/users"})
public class UserManagementServlet extends HttpServlet {

    @EJB
    private UserServiceFacade userServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pagination_string = request.getParameter("pagination");
        String search_query = request.getParameter("searchQuery");
        String filter_field = request.getParameter("filterField");

        if (pagination_string == null || pagination_string.isEmpty()) {
            pagination_string = "1";
        }
        int pagination = Integer.parseInt(pagination_string);

        if (search_query == null || search_query.isEmpty()) {
            List<UserDTO> users = userServiceFacade.getUsers(pagination);
            request.setAttribute("users", users);
            request.setAttribute("currentPage", pagination);
        }else{
            if(filter_field==null || filter_field.isEmpty()){
                filter_field = "fullName";
            }

            if(filter_field == "username") {
                List<UserDTO> users = userServiceFacade.searchUsersByUsername(search_query, pagination);
                request.setAttribute("users", users);
                request.setAttribute("currentPage", pagination);
                request.setAttribute("searchQuery", search_query);
                request.setAttribute("filterField", filter_field);
            }
            if(filter_field == "role"){
                List<UserDTO> users = userServiceFacade.searchUsersByRole(search_query, pagination);
                request.setAttribute("users", users);
                request.setAttribute("currentPage", pagination);
                request.setAttribute("searchQuery", search_query);
                request.setAttribute("filterField", filter_field);
            }
            else{
                List<UserDTO> users = userServiceFacade.searchUsersByFullName(search_query, pagination);
                request.setAttribute("users", users);
                request.setAttribute("currentPage", pagination);
                request.setAttribute("searchQuery", search_query);
                request.setAttribute("filterField", filter_field);
            }
        }
        request.getRequestDispatcher("/WEB-INF/views/admin/user-table-fragment.jsp")
                .include(request, response);
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Long userId = Long.parseLong(request.getParameter("userId"));
            String username = request.getParameter("username");
            String fullName = request.getParameter("fullName");
            String role = request.getParameter("role");

            UserRole userRole = UserRole.valueOf(role.toUpperCase());

            // Update user via service facade
            userServiceFacade.UpdateUser(userId, username, fullName, userRole, "");

            response.setStatus(HttpServletResponse.SC_OK);
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user data");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("userId");
        if (userId != null && !userId.isEmpty()) {
            Long userId_long = Long.parseLong(userId);
            userServiceFacade.DeleteUser(userId_long, "");
            response.setStatus(HttpServletResponse.SC_NO_CONTENT); // 204 No Content
            //request.getRequestDispatcher("/index.jsp?page=users").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Username is required");
        }
    }
}
