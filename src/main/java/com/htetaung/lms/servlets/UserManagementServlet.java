package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.UserServiceFacade;
import com.htetaung.lms.models.dto.UserDTO;
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
        if (pagination_string == null || pagination_string.isEmpty()) {
            pagination_string = "1";
        }
        int pagination = Integer.parseInt(pagination_string);

        List<UserDTO> users = userServiceFacade.getUsers(pagination);
        request.setAttribute("users", users);
        request.setAttribute("currentPage", pagination);

        // Forward to table fragment JSP
        request.getRequestDispatcher("/WEB-INF/views/admin/user-table-fragment.jsp")
                .include(request, response);
    }

}
