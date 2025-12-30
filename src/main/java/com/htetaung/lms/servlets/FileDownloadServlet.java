package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.FileSubmittedFacade;
import com.htetaung.lms.models.assessments.FileSubmitted;
import com.htetaung.lms.models.enums.UserRole;
import com.htetaung.lms.utils.MessageModal;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

@WebServlet(name = "fileDownloadServlet", urlPatterns = {"/api/download-file"})
public class FileDownloadServlet extends HttpServlet {

    @EJB
    private FileSubmittedFacade fileSubmittedFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get session info
            Long userId = (Long) request.getSession().getAttribute("userId");
            UserRole userRole = (UserRole) request.getSession().getAttribute("role");

            if (userId == null || userRole == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Please login to download files");
                return;
            }

            // Only lecturers and admins can download files
            if (!userRole.equals(UserRole.LECTURER) && !userRole.equals(UserRole.ADMIN) && !userRole.equals(UserRole.ACADEMIC_LEADER)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't have permission to download files");
                return;
            }

            // Get file ID parameter
            String fileIdStr = request.getParameter("fileId");
            if (fileIdStr == null || fileIdStr.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File ID is required");
                return;
            }

            Long fileId = Long.parseLong(fileIdStr);

            // Get file metadata from database
            FileSubmitted fileSubmitted = fileSubmittedFacade.find(fileId);
            if (fileSubmitted == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
                return;
            }

            // Get file from disk
            File file = new File(fileSubmitted.getFilePath());
            if (!file.exists() || !file.canRead()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on server");
                return;
            }

            // Set response headers
            String mimeType = getServletContext().getMimeType(fileSubmitted.getFileName());
            if (mimeType == null) {
                mimeType = "application/octet-stream";
            }

            response.setContentType(mimeType);
            response.setContentLength((int) file.length());
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileSubmitted.getFileName() + "\"");

            // Stream file to response
            try (FileInputStream fileInputStream = new FileInputStream(file);
                 OutputStream outputStream = response.getOutputStream()) {

                byte[] buffer = new byte[4096];
                int bytesRead;

                while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }

                outputStream.flush();
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file ID format");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error downloading file: " + e.getMessage());
        }
    }
}

