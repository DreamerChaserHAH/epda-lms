package com.htetaung.lms.ejbs;

import com.htetaung.lms.ejbs.services.UserServiceFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.models.enums.UserRole;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;

import java.util.HashMap;
import java.util.logging.Logger;

@Singleton
@Startup
public class DatabaseInitializer {

    private static final Logger LOGGER = Logger.getLogger(DatabaseInitializer.class.getName());

    @EJB
    private UserFacade userFacade;

    @EJB
    private UserServiceFacade userServiceFacade;

    @PostConstruct
    public void init() {
        try {
            // Check if any users exist
            long userCount = userFacade.count();

            if (userCount == 0) {
                LOGGER.info("No users found. Creating default demo users...");
                createDefaultUsers();
                LOGGER.info("Default demo users created successfully.");
            } else {
                LOGGER.info("Database already contains " + userCount + " users. Verifying demo users exist...");
                verifyAndCreateDemoUsers();
            }
        } catch (Exception e) {
            LOGGER.severe("Failed to initialize database: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void verifyAndCreateDemoUsers() {
        // Check and create admin if missing
        if (!userFacade.findByUsername("admin").isPresent()) {
            LOGGER.info("Admin user not found. Creating...");
            createDefaultAdmin();
        }
        
        // Check and create lecturer if missing
        if (!userFacade.findByUsername("lecturer").isPresent()) {
            LOGGER.info("Lecturer user not found. Creating...");
            createDefaultLecturer();
        }
        
        // Check and create academic leader if missing
        if (!userFacade.findByUsername("leader").isPresent()) {
            LOGGER.info("Academic leader user not found. Creating...");
            createDefaultAcademicLeader();
        }
        
        // Check and create student if missing
        if (!userFacade.findByUsername("student").isPresent()) {
            LOGGER.info("Student user not found. Creating...");
            createDefaultStudent();
        }
    }

    private void createDefaultUsers() {
        // Create Admin user
        try {
            createDefaultAdmin();
        } catch (Exception e) {
            LOGGER.severe("Failed to create admin user: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Create Academic Leader user
        try {
            createDefaultAcademicLeader();
        } catch (Exception e) {
            LOGGER.severe("Failed to create academic leader user: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Create Lecturer user
        try {
            createDefaultLecturer();
        } catch (Exception e) {
            LOGGER.severe("Failed to create lecturer user: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Create Student user
        try {
            createDefaultStudent();
        } catch (Exception e) {
            LOGGER.severe("Failed to create student user: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void createDefaultAdmin() {
        HashMap<String, String> additionalInfo = new HashMap<>();
        additionalInfo.put("departmentId", "1");
        
        LOGGER.info("Creating admin user: admin / admin");
        
        userServiceFacade.CreateUser(
                "admin",
                "Admin User",
                "admin",
                UserRole.ADMIN,
                additionalInfo,
                "SYSTEM"
        );
    }
    
    private void createDefaultAcademicLeader() {
        HashMap<String, String> additionalInfo = new HashMap<>();
        additionalInfo.put("departmentId", "1");
        additionalInfo.put("programmeId", "1");
        
        LOGGER.info("Creating academic leader user: leader / leader123");
        
        userServiceFacade.CreateUser(
                "leader",
                "Academic Leader",
                "leader123",
                UserRole.ACADEMIC_LEADER,
                additionalInfo,
                "SYSTEM"
        );
    }
    
    private void createDefaultLecturer() {
        try {
            HashMap<String, String> additionalInfo = new HashMap<>();
            additionalInfo.put("departmentId", "1");
            
            LOGGER.info("Creating lecturer user: lecturer / lecturer123");
            
            userServiceFacade.CreateUser(
                    "lecturer",
                    "Lecturer User",
                    "lecturer123",
                    UserRole.LECTURER,
                    additionalInfo,
                    "SYSTEM"
            );
            
            // Verify lecturer was created
            var lecturerOpt = userFacade.findByUsername("lecturer");
            if (lecturerOpt.isPresent()) {
                var lecturer = lecturerOpt.get();
                LOGGER.info("✓ Lecturer user created successfully. Username: " + lecturer.getUsername() + ", Role: " + lecturer.getRole());
            } else {
                LOGGER.warning("✗ Lecturer user creation may have failed - user not found after creation");
            }
        } catch (Exception e) {
            LOGGER.severe("Error creating lecturer user: " + e.getMessage());
            throw e;
        }
    }
    
    private void createDefaultStudent() {
        HashMap<String, String> additionalInfo = new HashMap<>();
        additionalInfo.put("programmeId", "1");
        
        LOGGER.info("Creating student user: student / student123");
        
        userServiceFacade.CreateUser(
                "student",
                "Student User",
                "student123",
                UserRole.STUDENT,
                additionalInfo,
                "SYSTEM"
        );
    }
    
}
