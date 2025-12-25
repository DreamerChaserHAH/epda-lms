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
import java.util.Optional;

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
        String gradeSymbol = request.getParameter("gradeSymbol");
        Integer minScore = Integer.parseInt(request.getParameter("minScore"));
        Integer maxScore = Integer.parseInt(request.getParameter("maxScore"));

        String operatedBy = ""; /// TODO

        try {
            gradingServiceFacade.createGrading(gradeSymbol, minScore, maxScore, operatedBy);
            response.setStatus(201);
            response.sendRedirect("/index.jsp?page=grading");
        }catch(ScoreOverlapException e){
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long gradingId = Long.parseLong(request.getParameter("gradingId"));
        String gradeSymbol = request.getParameter("gradeSymbol");
        Integer minScore = Integer.parseInt(request.getParameter("minScore"));
        Integer maxScore = Integer.parseInt(request.getParameter("maxScore"));

        String operatedBy = ""; /// TODO

        try {
            gradingServiceFacade.updateGrading(gradingId, gradeSymbol, minScore, maxScore, operatedBy);
            response.setStatus(200);
        }catch(ScoreOverlapException e){
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long gradingId = Long.parseLong(request.getParameter("gradingId"));

        String operatedBy = ""; /// TODO

        gradingServiceFacade.deleteGrading(gradingId, operatedBy);
        response.setStatus(200);
    }
}
