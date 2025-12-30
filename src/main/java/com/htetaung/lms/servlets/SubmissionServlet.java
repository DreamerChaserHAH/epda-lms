package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.QuizQuestionServiceFacade;
import com.htetaung.lms.ejbs.services.SubmissionServiceFacade;
import com.htetaung.lms.models.dto.QuizIndividualQuestionDTO;
import com.htetaung.lms.models.dto.QuizSubmissionDTO;
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

@WebServlet(name = "submissionServlet", urlPatterns = {"/api/submissions", "/api/submission-details"})
public class SubmissionServlet extends HttpServlet {

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    @EJB
    private QuizQuestionServiceFacade quizQuestionServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String includingPage = (String) request.getAttribute("includingPage");
        String assessmentIdString = RequestParameterProcessor.getStringValue("assessmentId", request, "");
        String submissionIdString = RequestParameterProcessor.getStringValue("submissionId", request, "");

        try {
            // Handle individual submission details request
            if (submissionIdString != null && !submissionIdString.isEmpty()) {
                Long submissionId = Long.parseLong(submissionIdString);
                SubmissionDTO submission = submissionServiceFacade.GetSubmission(submissionId);
                request.setAttribute("submission", submission);

                // If it's a quiz submission, also fetch the quiz questions
                if (submission instanceof QuizSubmissionDTO) {
                    QuizSubmissionDTO quizSubmission = (QuizSubmissionDTO) submission;
                    Long assessmentId = quizSubmission.getAssessmentId();
                    if (assessmentId != null) {
                        List<QuizIndividualQuestionDTO> questions = quizQuestionServiceFacade.GetQuestionsForQuiz(assessmentId);
                        request.setAttribute("quizQuestions", questions);
                    }
                }
            }
            // Handle submissions list by assessment
            else if (assessmentIdString != null && !assessmentIdString.isEmpty()) {
                Long assessmentId = Long.parseLong(assessmentIdString);
                List<SubmissionDTO> submissions = submissionServiceFacade.GetSubmissionsByAssessment(assessmentId);
                request.setAttribute("submissions", submissions);
            } else {
                MessageModal.DisplayErrorMessage("Assessment ID or Submission ID is required", request);
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

