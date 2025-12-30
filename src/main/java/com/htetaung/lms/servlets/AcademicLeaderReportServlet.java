package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.*;
import com.htetaung.lms.models.dto.*;
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
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet(name = "academicLeaderReportServlet", urlPatterns = {"/api/academic-leader-reports", "/api/academic-leader-detail-reports"})
public class AcademicLeaderReportServlet extends HttpServlet {

    @EJB
    private UserServiceFacade userServiceFacade;

    @EJB
    private ModuleServiceFacade moduleServiceFacade;

    @EJB
    private ClassServiceFacade classServiceFacade;

    @EJB
    private AssessmentServiceFacade assessmentServiceFacade;

    @EJB
    private SubmissionServiceFacade submissionServiceFacade;

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

        Long academicLeaderId = (Long) session.getAttribute("userId");
        String reportType = request.getParameter("type");
        if (reportType == null) reportType = "overview";

        System.out.println("DEBUG: AcademicLeaderReportServlet - Report Type: " + reportType);
        System.out.println("DEBUG: AcademicLeaderReportServlet - Academic Leader ID: " + academicLeaderId);

        try {
            switch (reportType) {
                case "student-performance":
                    System.out.println("DEBUG: Loading student performance report");
                    loadStudentPerformanceReport(request, academicLeaderId);
                    break;
                case "class-enrollment":
                    System.out.println("DEBUG: Loading class enrollment report");
                    loadClassEnrollmentReport(request, academicLeaderId);
                    break;
                case "lecturer-performance":
                    System.out.println("DEBUG: Loading lecturer performance report");
                    loadLecturerPerformanceReport(request, academicLeaderId);
                    break;
                case "module-performance":
                    System.out.println("DEBUG: Loading module performance report");
                    loadModulePerformanceReport(request, academicLeaderId);
                    break;
                case "student-satisfaction":
                    System.out.println("DEBUG: Loading student satisfaction report");
                    loadStudentSatisfactionReport(request, academicLeaderId);
                    break;
                default:
                    System.out.println("DEBUG: Loading overview report");
                    loadOverviewReport(request);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("DEBUG: Error in servlet: " + e.getMessage());
            MessageModal.DisplayErrorMessage("Error loading report: " + e.getMessage(), request);
        }
    }

    private void loadOverviewReport(HttpServletRequest request) {
        try {
            List<UserDTO> allUsers = userServiceFacade.getUsers(1);
            long totalStudents = allUsers.stream().filter(u -> u.role == UserRole.STUDENT).count();
            long totalLecturers = allUsers.stream().filter(u -> u.role == UserRole.LECTURER).count();

            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("totalLecturers", totalLecturers);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Report 1: University-Wide Student Performance Report (scoped to academic leader)
    private void loadStudentPerformanceReport(HttpServletRequest request, Long academicLeaderId) {
        try {
            // Get modules under this academic leader
            List<ModuleDTO> modules = moduleServiceFacade.ListAllModulesUnderAcademicLeader(academicLeaderId, 1);
            if (modules == null) modules = new ArrayList<>();

            // Get all classes under these modules
            Set<Long> classIds = new HashSet<>();
            for (ModuleDTO module : modules) {
                List<ClassDTO> classes = classServiceFacade.ListAllClassesUnderModule(module.moduleId);
                if (classes != null) {
                    for (ClassDTO classDTO : classes) {
                        classIds.add(classDTO.classId);
                    }
                }
            }

            // Get all students enrolled in these classes
            Set<Long> studentIds = new HashSet<>();
            Map<Long, StudentDTO> studentMap = new HashMap<>();

            for (Long classId : classIds) {
                ClassDTO classDTO = classServiceFacade.GetClass(classId);
                if (classDTO != null && classDTO.students != null) {
                    for (StudentDTO student : classDTO.students) {
                        studentIds.add(student.userId);
                        studentMap.put(student.userId, student);
                    }
                }
            }

            int totalStudents = studentIds.size();
            int studentsWithSubmissions = 0;
            int passedStudents = 0;
            int failedStudents = 0;
            double totalScore = 0;
            int gradedSubmissions = 0;

            Map<Long, StudentPerformance> studentPerformanceMap = new HashMap<>();

            // Get submissions for students in these classes
            for (Long studentId : studentIds) {
                try {
                    List<SubmissionDTO> submissions = submissionServiceFacade.GetSubmissionsByStudent(studentId);
                    if (submissions != null && !submissions.isEmpty()) {
                        studentsWithSubmissions++;

                        double studentTotal = 0;
                        int studentGradedCount = 0;

                        for (SubmissionDTO sub : submissions) {
                            if (sub.getScore() != null && "GRADED".equals(sub.getGradingStatus())) {
                                studentTotal += sub.getScore();
                                studentGradedCount++;
                                totalScore += sub.getScore();
                                gradedSubmissions++;
                            }
                        }

                        if (studentGradedCount > 0) {
                            double avgScore = studentTotal / studentGradedCount;
                            StudentDTO student = studentMap.get(studentId);
                            StudentPerformance perf = new StudentPerformance();
                            perf.studentName = student.fullname;
                            perf.studentEmail = student.email;
                            perf.totalSubmissions = submissions.size();
                            perf.gradedSubmissions = studentGradedCount;
                            perf.averageScore = avgScore;
                            perf.status = avgScore >= 50 ? "Passed" : "Failed";

                            if (avgScore >= 50) {
                                passedStudents++;
                            } else {
                                failedStudents++;
                            }

                            studentPerformanceMap.put(studentId, perf);
                        }
                    }
                } catch (Exception e) {
                    // Continue
                }
            }

            double overallAverage = gradedSubmissions > 0 ? totalScore / gradedSubmissions : 0;
            double passRate = studentsWithSubmissions > 0 ? (passedStudents * 100.0) / studentsWithSubmissions : 0;

            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("studentsWithSubmissions", studentsWithSubmissions);
            request.setAttribute("passedStudents", passedStudents);
            request.setAttribute("failedStudents", failedStudents);
            request.setAttribute("overallAverage", Math.round(overallAverage * 10.0) / 10.0);
            request.setAttribute("passRate", Math.round(passRate * 10.0) / 10.0);
            request.setAttribute("studentPerformances", new ArrayList<>(studentPerformanceMap.values()));

        } catch (Exception e) {
            e.printStackTrace();
            MessageModal.DisplayErrorMessage("Error loading student performance report: " + e.getMessage(), request);
        }
    }

    // Report 2: Class Enrollment Report
    private void loadClassEnrollmentReport(HttpServletRequest request, Long academicLeaderId) {
        try {
            System.out.println("DEBUG: loadClassEnrollmentReport - Starting with academicLeaderId: " + academicLeaderId);

            List<ModuleDTO> modules = moduleServiceFacade.ListAllModulesUnderAcademicLeader(academicLeaderId, 1);
            if (modules == null) modules = new ArrayList<>();

            System.out.println("DEBUG: loadClassEnrollmentReport - Found " + modules.size() + " modules");

            List<ClassEnrollment> classEnrollments = new ArrayList<>();

            for (ModuleDTO module : modules) {
                try {
                    List<ClassDTO> classes = classServiceFacade.ListAllClassesUnderModule(module.moduleId);
                    System.out.println("DEBUG: loadClassEnrollmentReport - Module '" + module.moduleName + "' has " + (classes != null ? classes.size() : 0) + " classes");

                    if (classes != null) {
                        for (ClassDTO classDTO : classes) {
                            ClassEnrollment enrollment = new ClassEnrollment();
                            enrollment.className = classDTO.className;
                            enrollment.moduleName = module.moduleName;
                            enrollment.lecturerName = module.managedBy != null ? module.managedBy.fullname : "Unassigned";
                            enrollment.totalStudents = classDTO.students != null ? classDTO.students.size() : 0;
                            enrollment.capacity = 50; // Default capacity
                            enrollment.enrollmentRate = enrollment.capacity > 0 ? (enrollment.totalStudents * 100.0) / enrollment.capacity : 0;

                            // Count assessments
                            List<AssessmentDTO> assessments = assessmentServiceFacade.ListAllAssessmentsInClass(classDTO.classId);
                            enrollment.totalAssessments = assessments != null ? assessments.size() : 0;

                            classEnrollments.add(enrollment);
                            System.out.println("DEBUG: loadClassEnrollmentReport - Added class '" + enrollment.className + "' with " + enrollment.totalStudents + " students");
                        }
                    }
                } catch (Exception e) {
                    System.out.println("DEBUG: loadClassEnrollmentReport - Error processing module: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            System.out.println("DEBUG: loadClassEnrollmentReport - Total class enrollments: " + classEnrollments.size());
            request.setAttribute("classEnrollments", classEnrollments);
            System.out.println("DEBUG: loadClassEnrollmentReport - Set attribute 'classEnrollments' with " + classEnrollments.size() + " items");

        } catch (Exception e) {
            e.printStackTrace();
            MessageModal.DisplayErrorMessage("Error loading class enrollment report: " + e.getMessage(), request);
        }
    }

    // Report 3: Lecturer Performance Report
    private void loadLecturerPerformanceReport(HttpServletRequest request, Long academicLeaderId) {
        try {
            List<ModuleDTO> modules = moduleServiceFacade.ListAllModulesUnderAcademicLeader(academicLeaderId, 1);
            if (modules == null) modules = new ArrayList<>();

            Map<Long, LecturerPerformance> lecturerMap = new HashMap<>();

            // Iterate through modules to find lecturers
            for (ModuleDTO module : modules) {
                if (module.managedBy != null) {
                    Long lecturerId = module.managedBy.userId;

                    if (!lecturerMap.containsKey(lecturerId)) {
                        LecturerPerformance perf = new LecturerPerformance();
                        perf.lecturerName = module.managedBy.fullname;
                        perf.lecturerEmail = "";
                        perf.totalClasses = 0;
                        perf.totalStudents = 0;
                        perf.totalAssessments = 0;
                        perf.totalSubmissions = 0;
                        perf.gradedSubmissions = 0;
                        perf.pendingSubmissions = 0;
                        perf.averageScore = 0;
                        perf.gradingRate = 0;
                        lecturerMap.put(lecturerId, perf);
                    }

                    LecturerPerformance perf = lecturerMap.get(lecturerId);
                    List<ClassDTO> classes = classServiceFacade.ListAllClassesUnderModule(module.moduleId);

                    if (classes != null) {
                        perf.totalClasses += classes.size();
                        double totalScore = 0;
                        int scoredCount = 0;

                        for (ClassDTO classDTO : classes) {
                            perf.totalStudents += classDTO.students != null ? classDTO.students.size() : 0;

                            List<AssessmentDTO> assessments = assessmentServiceFacade.ListAllAssessmentsInClass(classDTO.classId);
                            if (assessments != null) {
                                perf.totalAssessments += assessments.size();

                                for (AssessmentDTO assessment : assessments) {
                                    List<SubmissionDTO> submissions = submissionServiceFacade.GetSubmissionsByAssessment(assessment.getAssessmentId());
                                    if (submissions != null) {
                                        perf.totalSubmissions += submissions.size();

                                        for (SubmissionDTO sub : submissions) {
                                            if ("GRADED".equals(sub.getGradingStatus())) {
                                                perf.gradedSubmissions++;
                                                if (sub.getScore() != null) {
                                                    totalScore += sub.getScore();
                                                    scoredCount++;
                                                }
                                            } else {
                                                perf.pendingSubmissions++;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        perf.averageScore = scoredCount > 0 ? totalScore / scoredCount : 0;
                        perf.gradingRate = perf.totalSubmissions > 0 ? (perf.gradedSubmissions * 100.0) / perf.totalSubmissions : 0;
                    }
                }
            }

            request.setAttribute("lecturerPerformances", new ArrayList<>(lecturerMap.values()));

        } catch (Exception e) {
            e.printStackTrace();
            MessageModal.DisplayErrorMessage("Error loading lecturer performance report: " + e.getMessage(), request);
        }
    }

    // Report 4: Module Performance Report
    private void loadModulePerformanceReport(HttpServletRequest request, Long academicLeaderId) {
        try {
            List<ModuleDTO> modules = moduleServiceFacade.ListAllModulesUnderAcademicLeader(academicLeaderId, 1);
            if (modules == null) modules = new ArrayList<>();

            List<ModulePerformance> modulePerformances = new ArrayList<>();

            for (ModuleDTO module : modules) {
                            ModulePerformance perf = new ModulePerformance();
                            perf.moduleName = module.moduleName;
                            perf.managedBy = module.managedBy != null ? module.managedBy.fullname : "Unassigned";

                            List<ClassDTO> classes = classServiceFacade.ListAllClassesUnderModule(module.moduleId);
                            if (classes != null) {
                                perf.totalClasses = classes.size();

                                int totalStudents = 0;
                                int totalAssessments = 0;
                                double totalScore = 0;
                                int scoredCount = 0;

                                for (ClassDTO classDTO : classes) {
                                    totalStudents += classDTO.students != null ? classDTO.students.size() : 0;

                                    List<AssessmentDTO> assessments = assessmentServiceFacade.ListAllAssessmentsInClass(classDTO.classId);
                                    if (assessments != null) {
                                        totalAssessments += assessments.size();

                                        for (AssessmentDTO assessment : assessments) {
                                            List<SubmissionDTO> submissions = submissionServiceFacade.GetSubmissionsByAssessment(assessment.getAssessmentId());
                                            if (submissions != null) {
                                                for (SubmissionDTO sub : submissions) {
                                                    if (sub.getScore() != null && "GRADED".equals(sub.getGradingStatus())) {
                                                        totalScore += sub.getScore();
                                                        scoredCount++;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                perf.totalStudents = totalStudents;
                                perf.totalAssessments = totalAssessments;
                                perf.averageScore = scoredCount > 0 ? totalScore / scoredCount : 0;
                            }

                            modulePerformances.add(perf);
            }

            request.setAttribute("modulePerformances", modulePerformances);

        } catch (Exception e) {
            e.printStackTrace();
            MessageModal.DisplayErrorMessage("Error loading module performance report: " + e.getMessage(), request);
        }
    }

    // Report 5: Student Satisfaction Report
    private void loadStudentSatisfactionReport(HttpServletRequest request, Long academicLeaderId) {
        try {
            List<ModuleDTO> modules = moduleServiceFacade.ListAllModulesUnderAcademicLeader(academicLeaderId, 1);
            if (modules == null) modules = new ArrayList<>();

            List<AssessmentFeedback> feedbacks = new ArrayList<>();

            for (ModuleDTO module : modules) {
                            List<ClassDTO> classes = classServiceFacade.ListAllClassesUnderModule(module.moduleId);
                            if (classes != null) {
                                for (ClassDTO classDTO : classes) {
                                    List<AssessmentDTO> assessments = assessmentServiceFacade.ListAllAssessmentsInClass(classDTO.classId);
                                    if (assessments != null) {
                                        for (AssessmentDTO assessment : assessments) {
                                            List<SubmissionDTO> submissions = submissionServiceFacade.GetSubmissionsByAssessment(assessment.getAssessmentId());
                                            if (submissions != null && !submissions.isEmpty()) {
                                                AssessmentFeedback feedback = new AssessmentFeedback();
                                                feedback.assessmentName = assessment.getAssessmentName();
                                                feedback.className = classDTO.className;
                                                feedback.moduleName = module.moduleName;
                                                feedback.totalSubmissions = submissions.size();

                                                // Calculate difficulty based on average score
                                                double totalScore = 0;
                                                int scoredCount = 0;
                                                for (SubmissionDTO sub : submissions) {
                                                    if (sub.getScore() != null) {
                                                        totalScore += sub.getScore();
                                                        scoredCount++;
                                                    }
                                                }

                                                if (scoredCount > 0) {
                                                    double avgScore = totalScore / scoredCount;
                                                    feedback.averageScore = avgScore;

                                                    // Difficulty rating based on average score
                                                    if (avgScore >= 80) {
                                                        feedback.difficultyLevel = "Too Easy";
                                                        feedback.recommendation = "Consider increasing difficulty";
                                                    } else if (avgScore >= 60) {
                                                        feedback.difficultyLevel = "Appropriate";
                                                        feedback.recommendation = "Maintain current difficulty";
                                                    } else if (avgScore >= 40) {
                                                        feedback.difficultyLevel = "Challenging";
                                                        feedback.recommendation = "Review learning materials";
                                                    } else {
                                                        feedback.difficultyLevel = "Too Difficult";
                                                        feedback.recommendation = "Consider reducing difficulty or providing more support";
                                                    }

                                                    feedbacks.add(feedback);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
            }

            request.setAttribute("assessmentFeedbacks", feedbacks);

        } catch (Exception e) {
            e.printStackTrace();
            MessageModal.DisplayErrorMessage("Error loading student satisfaction report: " + e.getMessage(), request);
        }
    }

    // Inner classes for data structures
    public static class StudentPerformance {
        public String studentName;
        public String studentEmail;
        public int totalSubmissions;
        public int gradedSubmissions;
        public double averageScore;
        public String status;
    }

    public static class ClassEnrollment {
        public String className;
        public String moduleName;
        public String lecturerName;
        public int totalStudents;
        public int capacity;
        public double enrollmentRate;
        public int totalAssessments;
    }

    public static class LecturerPerformance {
        public String lecturerName;
        public String lecturerEmail;
        public int totalClasses;
        public int totalStudents;
        public int totalAssessments;
        public int totalSubmissions;
        public int gradedSubmissions;
        public int pendingSubmissions;
        public double averageScore;
        public double gradingRate;
    }

    public static class ModulePerformance {
        public String moduleName;
        public String managedBy;
        public int totalClasses;
        public int totalStudents;
        public int totalAssessments;
        public double averageScore;
    }

    public static class AssessmentFeedback {
        public String assessmentName;
        public String className;
        public String moduleName;
        public int totalSubmissions;
        public double averageScore;
        public String difficultyLevel;
        public String recommendation;
    }
}

