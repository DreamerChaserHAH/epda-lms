package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.LecturerFacade;
import com.htetaung.lms.ejbs.services.ModuleServiceFacade;
import com.htetaung.lms.exception.ModuleException;
import com.htetaung.lms.models.dto.LecturerDTO;
import com.htetaung.lms.models.dto.ModuleDTO;
import com.htetaung.lms.models.enums.UserRole;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "moduleServlet", urlPatterns = {"/api/modules"})
public class ModuleServlet extends HttpServlet {
    @EJB
    private ModuleServiceFacade moduleServiceFacade;

    @EJB
    private LecturerFacade lecturerFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String includingPage = (String) request.getAttribute("includingPage");

        HttpSession session = request.getSession();
        Long userId = (Long)session.getAttribute("userId");
        UserRole userRole = (UserRole) session.getAttribute("role");

        if (userId == null || userRole == null) {
            // Handle unauthenticated access
            return;
        }

        if (userRole == UserRole.ACADEMIC_LEADER){
            try {
                List<ModuleDTO> modules = moduleServiceFacade.ListAllModulesUnderAcademicLeader(userId, 1);
                List<LecturerDTO> lecturersUnderAcademicLeader = lecturerFacade.listAllLecturersUnderAcademicLeader(userId);
                request.setAttribute("modules", modules);
                request.setAttribute("lecturers", lecturersUnderAcademicLeader);
            } catch (ModuleException e) {
                /// DO NOTHING
            }

            String targetPage = (includingPage != null && !includingPage.isEmpty())
                    ? includingPage
                    : "/WEB-INF/views/academic-leader/modules-table-fragment.jsp";

            request.getRequestDispatcher(targetPage).include(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        Long userId = (Long)session.getAttribute("userId");
        UserRole userRole = (UserRole) session.getAttribute("role");
        String username = (String) session.getAttribute("username");

        if (userId == null || userRole == null || username == null) {
            // Handle unauthenticated access
            return;
        }

        if(userRole != UserRole.ACADEMIC_LEADER){
            // Only Academic Leaders can create modules
            return;
        }

        String moduleName = (String) request.getParameter("moduleName");
        String lecturerId_String = (String) request.getParameter("lecturerId");

        if (moduleName != null && !moduleName.trim().isEmpty() && lecturerId_String != null && !lecturerId_String.trim().isEmpty()) {
            try {
                Long lecturerId = Long.parseLong(lecturerId_String);
                moduleServiceFacade.CreateModule(
                        moduleName,
                        userId,
                        lecturerId,
                        username
                );

                request.getSession().setAttribute("messageType", "SUCCESS");
                request.getSession().setAttribute("messageContent", "Module " + moduleName + " created successfully");

            }catch(NumberFormatException e){
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Some format is incorrect!");
            } catch (ModuleException e) {
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Module Exception: " + e.getMessage());
            }
        }else{
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Some fields are missing!");
        }
        response.sendRedirect("/index.jsp?page=modules");
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        Long userId = (Long) session.getAttribute("userId");
        UserRole userRole = (UserRole) session.getAttribute("role");
        String username = (String) session.getAttribute("username");

        if (userId == null || userRole == null || username == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        if (userRole != UserRole.ACADEMIC_LEADER) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String moduleId_String = request.getParameter("moduleId");
        String moduleName = request.getParameter("moduleName");
        String lecturerId_String = request.getParameter("lecturerId");

        if (moduleId_String != null && !moduleId_String.trim().isEmpty() &&
                moduleName != null && !moduleName.trim().isEmpty()) {
            try {
                Long moduleId = Long.parseLong(moduleId_String);
                Long lecturerId = (lecturerId_String != null && !lecturerId_String.trim().isEmpty())
                        ? Long.parseLong(lecturerId_String)
                        : null;

                moduleServiceFacade.UpdateModule(moduleId, moduleName, lecturerId, username);

                request.getSession().setAttribute("messageType", "SUCCESS");
                request.getSession().setAttribute("messageContent", "Module updated successfully");

            } catch (NumberFormatException e) {
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Invalid format!");
            } catch (ModuleException e) {
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Module Exception: " + e.getMessage());
            }
        } else {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Required fields are missing!");
        }

        response.sendRedirect("/index.jsp?page=modules");
    }


    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        Long userId = (Long) session.getAttribute("userId");
        UserRole userRole = (UserRole) session.getAttribute("role");
        String username = (String) session.getAttribute("username");

        if (userId == null || userRole == null || username == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        if (userRole != UserRole.ACADEMIC_LEADER) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String moduleId_String = request.getParameter("moduleId");

        if (moduleId_String != null && !moduleId_String.trim().isEmpty()) {
            try {
                Long moduleId = Long.parseLong(moduleId_String);
                moduleServiceFacade.DeleteModule(moduleId, username);

                request.getSession().setAttribute("messageType", "SUCCESS");
                request.getSession().setAttribute("messageContent", "Module deleted successfully");

            } catch (NumberFormatException e) {
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Invalid module ID!");
            } catch (ModuleException e) {
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Module Exception: " + e.getMessage());
            }
        } else {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Module ID is required!");
        }

        response.sendRedirect("/index.jsp?page=modules");
    }

}
