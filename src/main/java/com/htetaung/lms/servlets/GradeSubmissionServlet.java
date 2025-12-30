package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.SubmissionServiceFacade;
import com.htetaung.lms.utils.MessageModal;
import com.htetaung.lms.utils.RequestParameterProcessor;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "gradeSubmissionServlet", urlPatterns = {"/api/grade-submission"})
public class GradeSubmissionServlet extends HttpServlet {

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String userEmail = (String) session.getAttribute("userEmail");

        String submissionIdStr = RequestParameterProcessor.getStringValue("submissionId", request, "");
        String scoreStr = RequestParameterProcessor.getStringValue("score", request, "");
        String feedback = RequestParameterProcessor.getStringValue("feedback", request, "");

        try {
            if (submissionIdStr == null || submissionIdStr.isEmpty()) {
                MessageModal.DisplayErrorMessage("Submission ID is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes");
                return;
            }

            if (scoreStr == null || scoreStr.isEmpty()) {
                MessageModal.DisplayErrorMessage("Score is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=view-submission-lecturer&submissionId=" + submissionIdStr);
                return;
            }

            if (feedback == null || feedback.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Feedback is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=view-submission-lecturer&submissionId=" + submissionIdStr);
                return;
            }

            Long submissionId = Long.parseLong(submissionIdStr);
            int score = Integer.parseInt(scoreStr);

            // Validate score range
            if (score < 0 || score > 100) {
                MessageModal.DisplayErrorMessage("Score must be between 0 and 100", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=view-submission-lecturer&submissionId=" + submissionIdStr);
                return;
            }

            // Grade the submission
            submissionServiceFacade.GradeSubmission(
                    submissionId,
                    score,
                    feedback,
                    userEmail
            );

            MessageModal.DisplaySuccessMessage("Submission graded successfully!", request);
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=view-submission-lecturer&submissionId=" + submissionIdStr);

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid submission ID or score format", request);
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes");
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Error grading submission: " + e.getMessage(), request);
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=view-submission-lecturer&submissionId=" + submissionIdStr);
        }
    }
}

