package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.GradingServiceFacade;
import com.htetaung.lms.exception.ScoreOverlapException;
import com.htetaung.lms.models.Grading;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "gradingServlet", urlPatterns = {"/gradings"})
public class GradingServlet extends HttpServlet {

    @EJB
    private GradingServiceFacade gradingServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Grading> gradings = gradingServiceFacade.getAllGradings();
        request.setAttribute("gradings", gradings);

        request.getRequestDispatcher("/WEB-INF/views/admin/grading-fragment.jsp")
                .include(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String gradeSymbol = request.getParameter("gradeSymbol");
            Integer minScore = Integer.parseInt(request.getParameter("minScore"));
            Integer maxScore = Integer.parseInt(request.getParameter("maxScore"));

            String operatedBy = ""; /// TODO

            gradingServiceFacade.createGrading(gradeSymbol, minScore, maxScore, operatedBy);

            request.getSession().setAttribute("messageType", "SUCCESS");
            request.getSession().setAttribute("messageContent", "Grading rule '" + gradeSymbol + "' created successfully");

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Invalid score input");
        } catch (ScoreOverlapException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", e.getMessage());
        } catch (Exception e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Error creating grading: " + e.getMessage());
        }

        response.sendRedirect("/index.jsp?page=grading");
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Long gradingId = Long.parseLong(request.getParameter("gradingId"));
            String gradeSymbol = request.getParameter("gradeSymbol");
            Integer minScore = Integer.parseInt(request.getParameter("minScore"));
            Integer maxScore = Integer.parseInt(request.getParameter("maxScore"));

            String operatedBy = ""; /// TODO

            gradingServiceFacade.updateGrading(gradingId, gradeSymbol, minScore, maxScore, operatedBy);

            request.getSession().setAttribute("messageType", "SUCCESS");
            request.getSession().setAttribute("messageContent", "Grading rule '" + gradeSymbol + "' updated successfully");

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Invalid grading ID or score input");
        } catch (ScoreOverlapException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", e.getMessage());
        } catch (Exception e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Error updating grading: " + e.getMessage());
        }

        response.sendRedirect("/index.jsp?page=grading");
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Long gradingId = Long.parseLong(request.getParameter("gradingId"));
            String operatedBy = ""; /// TODO

            gradingServiceFacade.deleteGrading(gradingId, operatedBy);

            request.getSession().setAttribute("messageType", "SUCCESS");
            request.getSession().setAttribute("messageContent", "Grading rule deleted successfully");

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Invalid grading ID");
        } catch (Exception e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Error deleting grading: " + e.getMessage());
        }

        response.sendRedirect("/index.jsp?page=grading");
    }
}
