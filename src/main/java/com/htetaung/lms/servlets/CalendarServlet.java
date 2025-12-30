package com.htetaung.lms.servlets;

import com.htetaung.lms.ejbs.services.AssessmentServiceFacade;
import com.htetaung.lms.ejbs.services.ClassServiceFacade;
import com.htetaung.lms.models.dto.AssessmentDTO;
import com.htetaung.lms.models.dto.ClassDTO;
import com.htetaung.lms.utils.MessageModal;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet(name = "calendarServlet", urlPatterns = {"/api/calendar"})
public class CalendarServlet extends HttpServlet {

    @EJB
    private ClassServiceFacade classServiceFacade;

    @EJB
    private AssessmentServiceFacade assessmentServiceFacade;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String includingPage = (String) request.getAttribute("includingPage");
        Long studentId = (Long) request.getSession().getAttribute("userId");

        if (studentId == null) {
            MessageModal.DisplayErrorMessage("Student ID not found in session", request);
            return;
        }

        try {
            // Get all classes the student is enrolled in
            List<ClassDTO> enrolledClasses = classServiceFacade.ListAllClassesUnderStudent(studentId);

            // Collect all assessments from all enrolled classes
            List<AssessmentDTO> allAssessments = new ArrayList<>();

            for (ClassDTO classDTO : enrolledClasses) {
                List<AssessmentDTO> classAssessments = assessmentServiceFacade
                        .ListVisibleAssessmentsForStudent(classDTO.classId, studentId);

                // Enrich with submission info
                classAssessments = assessmentServiceFacade.EnrichWithSubmissionInfo(classAssessments, studentId);

                // Add class name to each assessment for display
                for (AssessmentDTO assessment : classAssessments) {
                    assessment.setClassName(classDTO.className);
                }

                allAssessments.addAll(classAssessments);
            }

            // Filter only future assessments (including today)
            Date now = new Date();
            Calendar cal = Calendar.getInstance();
            cal.setTime(now);
            cal.set(Calendar.HOUR_OF_DAY, 0);
            cal.set(Calendar.MINUTE, 0);
            cal.set(Calendar.SECOND, 0);
            cal.set(Calendar.MILLISECOND, 0);
            Date today = cal.getTime();

            List<AssessmentDTO> upcomingAssessments = allAssessments.stream()
                    .filter(a -> a.getDeadline() != null && !a.getDeadline().before(today))
                    .sorted(Comparator.comparing(AssessmentDTO::getDeadline))
                    .collect(Collectors.toList());

            // Group assessments by date for calendar view
            Map<String, List<AssessmentDTO>> assessmentsByDate = new LinkedHashMap<>();
            for (AssessmentDTO assessment : upcomingAssessments) {
                String dateKey = formatDate(assessment.getDeadline());
                assessmentsByDate.computeIfAbsent(dateKey, k -> new ArrayList<>()).add(assessment);
            }

            // Calculate statistics
            int totalUpcoming = upcomingAssessments.size();
            long upcomingThisWeek = upcomingAssessments.stream()
                    .filter(a -> isWithinDays(a.getDeadline(), 7))
                    .count();
            long upcomingThisMonth = upcomingAssessments.stream()
                    .filter(a -> isWithinDays(a.getDeadline(), 30))
                    .count();

            // Set attributes
            request.setAttribute("upcomingAssessments", upcomingAssessments);
            request.setAttribute("assessmentsByDate", assessmentsByDate);
            request.setAttribute("totalUpcoming", totalUpcoming);
            request.setAttribute("upcomingThisWeek", upcomingThisWeek);
            request.setAttribute("upcomingThisMonth", upcomingThisMonth);

            String targetPage = (includingPage != null && !includingPage.isEmpty())
                    ? includingPage
                    : "/WEB-INF/views/student/calendar-view.jsp";

            request.getRequestDispatcher(targetPage).include(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            MessageModal.DisplayErrorMessage("Error loading calendar: " + e.getMessage(), request);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("export".equals(action)) {
            exportCalendar(request, response);
        }
    }

    private void exportCalendar(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Long studentId = (Long) request.getSession().getAttribute("userId");

        if (studentId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Student ID not found");
            return;
        }

        try {
            // Get all upcoming assessments
            List<ClassDTO> enrolledClasses = classServiceFacade.ListAllClassesUnderStudent(studentId);
            List<AssessmentDTO> allAssessments = new ArrayList<>();

            for (ClassDTO classDTO : enrolledClasses) {
                List<AssessmentDTO> classAssessments = assessmentServiceFacade
                        .ListVisibleAssessmentsForStudent(classDTO.classId, studentId);

                for (AssessmentDTO assessment : classAssessments) {
                    assessment.setClassName(classDTO.className);
                }

                allAssessments.addAll(classAssessments);
            }

            // Filter upcoming assessments
            Date today = getTodayStart();
            List<AssessmentDTO> upcomingAssessments = allAssessments.stream()
                    .filter(a -> a.getDeadline() != null && !a.getDeadline().before(today))
                    .sorted(Comparator.comparing(AssessmentDTO::getDeadline))
                    .collect(Collectors.toList());

            // Generate iCalendar content
            String icsContent = generateICalendar(upcomingAssessments);

            // Set response headers
            response.setContentType("text/calendar");
            response.setHeader("Content-Disposition", "attachment; filename=\"lms-calendar.ics\"");
            response.setCharacterEncoding("UTF-8");

            // Write content
            response.getWriter().write(icsContent);
            response.getWriter().flush();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error exporting calendar: " + e.getMessage());
        }
    }

    private String generateICalendar(List<AssessmentDTO> assessments) {
        StringBuilder ics = new StringBuilder();

        // iCalendar header
        ics.append("BEGIN:VCALENDAR\r\n");
        ics.append("VERSION:2.0\r\n");
        ics.append("PRODID:-//LMS//Assessment Calendar//EN\r\n");
        ics.append("CALSCALE:GREGORIAN\r\n");
        ics.append("METHOD:PUBLISH\r\n");
        ics.append("X-WR-CALNAME:LMS Assessments\r\n");
        ics.append("X-WR-TIMEZONE:UTC\r\n");

        // Add each assessment as an event
        for (AssessmentDTO assessment : assessments) {
            ics.append("BEGIN:VEVENT\r\n");
            ics.append("UID:").append(generateUID(assessment)).append("\r\n");
            ics.append("DTSTAMP:").append(formatDateTimeUTC(new Date())).append("\r\n");
            ics.append("DTSTART:").append(formatDateTimeUTC(assessment.getDeadline())).append("\r\n");
            ics.append("DTEND:").append(formatDateTimeUTC(assessment.getDeadline())).append("\r\n");
            ics.append("SUMMARY:").append(escapeICalText(assessment.getAssessmentName() + " - " + assessment.getClassName())).append("\r\n");

            if (assessment.getAssessmentDescription() != null && !assessment.getAssessmentDescription().isEmpty()) {
                ics.append("DESCRIPTION:").append(escapeICalText(assessment.getAssessmentDescription())).append("\r\n");
            }

            ics.append("STATUS:CONFIRMED\r\n");
            ics.append("SEQUENCE:0\r\n");

            // Add alarm 1 day before
            ics.append("BEGIN:VALARM\r\n");
            ics.append("TRIGGER:-P1D\r\n");
            ics.append("ACTION:DISPLAY\r\n");
            ics.append("DESCRIPTION:Assessment due tomorrow\r\n");
            ics.append("END:VALARM\r\n");

            ics.append("END:VEVENT\r\n");
        }

        // iCalendar footer
        ics.append("END:VCALENDAR\r\n");

        return ics.toString();
    }

    private String generateUID(AssessmentDTO assessment) {
        return "assessment-" + assessment.getAssessmentId() + "@lms.local";
    }

    private String formatDateTimeUTC(Date date) {
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        cal.setTime(date);

        return String.format("%04d%02d%02dT%02d%02d%02dZ",
                cal.get(Calendar.YEAR),
                cal.get(Calendar.MONTH) + 1,
                cal.get(Calendar.DAY_OF_MONTH),
                cal.get(Calendar.HOUR_OF_DAY),
                cal.get(Calendar.MINUTE),
                cal.get(Calendar.SECOND));
    }

    private String escapeICalText(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                .replace(";", "\\;")
                .replace(",", "\\,")
                .replace("\n", "\\n");
    }

    private Date getTodayStart() {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }

    /**
     * Format date as "yyyy-MM-dd"
     */
    private String formatDate(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        return String.format("%04d-%02d-%02d",
                cal.get(Calendar.YEAR),
                cal.get(Calendar.MONTH) + 1,
                cal.get(Calendar.DAY_OF_MONTH));
    }

    /**
     * Check if date is within specified number of days from now
     */
    private boolean isWithinDays(Date date, int days) {
        if (date == null) return false;

        Calendar now = Calendar.getInstance();
        now.set(Calendar.HOUR_OF_DAY, 0);
        now.set(Calendar.MINUTE, 0);
        now.set(Calendar.SECOND, 0);
        now.set(Calendar.MILLISECOND, 0);

        Calendar target = Calendar.getInstance();
        target.setTime(date);
        target.set(Calendar.HOUR_OF_DAY, 0);
        target.set(Calendar.MINUTE, 0);
        target.set(Calendar.SECOND, 0);
        target.set(Calendar.MILLISECOND, 0);

        long diffMillis = target.getTimeInMillis() - now.getTimeInMillis();
        long diffDays = diffMillis / (24 * 60 * 60 * 1000);

        return diffDays >= 0 && diffDays <= days;
    }
}

