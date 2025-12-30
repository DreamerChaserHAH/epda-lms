package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.GradingFacade;
import com.htetaung.lms.ejbs.services.SubmissionServiceFacade;
import com.htetaung.lms.models.Grading;
import com.htetaung.lms.models.dto.SubmissionDTO;
import com.htetaung.lms.utils.MessageModal;
import com.htetaung.lms.utils.RequestParameterProcessor;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "studentSubmissionsServlet", urlPatterns = {"/api/student-submissions"})
public class StudentSubmissionsServlet extends HttpServlet {

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    @EJB
    private GradingFacade gradingFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String includingPage = (String) request.getAttribute("includingPage");
        String studentIdString = RequestParameterProcessor.getStringValue("studentId", request, "");

        try {
            if (studentIdString != null && !studentIdString.isEmpty()) {
                Long studentId = Long.parseLong(studentIdString);

                // Get all submissions for this student
                List<SubmissionDTO> submissions = submissionServiceFacade.GetSubmissionsByStudent(studentId);
                request.setAttribute("submissions", submissions);

                // Get all grading categories for the grade legend
                List<Grading> gradings = gradingFacade.findAllGradings();
                request.setAttribute("gradings", gradings);

            } else {
                MessageModal.DisplayErrorMessage("Student ID is required", request);
            }

            if (includingPage != null && !includingPage.isEmpty()) {
                request.getRequestDispatcher(includingPage).include(request, response);
            }

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid ID format", request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Error loading submissions: " + e.getMessage(), request);
        }
    }
}

