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

@WebServlet(name = "profileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {
    @EJB
    private UserServiceFacade userServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("userId");
        UserDTO userDTO = userServiceFacade.GetUser(Long.valueOf(userId));
        request.setAttribute("userProfile", userDTO);
        request.getRequestDispatcher("/WEB-INF/views/common/profile-fragment.jsp")
                .include(request, response);
    }
}
