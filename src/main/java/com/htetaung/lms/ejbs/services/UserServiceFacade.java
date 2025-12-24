package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.*;
import com.htetaung.lms.exception.AuthenticationException;
import com.htetaung.lms.models.User;
import com.htetaung.lms.models.dto.UserDTO;
import com.htetaung.lms.models.enums.UserRole;
import com.htetaung.lms.models.Student;
import com.htetaung.lms.models.Lecturer;
import com.htetaung.lms.models.AcademicLeader;
import com.htetaung.lms.models.Admin;

import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.List;
import java.util.Map;


@Stateless
public class UserServiceFacade {

    @EJB
    private AdminFacade adminFacade;

    @EJB
    private AcademicLeaderFacade academicLeaderFacade;

    @EJB
    private LecturerFacade lecturerFacade;

    @EJB
    private StudentFacade studentFacade;

    @EJB
    private UserFacade userFacade;

    public void CreateUser(String username, String fullname, String password, UserRole role, Map<String, String> additionalInfo, String operatorUsername) throws IllegalArgumentException{

        if(!userFacade.isUsernameAvailable(username)){
            throw new IllegalArgumentException("Username already exists");
        }

        String hashedPassword = hashPassword(password);

        User newUser = new User();
        newUser.setUsername(username);
        newUser.setPasswordHash(hashedPassword);
        newUser.setFullName(fullname);
        newUser.setCreatedBy(null);
        newUser.setRole(role);

        switch (role){
            case STUDENT -> {
                Long programmeId = Long.valueOf(additionalInfo.get("programmeId"));

                Student newStudent = new Student(newUser, programmeId);
                studentFacade.create(newStudent, operatorUsername);
            }
            case ACADEMIC_LEADER -> {
                Long departmentId = Long.valueOf(additionalInfo.get("departmentId"));
                Long programmeId = Long.valueOf(additionalInfo.get("programmeId"));

                AcademicLeader academicLeader = new AcademicLeader(newUser, departmentId, programmeId);
                academicLeaderFacade.create(academicLeader, operatorUsername);
            }
            case LECTURER -> {
                Long departmentId = Long.valueOf(additionalInfo.get("departmentId"));

                Lecturer lecturer = new Lecturer(newUser, departmentId, null);
                lecturerFacade.create(lecturer, operatorUsername);
            }
            case ADMIN -> {
                Long departmentId = Long.valueOf(additionalInfo.get("departmentId"));
                Admin admin = new Admin(newUser, departmentId);

                adminFacade.create(admin, operatorUsername);
            }
            default -> throw new IllegalArgumentException("Invalid user role");
        }
    }

    public User authenticateUser(String username, String password, UserRole role) throws AuthenticationException {
        User user = userFacade.findByUsername(username)
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

    public void DeleteUser(Long userId, String operatorUsername){
        User userToDelete = userFacade.find(userId);
        userFacade.remove(userToDelete, operatorUsername);
    }

    public void DeleteUserByUsername(String username, String operatorUsername) throws IllegalArgumentException{
        User userToDelete = userFacade.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        userFacade.remove(userToDelete, operatorUsername);
    }

    public List<UserDTO> getUsers(int page){
        return userFacade.findAllUsers(page).stream()
                .map(user -> new UserDTO(
                        user.getUserId(),
                        user.getUsername(),
                        user.getFullName(),
                        user.getRole(),
                        user.getCreatedAt()
                ))
                .toList();
    }

    public List<UserDTO> searchUsersByFullName(String fullname, int page){
        return userFacade.searchByFullName(fullname, page).stream()
                .map(user -> new UserDTO(
                        user.getUserId(),
                        user.getUsername(),
                        user.getFullName(),
                        user.getRole(),
                        user.getCreatedAt()
                ))
                .toList();
    }

    public List<UserDTO> searchUsersByUsername(String username, int page){
        return userFacade.searchByUsername(username, page).stream()
                .map(user -> new UserDTO(
                        user.getUserId(),
                        user.getUsername(),
                        user.getFullName(),
                        user.getRole(),
                        user.getCreatedAt()
                ))
                .toList();
    }

    public List<UserDTO> searchUsersByRole(String role_string, int page){
        UserRole role;
        try{
            role = UserRole.valueOf(role_string.toUpperCase());
        }catch (IllegalArgumentException e){
            throw new IllegalArgumentException("Invalid role for searching users");
        }

        return userFacade.findAllUsersWithRole(role, page).stream()
                .map(user -> new UserDTO(
                        user.getUserId(),
                        user.getUsername(),
                        user.getFullName(),
                        user.getRole(),
                        user.getCreatedAt()
                ))
                .toList();
    }

    public void UpdateUser(Long userId, String username, String fullName, UserRole role, String operatorUsername) throws IllegalArgumentException{
        User userToUpdate = userFacade.find(userId);

        if(!userToUpdate.getUsername().equals(username)){
            if(!userFacade.isUsernameAvailable(username)){
                throw new IllegalArgumentException("Username already exists");
            }
            userToUpdate.setUsername(username);
        }

        userToUpdate.setFullName(fullName);
        userToUpdate.setRole(role);

        userFacade.edit(userToUpdate, operatorUsername);
    }

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
