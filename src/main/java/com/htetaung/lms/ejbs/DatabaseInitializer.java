package com.htetaung.lms.ejbs;

import com.htetaung.lms.ejbs.services.UserServiceFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;

import com.htetaung.lms.models.Admin;
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
                LOGGER.info("No users found. Creating default admin user...");
                createDefaultAdmin();
                LOGGER.info("Default admin user created successfully.");
            } else {
                LOGGER.info("Database already contains users. Skipping initialization.");
            }
        } catch (Exception e) {
            LOGGER.severe("Failed to initialize database: " + e.getMessage());
        }
    }

    private void createDefaultAdmin() {
        HashMap<String, String> additionalInfo = new HashMap<String, String>();
        additionalInfo.put("departmentId", "1");
        userServiceFacade.CreateUser(
                "admin",
                "admin",
                "admin",
                UserRole.ADMIN,
                additionalInfo,
                "SYSTEM"
        );
    }
}
