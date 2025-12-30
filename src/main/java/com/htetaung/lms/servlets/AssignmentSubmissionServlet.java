package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.SubmissionServiceFacade;
import com.htetaung.lms.exception.SubmissionException;
import com.htetaung.lms.models.dto.AssignmentSubmissionDTO;
import com.htetaung.lms.utils.MessageModal;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;

@WebServlet(name = "assignmentSubmissionServlet", urlPatterns = {"/api/submit-assignment"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class AssignmentSubmissionServlet extends HttpServlet {

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get session info
            Long userId = (Long) request.getSession().getAttribute("userId");
            String username = (String) request.getSession().getAttribute("username");

            if (userId == null || username == null) {
                MessageModal.DisplayErrorMessage("User session expired. Please login again.", request);
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Get form parameters
            String assessmentIdStr = request.getParameter("assessmentId");
            String studentIdStr = request.getParameter("studentId");
            String comments = request.getParameter("comments");
            String academicIntegrity = request.getParameter("academicIntegrity");

            // Validate required fields
            if (assessmentIdStr == null || assessmentIdStr.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Assessment ID is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
                return;
            }

            if (studentIdStr == null || studentIdStr.trim().isEmpty()) {
                MessageModal.DisplayErrorMessage("Student ID is required", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
                return;
            }

            if (academicIntegrity == null) {
                MessageModal.DisplayErrorMessage("You must certify academic integrity", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=submit-assessment&assessmentId=" + assessmentIdStr);
                return;
            }

            // Get all uploaded file parts
            java.util.Collection<Part> fileParts = request.getParts();
            java.util.List<Part> submissionFiles = new java.util.ArrayList<>();

            for (Part part : fileParts) {
                if (part.getName().equals("submissionFiles") && part.getSize() > 0) {
                    submissionFiles.add(part);
                }
            }

            if (submissionFiles.isEmpty()) {
                MessageModal.DisplayErrorMessage("At least one file is required for submission", request);
                response.sendRedirect(request.getContextPath() + "/index.jsp?page=submit-assessment&assessmentId=" + assessmentIdStr);
                return;
            }

            // Validate file sizes (10MB each)
            long maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
            for (Part filePart : submissionFiles) {
                if (filePart.getSize() > maxFileSize) {
                    MessageModal.DisplayErrorMessage("File size exceeds 10MB limit: " + getFileName(filePart), request);
                    response.sendRedirect(request.getContextPath() + "/index.jsp?page=submit-assessment&assessmentId=" + assessmentIdStr);
                    return;
                }
            }

            // Parse parameters
            Long studentId = Long.parseLong(studentIdStr);
            Long assessmentId = Long.parseLong(assessmentIdStr);

            // Submit assignment with multiple files
            AssignmentSubmissionDTO submission = submissionServiceFacade.SubmitAssignment(
                    studentId,
                    assessmentId,
                    submissionFiles,
                    comments,
                    username
            );

            if (submission != null && submission.getSubmissionId() != null) {
                MessageModal.DisplaySuccessMessage(
                    "Assignment submitted successfully! " + submissionFiles.size() + " file(s) uploaded. Submission ID: " + submission.getSubmissionId(),
                    request
                );
            } else {
                MessageModal.DisplayWarningMessage("Assignment may not have been saved properly. Please check your submissions.", request);
            }

        } catch (NumberFormatException e) {
            MessageModal.DisplayErrorMessage("Invalid number format: " + e.getMessage(), request);
            e.printStackTrace();
        } catch (SubmissionException e) {
            MessageModal.DisplayErrorMessage("Submission failed: " + e.getMessage(), request);
            e.printStackTrace();
        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Unexpected error: " + e.getMessage(), request);
            e.printStackTrace();
        }

        // Redirect back to assignments page
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
    }

    /**
     * Extract filename from Part header
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String content : contentDisposition.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "unknown";
    }
}

