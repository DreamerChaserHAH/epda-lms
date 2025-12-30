package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.AssessmentFacade;
import com.htetaung.lms.ejbs.services.AssessmentServiceFacade;
import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.dto.AssessmentDTO;
import com.htetaung.lms.models.enums.AssessmentType;
import com.htetaung.lms.utils.MessageModal;
import com.htetaung.lms.utils.RequestParameterProcessor;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "assessmnetServlet", urlPatterns = {"/api/assessments"})
public class AssessmentServlet extends HttpServlet {
    @EJB
    private AssessmentServiceFacade assessmentServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String includingPage = (String) request.getAttribute("includingPage");
        String assessmentIdString = RequestParameterProcessor.getStringValue("requestedAssessmentId", request, "");

        // GET single assessment by ID
        if (assessmentIdString != null && !assessmentIdString.isEmpty()) {
            Long assessmentId = Long.parseLong(assessmentIdString);

            try {
                AssessmentDTO assessmentDTO = assessmentServiceFacade.GetAssessment(assessmentId);
                if (assessmentDTO == null) {
                    MessageModal.DisplayErrorMessage("Assessment Not Found with ID: " + assessmentId, request);
                    return;
                }

                request.setAttribute("assessment", assessmentDTO);

                String targetPage = (includingPage != null && !includingPage.isEmpty())
                        ? includingPage
                        : "/WEB-INF/views/assessment/assessment-detail-fragment.jsp";

                request.getRequestDispatcher(targetPage).include(request, response);
                return;
            } catch (Exception ex) {
                MessageModal.DisplayErrorMessage("Error Fetching Assessment: " + ex.getMessage(), request);
            }
        }

        // GET list of assessments (with optional class filter)
        String classIdString = RequestParameterProcessor.getStringValue("classId", request, "");
        String pagination_string = RequestParameterProcessor.getStringValue("pagination", request, "1");

        int pagination = Integer.parseInt(pagination_string);

        try {
            List<AssessmentDTO> assessments;

            if (classIdString != null && !classIdString.isEmpty()) {
                Long classId = Long.parseLong(classIdString);
                assessments = assessmentServiceFacade.ListAllAssessmentsInClass(classId);
            } else {
                assessments = assessmentServiceFacade.ListAllAssessments();
            }

            request.setAttribute("assessments", assessments);
            request.setAttribute("currentPage", pagination);

            String targetPage = (includingPage != null && !includingPage.isEmpty())
                    ? includingPage
                    : "/WEB-INF/views/assessment/assessment-list-fragment.jsp";

            request.getRequestDispatcher(targetPage).include(request, response);

        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Error Loading Assessments: " + e.getMessage(), request);
        }
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get form parameters
            String assessmentName = request.getParameter("assessmentName");
            String assessmentDescription = request.getParameter("assessmentDescription");
            String relatedClassIdStr = request.getParameter("relatedClassId");
            String deadlineStr = request.getParameter("deadline");
            String assessmentTypeStr = request.getParameter("assessmentType");
            String lecturerIdStr = request.getParameter("lecturerId");

            // Validate required fields
            if (assessmentName == null || assessmentName.trim().isEmpty() ||
                    assessmentDescription == null || assessmentDescription.trim().isEmpty() ||
                    relatedClassIdStr == null || relatedClassIdStr.trim().isEmpty() ||
                    deadlineStr == null || deadlineStr.trim().isEmpty() ||
                    assessmentTypeStr == null || assessmentTypeStr.trim().isEmpty() ||
                    lecturerIdStr == null || lecturerIdStr.trim().isEmpty()) {

                MessageModal.DisplayErrorMessage("All fields are required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=assessments");
                return;
            }

            // Parse parameters
            Long relatedClassId = Long.parseLong(relatedClassIdStr);
            Long lecturerId = Long.parseLong(lecturerIdStr);

            // Parse deadline
            Date deadline = null;
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                sdf.setLenient(false);
                deadline = sdf.parse(deadlineStr);
            } catch (ParseException e) {
                MessageModal.DisplayErrorMessage("Invalid deadline format", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=assessments");
                return;
            }

            // Parse assessment type
            AssessmentType assessmentType;
            try {
                assessmentType = AssessmentType.valueOf(assessmentTypeStr.toUpperCase());
            } catch (IllegalArgumentException e) {
                MessageModal.DisplayErrorMessage("Invalid assessment type", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=assessments");
                return;
            }

            // Create assessment
            assessmentServiceFacade.CreateAssessment(
                    assessmentName,
                    assessmentDescription,
                    relatedClassId,
                    deadline,
                    assessmentType,
                    lecturerId
            );

            MessageModal.DisplaySuccessMessage("Assessment created successfully", request);

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid number format: " + e.getMessage(), request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Assessment creation failed: " + e.getMessage(), request);
        }

        response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&classId=" + request.getParameter("relatedClassId"));
    }


    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get userId from session
            Long userId = (Long) request.getSession().getAttribute("userId");
            if (userId == null) {
                MessageModal.DisplayErrorMessage("User session expired. Please login again.", request);
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Get form parameters
            String assessmentIdStr = request.getParameter("assessmentId");
            String assessmentName = request.getParameter("assessmentName");
            String assessmentDescription = request.getParameter("assessmentDescription");
            String relatedClassIdStr = request.getParameter("relatedClassId");
            String deadlineStr = request.getParameter("deadline");
            String assessmentTypeStr = request.getParameter("assessmentType");
            String visibilityStr = request.getParameter("visibility");

            // Validate required fields
            if (assessmentIdStr == null || assessmentIdStr.trim().isEmpty() ||
                    assessmentName == null || assessmentName.trim().isEmpty() ||
                    assessmentDescription == null || assessmentDescription.trim().isEmpty() ||
                    relatedClassIdStr == null || relatedClassIdStr.trim().isEmpty() ||
                    deadlineStr == null || deadlineStr.trim().isEmpty() ||
                    assessmentTypeStr == null || assessmentTypeStr.trim().isEmpty() ||
                    visibilityStr == null || visibilityStr.trim().isEmpty()) {

                MessageModal.DisplayErrorMessage("All fields are required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&classId=" + relatedClassIdStr);
                return;
            }

            // Parse parameters
            Long assessmentId = Long.parseLong(assessmentIdStr);
            Long relatedClassId = Long.parseLong(relatedClassIdStr);

            // Parse deadline
            Date deadline = null;
            try {
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                deadline = dateFormat.parse(deadlineStr);
            } catch (ParseException e) {
                MessageModal.DisplayErrorMessage("Invalid deadline format", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&classId=" + relatedClassIdStr);
                return;
            }

            // Parse assessment type
            AssessmentType assessmentType;
            try {
                assessmentType = AssessmentType.valueOf(assessmentTypeStr.toUpperCase());
            } catch (IllegalArgumentException e) {
                MessageModal.DisplayErrorMessage("Invalid assessment type", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&classId=" + relatedClassIdStr);
                return;
            }

            // Parse visibility
            com.htetaung.lms.models.enums.Visibility visibility;
            try {
                visibility = com.htetaung.lms.models.enums.Visibility.valueOf(visibilityStr.toUpperCase());
            } catch (IllegalArgumentException e) {
                MessageModal.DisplayErrorMessage("Invalid visibility option", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&classId=" + relatedClassIdStr);
                return;
            }

            // Create DTO with updated values
            AssessmentDTO dto = new AssessmentDTO();
            dto.setAssessmentId(assessmentId);
            dto.setAssessmentName(assessmentName);
            dto.setAssessmentDescription(assessmentDescription);
            dto.setDeadline(deadline);
            dto.setAssessmentType(assessmentType);
            dto.setVisibility(visibility);

            // Update assessment
            assessmentServiceFacade.UpdateAssessmentDetails(dto, relatedClassId, userId, "");

            MessageModal.DisplaySuccessMessage("Assessment updated successfully", request);

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid number format: " + e.getMessage(), request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Assessment update failed: " + e.getMessage(), request);
        }

        response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&classId=" + request.getParameter("relatedClassId"));
    }


    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String assessmentIdStr = request.getParameter("assessmentId");
            Long assessmentId = Long.parseLong(assessmentIdStr);

            assessmentServiceFacade.DeleteAssessment(assessmentId);
            MessageModal.DisplaySuccessMessage("Assessment deleted successfully", request);
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Delete failed: " + e.getMessage(), request);
        }

        response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&classId=" + request.getParameter("relatedClassId"));
    }
}
