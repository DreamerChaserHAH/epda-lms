package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.facades.StudentFacade;
import com.htetaung.lms.ejbs.services.ClassServiceFacade;
import com.htetaung.lms.ejbs.services.ModuleServiceFacade;
import com.htetaung.lms.ejbs.services.SubmissionServiceFacade;
import com.htetaung.lms.ejbs.services.UserServiceFacade;
import com.htetaung.lms.exception.ClassException;
import com.htetaung.lms.exception.ModuleException;
import com.htetaung.lms.models.dto.ClassDTO;
import com.htetaung.lms.models.dto.ModuleDTO;
import com.htetaung.lms.models.dto.StudentDTO;
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
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet(name = "classServlet", urlPatterns = {"/classes"})
public class ClassServlet extends HttpServlet {

    @EJB
    private ClassServiceFacade classServiceFacade;

    @EJB
    private ModuleServiceFacade moduleServiceFacade;

    @EJB
    private UserServiceFacade userServiceFacade;

    @EJB
    private StudentFacade studentFacade;

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check for classId parameter first (for individual class details)
        String classId_String = RequestParameterProcessor.getStringValue("classId", request, null);
        String includingPage = (String) request.getAttribute("includingPage");

        if (classId_String != null && !classId_String.isEmpty()) {
            try {
                Long classId = Long.parseLong(classId_String);
                ClassDTO classDetails = classServiceFacade.GetClass(classId);
                request.setAttribute("classDetails", classDetails);

                List<StudentDTO> allStudents = studentFacade.getAllStudents();
                List<StudentDTO> availableStudents = allStudents;

                if (classDetails.students != null && !classDetails.students.isEmpty()) {
                    Set<Long> enrolledIds = classDetails.students.stream()
                            .map(s -> s.userId)
                            .collect(Collectors.toSet());

                    availableStudents = allStudents.stream()
                            .filter(s -> !enrolledIds.contains(s.userId))
                            .toList();
                }

                request.setAttribute("availableStudents", availableStudents);

                request.getSession().setAttribute("messageType", "SUCCESS");
                request.getSession().setAttribute("messageContent", "Class details loaded successfully!");

            } catch (NumberFormatException e) {
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Invalid Class ID format");
            } catch (ClassException | ModuleException e) {
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Exception: " + e.getMessage());
            }
        } else {
            // Check for lecturerId parameter (NEW - for listing classes under lecturer)
            String lecturerId_String = RequestParameterProcessor.getStringValue("lecturerId", request, null);

            // Check for studentId parameter (NEW - for listing classes under student)
            String studentId_String = RequestParameterProcessor.getStringValue("studentId", request, null);

            if (lecturerId_String != null && !lecturerId_String.isEmpty()) {
                try {
                    Long lecturerId = Long.parseLong(lecturerId_String);
                    List<ClassDTO> classes = classServiceFacade.ListAllClassesUnderLecturer(lecturerId);
                    request.setAttribute("classes", classes);

                    request.getSession().setAttribute("messageType", "SUCCESS");
                    request.getSession().setAttribute("messageContent", "Classes under lecturer loaded successfully!");

                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("messageType", "ERROR");
                    request.getSession().setAttribute("messageContent", "Invalid Lecturer ID format");
                } catch (ClassException e) {
                    request.getSession().setAttribute("messageType", "ERROR");
                    request.getSession().setAttribute("messageContent", "Exception: " + e.getMessage());
                }
            } else if (studentId_String != null && !studentId_String.isEmpty()) {
                try {
                    Long studentId = Long.parseLong(studentId_String);
                    List<ClassDTO> classes = classServiceFacade.ListAllClassesUnderStudent(studentId);
                    request.setAttribute("classes", classes);

                    request.getSession().setAttribute("messageType", "SUCCESS");
                    request.getSession().setAttribute("messageContent", "Classes loaded successfully!");

                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("messageType", "ERROR");
                    request.getSession().setAttribute("messageContent", "Invalid Student ID format");
                } catch (ClassException e) {
                    request.getSession().setAttribute("messageType", "ERROR");
                    request.getSession().setAttribute("messageContent", "Exception: " + e.getMessage());
                }
            } else {
                // Check for leaderId parameter (for module/class listing)
                String academicLeaderId_String = RequestParameterProcessor.getStringValue("leaderId", request, null);
                if (academicLeaderId_String != null && !academicLeaderId_String.isEmpty()) {
                    try {
                        Long academicLeaderId = Long.parseLong(academicLeaderId_String);
                        List<ModuleDTO> modules = moduleServiceFacade.ListAllModulesUnderAcademicLeader(academicLeaderId, 1);
                        request.setAttribute("modules", modules);
                        int numberOfModules = modules.size();
                        HashMap<ModuleDTO, List<ClassDTO>> moduleClassesMap = new HashMap<>();
                        for (int i = 0; i < numberOfModules; i++) {
                            Long moduleId = modules.get(i).moduleId;
                            List<ClassDTO> classDTOs = classServiceFacade.ListAllClassesUnderModule(moduleId);
                            moduleClassesMap.put(modules.get(i), classDTOs);
                        }
                        request.setAttribute("moduleClassesMap", moduleClassesMap);

                        request.getSession().setAttribute("messageType", "SUCCESS");
                        request.getSession().setAttribute("messageContent", "Modules of the Academic Leader loaded successfully!");

                    } catch (NumberFormatException e) {
                        request.getSession().setAttribute("messageType", "ERROR");
                        request.getSession().setAttribute("messageContent", "Invalid Academic Leader ID format");
                    } catch (ModuleException | ClassException e) {
                        request.getSession().setAttribute("messageType", "ERROR");
                        request.getSession().setAttribute("messageContent", "Exception: " + e.getMessage());
                    }
                } else {
                    request.getSession().setAttribute("messageType", "ERROR");
                    request.getSession().setAttribute("messageContent", "Class ID, Lecturer ID, or Academic Leader ID is required");
                }
            }
        }

        if(includingPage != null){
            if (!includingPage.isEmpty()) {
                request.getRequestDispatcher(includingPage).include(request, response);
            }else{
                request.getRequestDispatcher("/WEB-INF/views/admin/classes-fragment.jsp").include(request, response);
            }
        }else {
            request.getRequestDispatcher("/WEB-INF/views/admin/classes-fragment.jsp").include(request, response);
        }
    }



    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String moduleId_String = RequestParameterProcessor.getStringValue("moduleId", request, null);
        String className = RequestParameterProcessor.getStringValue("className", request, null);
        String operatedBy = (String) request.getSession().getAttribute("username");
        String leaderId_String = RequestParameterProcessor.getStringValue("leaderId", request, "");

        if (moduleId_String == null || moduleId_String.isEmpty()) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Module ID is required");
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&leaderId=" + leaderId_String);
            return;
        }

        if (className == null || className.trim().isEmpty()) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Class name is required");
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&leaderId=" + leaderId_String);
            return;
        }

        try {
            Long moduleId = Long.parseLong(moduleId_String);
            classServiceFacade.CreateClass(moduleId, className.trim(), operatedBy);

            request.getSession().setAttribute("messageType", "SUCCESS");
            request.getSession().setAttribute("messageContent", "Class created successfully!");

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Invalid Module ID format");
        } catch (ClassException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Exception: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&leaderId=" + leaderId_String);
    }


    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String classId_String = request.getParameter("classId");
        String className = request.getParameter("className");
        String operatedBy = (String) request.getSession().getAttribute("username");

        // Get student IDs to add and remove
        String[] studentsToAdd = request.getParameterValues("studentsToAdd[]");
        String[] studentsToRemove = request.getParameterValues("studentsToRemove[]");

        if (classId_String == null || classId_String.isEmpty()) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Class ID is required");
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&classId=" + classId_String);
            return;
        }

        try {
            Long classId = Long.parseLong(classId_String);

            // Convert student IDs to StudentDTO lists
            List<StudentDTO> newStudents = studentsToAdd != null
                    ? studentFacade.getStudentsByIds(
                    java.util.Arrays.stream(studentsToAdd)
                            .map(Long::parseLong)
                            .toList()
            )
                    : List.of();

            List<StudentDTO> studentsToRemoveList = studentsToRemove != null
                    ? studentFacade.getStudentsByIds(
                    java.util.Arrays.stream(studentsToRemove)
                            .map(Long::parseLong)
                            .toList()
            )
                    : List.of();

            classServiceFacade.UpdateClass(classId, className, newStudents, studentsToRemoveList, operatedBy);

            request.getSession().setAttribute("messageType", "SUCCESS");
            request.getSession().setAttribute("messageContent", "Class updated successfully!");

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Invalid ID format");
        } catch (ClassException e) {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Error updating class: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes&classId=" + classId_String);
    }


    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String classId = request.getParameter("classId");
        String operatedBy = (String) request.getSession().getAttribute("username");

        if (classId != null && !classId.isEmpty()) {
            try {
                Long classId_long = Long.parseLong(classId);
                classServiceFacade.DeleteClass(classId_long, operatedBy);

                request.getSession().setAttribute("messageType", "SUCCESS");
                request.getSession().setAttribute("messageContent", "Class with ID " + classId + " deleted successfully");
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Invalid Class ID format");
            } catch (ClassException e) {
                request.getSession().setAttribute("messageType", "ERROR");
                request.getSession().setAttribute("messageContent", "Error deleting class: " + e.getMessage());
            }
        } else {
            request.getSession().setAttribute("messageType", "ERROR");
            request.getSession().setAttribute("messageContent", "Class ID is required for deletion");
        }

        // Get the referer URL or default to classes page
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes");
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp?page=classes");
        }
    }

}
