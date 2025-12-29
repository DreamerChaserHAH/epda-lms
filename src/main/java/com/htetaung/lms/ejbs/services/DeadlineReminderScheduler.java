package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.AssessmentFacade;
import com.htetaung.lms.ejbs.facades.ClassEnrollmentFacade;
import com.htetaung.lms.models.Assessment;
import com.htetaung.lms.models.ClassEnrollment;
import jakarta.ejb.EJB;
import jakarta.ejb.Schedule;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

@Singleton
@Startup
public class DeadlineReminderScheduler {

    @EJB
    private AssessmentFacade assessmentFacade;

    @EJB
    private ClassEnrollmentFacade enrollmentFacade;

    @EJB
    private NotificationService notificationService;

    // Run daily at 9 AM
    @Schedule(hour = "9", minute = "0", persistent = false)
    public void checkDeadlines() {
        try {
            List<Assessment> assessments = assessmentFacade.findAll();
            Date now = new Date();
            Calendar cal = Calendar.getInstance();
            cal.setTime(now);
            cal.add(Calendar.DAY_OF_MONTH, 1);
            Date tomorrow = cal.getTime();
            cal.add(Calendar.DAY_OF_MONTH, 1);
            Date dayAfter = cal.getTime();

            for (Assessment assessment : assessments) {
                Date deadline = assessment.getDeadline();
                
                // Check if deadline is tomorrow (1 day reminder)
                if (deadline.after(tomorrow) && deadline.before(dayAfter)) {
                    sendReminders(assessment, 1);
                }
                // Check if deadline is in 3 days
                else if (deadline.after(dayAfter)) {
                    cal.setTime(now);
                    cal.add(Calendar.DAY_OF_MONTH, 3);
                    Date threeDays = cal.getTime();
                    cal.add(Calendar.DAY_OF_MONTH, 1);
                    Date fourDays = cal.getTime();
                    
                    if (deadline.after(threeDays) && deadline.before(fourDays)) {
                        sendReminders(assessment, 3);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error in deadline reminder scheduler: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void sendReminders(Assessment assessment, int daysRemaining) {
        // Note: This is a simplified version. In production, you'd:
        // 1. Get students enrolled in the class related to the assessment
        // 2. Check if they've already submitted
        // 3. Only send to students who haven't submitted
        
        // For now, we'll send to all students (you can enhance this)
        // This would require linking assessments to classes
        try {
            // Get all active enrollments (simplified - in production, filter by assessment's class)
            List<ClassEnrollment> enrollments = enrollmentFacade.findAll();
            
            for (ClassEnrollment enrollment : enrollments) {
                if (enrollment.getIsActive() && 
                    enrollment.getStudent().getRole().toString().equals("STUDENT")) {
                    notificationService.notifyDeadlineReminder(
                        assessment.getId(),
                        assessment.getName(),
                        enrollment.getStudent().getUserId(),
                        daysRemaining
                    );
                }
            }
        } catch (Exception e) {
            System.err.println("Error sending deadline reminders: " + e.getMessage());
        }
    }
}

