package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.StaffServiceFacade;
import com.htetaung.lms.models.dto.AcademicLeaderDTO;
import com.htetaung.lms.models.dto.LecturerDTO;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "lecturerAssignServlet", urlPatterns = {"/lecturers"})
public class LecturerAssignServlet extends HttpServlet {
    @EJB
    private StaffServiceFacade staffServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<LecturerDTO> lecturerDTOList = staffServiceFacade.getAllLecturers();
        List<AcademicLeaderDTO> academicLeaderDTOList = staffServiceFacade.getAllAcademicLeaders();

        request.setAttribute("lecturers", lecturerDTOList);
        request.setAttribute("academicLeaders", academicLeaderDTOList);

        request.getRequestDispatcher("/WEB-INF/views/admin/lecturer-assignment-fragment.jsp")
                .include(request, response);
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Long lecturerId = Long.parseLong(request.getParameter("lecturerId"));;

        Long academicLeaderId = 0L;
        try {
            academicLeaderId = Long.parseLong(request.getParameter("academicLeaderId"));
        }catch(NumberFormatException e) {
            //DO NOTHING
        }
        String operatedBy = ""; /// TODO: get from session

        staffServiceFacade.updateLecturerAcademicLeader(lecturerId, academicLeaderId, operatedBy);

        request.getSession().setAttribute("messageType", "SUCCESS");
        request.getSession().setAttribute("messageContent", "Lecturer with User ID " + lecturerId + " updated successfully");

        response.sendRedirect("/index.jsp?page=lecturer-assignment");
    }

}
