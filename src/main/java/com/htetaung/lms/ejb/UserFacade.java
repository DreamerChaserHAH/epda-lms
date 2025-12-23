package com.htetaung.lms.ejb;

import com.htetaung.lms.dao.UserDao;
import com.htetaung.lms.entity.User;
import com.htetaung.lms.exception.AuthenticationException;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import jakarta.inject.Inject;

@Stateless
public class UserFacade {

    @EJB
    private UserDao userDao;

    // Authentication (Business Logic)
    public User authenticateUser(String username, String password, User.Role role) throws AuthenticationException {
        User user = userDao.findByUsername(username)
                .orElseThrow(() -> new AuthenticationException("Invalid username or password"));

        String hashedPassword = hashPassword(password);
        if (!user.getPasswordHash().equals(hashedPassword)) {
            throw new AuthenticationException("Invalid username or password");
        }

        if (user.getRole() != role) {
            throw new AuthenticationException("User does not have the required role");
        }

        return user;
    }

    // Profile Management (Business Logic)
    public User updateProfile(Long userId, String fullName) {
        User user = userDao.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        user.setFullName(fullName);
        userDao.update(user);
        return user;
    }

    public User changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userDao.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (!user.getPasswordHash().equals(hashPassword(oldPassword))) {
            throw new IllegalArgumentException("Current password is incorrect");
        }

        user.setPasswordHash(hashPassword(newPassword));
        userDao.update(user);
        return user;
    }

    // User Lookup
    public User getUserById(Long id) {
        return userDao.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
    }

    public User getUserByUsername(String username) {
        return userDao.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
    }

    // Validation (Business Logic)
    public boolean isUsernameAvailable(String username) {
        return !userDao.existsByUsername(username);
    }

    public boolean isValidCredentials(String username, String password) {
        return userDao.findByUsername(username)
                .map(user -> user.getPasswordHash().equals(hashPassword(password)))
                .orElse(false);
    }

    // User Management
    public void deleteUser(Long userId) {
        if (!userDao.findById(userId).isPresent()) {
            throw new IllegalArgumentException("User not found");
        }
        userDao.delete(userId);
    }

    // Security utility (stays in facade)
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Password hashing failed", e);
        }
    }
}
