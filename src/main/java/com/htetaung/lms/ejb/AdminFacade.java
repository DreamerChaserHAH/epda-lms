package com.htetaung.lms.ejb;

import com.htetaung.lms.dao.AdminDao;
import com.htetaung.lms.dao.UserDao;
import com.htetaung.lms.entity.Admin;
import com.htetaung.lms.entity.User;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;

import java.util.List;
import java.util.Optional;

@Stateless
public class AdminFacade {

    @EJB
    private AdminDao adminDao;
    @EJB
    private UserDao userDao;

    public Admin registerAdmin(String username, String fullName, String passwordHash,
                               Optional<User> createdBy, Long department) {

        if (userDao.existsByUsername(username)) {
            throw new IllegalArgumentException("Username already exists");
        }
        Admin admin = new Admin(username, fullName, passwordHash, createdBy, department);
        adminDao.save(admin);
        return admin;
    }

    public Admin getAdminByUserId(Long userId) {
        return adminDao.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Admin not found for userId " + userId));
    }

    public List<Admin> getAllAdmins() {
        return adminDao.findAll();
    }

    public List<Admin> getAdminsByDepartment(Long departmentId) {
        return adminDao.findByDepartment(departmentId);
    }

    public Admin updateAdminDepartment(Long userId, Long newDepartmentId) {
        Admin admin = getAdminByUserId(userId);
        admin.setDepartment(newDepartmentId);
        adminDao.update(admin);
        return admin;
    }

    public void deleteAdmin(Long userId) {
        if (!adminDao.findByUserId(userId).isPresent()) {
            throw new IllegalArgumentException("Admin not found");
        }
        adminDao.delete(userId);
    }
}
