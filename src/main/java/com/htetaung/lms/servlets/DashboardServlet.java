package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.*;
import com.htetaung.lms.models.dto.*;
import com.htetaung.lms.models.Grading;
import com.htetaung.lms.models.enums.UserRole;
import com.htetaung.lms.utils.MessageModal;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet(name = "dashboardServlet", urlPatterns = {"/api/dashboard"})
public class DashboardServlet extends HttpServlet {

    @EJB
    private UserServiceFacade userServiceFacade;

    @EJB
    private ClassServiceFacade classServiceFacade;

    @EJB
    private AssessmentServiceFacade assessmentServiceFacade;

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

    @EJB
    private ModuleServiceFacade moduleServiceFacade;

    @EJB
    private GradingServiceFacade gradingServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Long userId = (Long) session.getAttribute("userId");
        Object roleObj = session.getAttribute("role");

        if (roleObj == null) {
            MessageModal.DisplayErrorMessage("Role not found in session", request);
            return;
        }

        try {
            UserRole role;

            // Handle both String and UserRole types
            if (roleObj instanceof UserRole) {
                role = (UserRole) roleObj;
            } else if (roleObj instanceof String) {
                role = UserRole.valueOf((String) roleObj);
            } else {
                MessageModal.DisplayErrorMessage("Invalid role type in session", request);
                return;
            }

            switch (role) {
                case ADMIN:
                    loadAdminDashboard(request);
                    break;
                case ACADEMIC_LEADER:
                    loadAcademicLeaderDashboard(request, userId);
                    break;
                case LECTURER:
                    loadLecturerDashboard(request, userId);
                    break;
                case STUDENT:
                    loadStudentDashboard(request, userId);
                    break;
                default:
                    MessageModal.DisplayErrorMessage("Unknown role: " + role, request);
            }

        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Error loading dashboard: " + e.getMessage(), request);
        }
    }

    private void loadAdminDashboard(HttpServletRequest request) {
        try {
            // Get all users count by role
            List<UserDTO> allUsers = userServiceFacade.getUsers(1);
            long totalUsers = allUsers.size();
            long totalStudents = allUsers.stream().filter(u -> u.role == UserRole.STUDENT).count();
            long totalLecturers = allUsers.stream().filter(u -> u.role == UserRole.LECTURER).count();
            long totalAcademicLeaders = allUsers.stream().filter(u -> u.role == UserRole.ACADEMIC_LEADER).count();

            // Get all modules by iterating through all academic leaders
            List<ModuleDTO> allModules = new ArrayList<>();
            Set<Long> moduleIds = new HashSet<>(); // To avoid duplicates

            for (UserDTO user : allUsers) {
                if (user.role == UserRole.ACADEMIC_LEADER) {
                    try {
                        List<ModuleDTO> leaderModules = moduleServiceFacade.ListAllModulesUnderAcademicLeader(user.userId, 1);
                        if (leaderModules != null) {
                            for (ModuleDTO module : leaderModules) {
                                if (!moduleIds.contains(module.moduleId)) {
                                    moduleIds.add(module.moduleId);
                                    allModules.add(module);
                                }
                            }
                        }
                    } catch (Exception e) {
                        // Continue if error with one academic leader
                    }
                }
            }

            int totalModules = allModules.size();

            // Get all classes from all modules
            List<ClassDTO> allClasses = new ArrayList<>();
            for (ModuleDTO module : allModules) {
                try {
                    List<ClassDTO> moduleClasses = classServiceFacade.ListAllClassesUnderModule(module.moduleId);
                    if (moduleClasses != null) {
                        allClasses.addAll(moduleClasses);
                    }
                } catch (Exception e) {
                    // Continue if error with one module
                }
            }
            int totalClasses = allClasses.size();

            // Get all assessments
            int totalAssessments = 0;
            try {
                List<AssessmentDTO> allAssessments = assessmentServiceFacade.ListAllAssessments();
                totalAssessments = allAssessments != null ? allAssessments.size() : 0;
            } catch (Exception e) {
                totalAssessments = 0;
            }

            // Get recent classes (first 5)
            List<ClassDTO> recentClasses = allClasses.stream()
                    .sorted((c1, c2) -> Long.compare(c2.classId, c1.classId))
                    .limit(5)
                    .collect(Collectors.toList());

            // Get grading schemes count
            int totalGradingSchemes = 0;
            try {
                List<Grading> gradingSchemes = gradingServiceFacade.getAllGradings();
                totalGradingSchemes = gradingSchemes != null ? gradingSchemes.size() : 0;
            } catch (Exception e) {
                totalGradingSchemes = 0;
            }

            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("totalLecturers", totalLecturers);
            request.setAttribute("totalAcademicLeaders", totalAcademicLeaders);
            request.setAttribute("totalClasses", totalClasses);
            request.setAttribute("totalModules", totalModules);
            request.setAttribute("totalAssessments", totalAssessments);
            request.setAttribute("totalGradingSchemes", totalGradingSchemes);
            request.setAttribute("recentClasses", recentClasses);

        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Error loading admin dashboard: " + e.getMessage(), request);
        }
    }

    private void loadAcademicLeaderDashboard(HttpServletRequest request, Long academicLeaderId) {
        try {
            // Get modules managed by academic leader
            List<ModuleDTO> managedModules = moduleServiceFacade.ListAllModulesUnderAcademicLeader(academicLeaderId, 1);
            int totalModules = managedModules != null ? managedModules.size() : 0;
            if (managedModules == null) managedModules = new ArrayList<>();

            // Get classes under these modules
            List<ClassDTO> allClasses = new ArrayList<>();
            for (ModuleDTO module : managedModules) {
                try {
                    List<ClassDTO> moduleClasses = classServiceFacade.ListAllClassesUnderModule(module.moduleId);
                    if (moduleClasses != null) {
                        allClasses.addAll(moduleClasses);
                    }
                } catch (Exception e) {
                    // Continue if error
                }
            }
            int totalClasses = allClasses.size();

            // Get total assessments
            int totalAssessments = 0;
            for (ClassDTO classDTO : allClasses) {
                try {
                    List<AssessmentDTO> assessments = assessmentServiceFacade.ListAllAssessmentsInClass(classDTO.classId);
                    totalAssessments += assessments != null ? assessments.size() : 0;
                } catch (Exception e) {
                    // Continue
                }
            }

            // Get total lecturers assigned (from modules)
            Set<Long> lecturerIds = new HashSet<>();
            for (ModuleDTO module : managedModules) {
                if (module.managedBy != null) {
                    lecturerIds.add(module.managedBy.userId);
                }
            }
            int totalLecturers = lecturerIds.size();

            // Get total students enrolled
            Set<Long> studentIds = new HashSet<>();
            for (ClassDTO classDTO : allClasses) {
                if (classDTO.students != null) {
                    for (StudentDTO student : classDTO.students) {
                        studentIds.add(student.userId);
                    }
                }
            }
            int totalStudents = studentIds.size();

            // Recent modules
            List<ModuleDTO> recentModules = managedModules.stream()
                    .sorted((m1, m2) -> Long.compare(m2.moduleId, m1.moduleId))
                    .limit(5)
                    .collect(Collectors.toList());

            request.setAttribute("totalModules", totalModules);
            request.setAttribute("totalClasses", totalClasses);
            request.setAttribute("totalAssessments", totalAssessments);
            request.setAttribute("totalLecturers", totalLecturers);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("managedModules", managedModules);
            request.setAttribute("recentModules", recentModules);

        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Error loading academic leader dashboard: " + e.getMessage(), request);
        }
    }

    private void loadLecturerDashboard(HttpServletRequest request, Long lecturerId) {
        try {
            // Get classes taught by lecturer
            List<ClassDTO> myClasses = classServiceFacade.ListAllClassesUnderLecturer(lecturerId);
            int totalClasses = myClasses != null ? myClasses.size() : 0;
            if (myClasses == null) myClasses = new ArrayList<>();

            // Get total students
            int totalStudents = 0;
            for (ClassDTO classDTO : myClasses) {
                if (classDTO.students != null) {
                    totalStudents += classDTO.students.size();
                }
            }

            // Get assessments created in lecturer's classes
            List<AssessmentDTO> myAssessments = new ArrayList<>();
            for (ClassDTO classDTO : myClasses) {
                try {
                    List<AssessmentDTO> assessments = assessmentServiceFacade.ListAllAssessmentsInClass(classDTO.classId);
                    if (assessments != null) {
                        myAssessments.addAll(assessments);
                    }
                } catch (Exception e) {
                    // Continue
                }
            }
            int totalAssessments = myAssessments.size();

            // Get submissions to grade
            int pendingGrading = 0;
            int gradedSubmissions = 0;
            List<SubmissionDTO> recentSubmissions = new ArrayList<>();

            for (AssessmentDTO assessment : myAssessments) {
                try {
                    List<SubmissionDTO> submissions = submissionServiceFacade.GetSubmissionsByAssessment(assessment.getAssessmentId());
                    if (submissions != null) {
                        for (SubmissionDTO submission : submissions) {
                            if ("PENDING".equals(submission.getGradingStatus())) {
                                pendingGrading++;
                            } else if ("GRADED".equals(submission.getGradingStatus())) {
                                gradedSubmissions++;
                            }
                        }
                        recentSubmissions.addAll(submissions);
                    }
                } catch (Exception e) {
                    // Continue
                }
            }

            // Sort recent submissions by date
            recentSubmissions.sort((s1, s2) -> {
                if (s1.getSubmittedAt() == null || s2.getSubmittedAt() == null) return 0;
                return s2.getSubmittedAt().compareTo(s1.getSubmittedAt());
            });
            recentSubmissions = recentSubmissions.stream().limit(10).collect(Collectors.toList());

            // Get upcoming assessments (deadlines)
            Date today = new Date();
            List<AssessmentDTO> upcomingAssessments = myAssessments.stream()
                    .filter(a -> a.getDeadline() != null && a.getDeadline().after(today))
                    .sorted(Comparator.comparing(AssessmentDTO::getDeadline))
                    .limit(5)
                    .collect(Collectors.toList());

            request.setAttribute("totalClasses", totalClasses);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("totalAssessments", totalAssessments);
            request.setAttribute("pendingGrading", pendingGrading);
            request.setAttribute("gradedSubmissions", gradedSubmissions);
            request.setAttribute("myClasses", myClasses);
            request.setAttribute("recentSubmissions", recentSubmissions);
            request.setAttribute("upcomingAssessments", upcomingAssessments);

        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Error loading lecturer dashboard: " + e.getMessage(), request);
        }
    }

    private void loadStudentDashboard(HttpServletRequest request, Long studentId) {
        try {
            // Get enrolled classes
            List<ClassDTO> enrolledClasses = classServiceFacade.ListAllClassesUnderStudent(studentId);
            int totalClasses = enrolledClasses != null ? enrolledClasses.size() : 0;
            if (enrolledClasses == null) enrolledClasses = new ArrayList<>();

            // Get all assessments
            List<AssessmentDTO> allAssessments = new ArrayList<>();
            for (ClassDTO classDTO : enrolledClasses) {
                try {
                    List<AssessmentDTO> assessments = assessmentServiceFacade.ListVisibleAssessmentsForStudent(classDTO.classId, studentId);
                    if (assessments != null) {
                        for (AssessmentDTO assessment : assessments) {
                            assessment.setClassName(classDTO.className);
                        }
                        allAssessments.addAll(assessments);
                    }
                } catch (Exception e) {
                    // Continue
                }
            }

            // Count submissions
            int totalAssessments = allAssessments.size();
            int completedAssessments = 0;
            int pendingAssessments = 0;

            for (AssessmentDTO assessment : allAssessments) {
                if (assessment.getSubmission() != null) {
                    completedAssessments++;
                } else {
                    pendingAssessments++;
                }
            }

            // Get upcoming assessments
            Date today = new Date();
            List<AssessmentDTO> upcomingAssessments = allAssessments.stream()
                    .filter(a -> a.getDeadline() != null && a.getDeadline().after(today))
                    .filter(a -> a.getSubmission() == null) // Not yet submitted
                    .sorted(Comparator.comparing(AssessmentDTO::getDeadline))
                    .limit(5)
                    .collect(Collectors.toList());

            // Get recent submissions with scores
            List<AssessmentDTO> recentSubmissions = allAssessments.stream()
                    .filter(a -> a.getSubmission() != null)
                    .sorted((a1, a2) -> {
                        if (a1.getSubmission().getSubmittedAt() == null || a2.getSubmission().getSubmittedAt() == null) return 0;
                        return a2.getSubmission().getSubmittedAt().compareTo(a1.getSubmission().getSubmittedAt());
                    })
                    .limit(5)
                    .collect(Collectors.toList());

            // Calculate average score
            double averageScore = 0;
            int gradedCount = 0;
            for (AssessmentDTO assessment : allAssessments) {
                if (assessment.getSubmission() != null && assessment.getSubmission().getScore() != null) {
                    averageScore += assessment.getSubmission().getScore();
                    gradedCount++;
                }
            }
            if (gradedCount > 0) {
                averageScore = averageScore / gradedCount;
            }

            request.setAttribute("totalClasses", totalClasses);
            request.setAttribute("totalAssessments", totalAssessments);
            request.setAttribute("completedAssessments", completedAssessments);
            request.setAttribute("pendingAssessments", pendingAssessments);
            request.setAttribute("averageScore", Math.round(averageScore * 10.0) / 10.0);
            request.setAttribute("enrolledClasses", enrolledClasses);
            request.setAttribute("upcomingAssessments", upcomingAssessments);
            request.setAttribute("recentSubmissions", recentSubmissions);

        } catch (Exception e) {
            MessageModal.DisplayErrorMessage("Error loading student dashboard: " + e.getMessage(), request);
        }
    }
}
