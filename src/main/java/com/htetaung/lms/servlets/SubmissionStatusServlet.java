package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.AssessmentServiceFacade;
import com.htetaung.lms.ejbs.services.ClassServiceFacade;
import com.htetaung.lms.ejbs.services.SubmissionServiceFacade;
import com.htetaung.lms.models.dto.AssessmentDTO;
import com.htetaung.lms.models.dto.ClassDTO;
import com.htetaung.lms.models.dto.StudentDTO;
import com.htetaung.lms.utils.MessageModal;
import com.htetaung.lms.utils.RequestParameterProcessor;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "submissionStatusServlet", urlPatterns = {"/api/submission-statuses"})
public class SubmissionStatusServlet extends HttpServlet {

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    @EJB
    private ClassServiceFacade classServiceFacade;

    @EJB
    private AssessmentServiceFacade assessmentServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String includingPage = (String) request.getAttribute("includingPage");
        String classIdString = RequestParameterProcessor.getStringValue("classId", request, "");

        try {
            if (classIdString != null && !classIdString.isEmpty()) {
                Long classId = Long.parseLong(classIdString);

                // Get class details to get students
                ClassDTO classDetails = classServiceFacade.GetClass(classId);

                // Get assessments for the class
                List<AssessmentDTO> assessments = assessmentServiceFacade.ListAllAssessmentsInClass(classId);

                // Create a map of submission statuses: "studentId_assessmentId" -> hasSubmitted
                Map<String, Boolean> submissionStatuses = new HashMap<>();

                if (classDetails.students != null && assessments != null) {
                    for (StudentDTO student : classDetails.students) {
                        for (AssessmentDTO assessment : assessments) {
                            String key = student.userId + "_" + assessment.getAssessmentId();
                            boolean hasSubmitted = submissionServiceFacade.HasSubmitted(student.userId, assessment.getAssessmentId());
                            submissionStatuses.put(key, hasSubmitted);
                        }
                    }
                }

                request.setAttribute("submissionStatuses", submissionStatuses);

            } else {
                MessageModal.DisplayErrorMessage("Class ID is required", request);
            }

            if (includingPage != null && !includingPage.isEmpty()) {
                request.getRequestDispatcher(includingPage).include(request, response);
            }

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid ID format", request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Error loading submission statuses: " + e.getMessage(), request);
        }
    }
}

