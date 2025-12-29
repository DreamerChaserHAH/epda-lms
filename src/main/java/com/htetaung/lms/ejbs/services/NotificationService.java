package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.NotificationFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.exception.ClassException;
import com.htetaung.lms.models.Notification;
import com.htetaung.lms.models.User;
import com.htetaung.lms.models.dto.ClassEnrollmentDTO;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import java.util.List;

@Stateless
public class NotificationService {

    @EJB
    private NotificationFacade notificationFacade;

    @EJB
    private UserFacade userFacade;

    @EJB
    private ClassServiceFacade enrollmentFacade;

    @EJB
    private EmailService emailService;

    public void createNotification(User user, String title, String message, String type, Long relatedId, String relatedType) {
        Notification notification = new Notification(user, title, message, type);
        notification.setRelatedId(relatedId);
        notification.setRelatedType(relatedType);
        notificationFacade.create(notification, "system");

        // Send email notification
        String email = user.getUsername() + "@student.apu.edu.my"; // Adjust based on your email pattern
        String link = "http://localhost:8080/?page=my_results"; // Adjust based on notification type
        emailService.sendNotificationEmail(email, type, title, message, link);
        notification.setEmailSent(true);
        notificationFacade.edit(notification, "system");
    }

    public void notifyNewAssignment(Long assessmentId, String assessmentName, Long classId) throws ClassException {
        if (classId != null) {
            List<ClassEnrollmentDTO> enrollments = enrollmentFacade.FindEnrollmentsInClass(classId);
            for (ClassEnrollmentDTO enrollment : enrollments) {
                createNotification(
                    userFacade.find(enrollment.getStudentDTO().userId),
                    "New Assignment: " + assessmentName,
                    "A new assignment has been posted: " + assessmentName,
                    "NEW_ASSIGNMENT",
                    assessmentId,
                    "ASSESSMENT"
                );
            }
        }
    }

    public void notifyGradePosted(Long submissionId, Long studentId, String assessmentName, Double marks) {
        User student = userFacade.find(studentId);
        if (student != null) {
            createNotification(
                student,
                "Grade Posted: " + assessmentName,
                "Your submission for " + assessmentName + " has been graded. Marks: " + marks,
                "GRADE_POSTED",
                submissionId,
                "SUBMISSION"
            );
        }
    }

    public void notifyDeadlineReminder(Long assessmentId, String assessmentName, Long studentId, int daysRemaining) {
        User student = userFacade.find(studentId);
        if (student != null) {
            createNotification(
                student,
                "Deadline Reminder: " + assessmentName,
                "Reminder: " + assessmentName + " is due in " + daysRemaining + " day(s).",
                "DEADLINE_REMINDER",
                assessmentId,
                "ASSESSMENT"
            );
        }
    }

    public void notifyAnnouncement(Long classId, String title, String message) throws ClassException {
        if (classId != null) {
            List<ClassEnrollmentDTO> enrollments = enrollmentFacade.FindEnrollmentsInClass(classId);
            for (ClassEnrollmentDTO enrollment : enrollments) {
                createNotification(
                        userFacade.find(enrollment.getStudentDTO().userId),
                    "Announcement: " + title,
                    message,
                    "ANNOUNCEMENT",
                    classId,
                    "CLASS"
                );
            }
        }
    }
}

