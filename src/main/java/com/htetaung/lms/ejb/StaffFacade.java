package com.htetaung.lms.ejb;

import com.htetaung.lms.dao.StaffDao;
import com.htetaung.lms.entity.Staff;
import com.htetaung.lms.entity.User;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import java.util.List;
import java.util.Optional;

@Stateless
public class StaffFacade {

    @EJB
    private StaffDao staffDao;

    @EJB
    private UserFacade userFacade;

    public Staff getStaffByStaffNumber(String staffNumber) {
        return staffDao.findById(staffNumber)
                .orElseThrow(() -> new IllegalArgumentException("Staff not found"));
    }

    public Staff getStaffByUserId(Long userId) {
        return staffDao.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Staff not found for user"));
    }

    public List<Staff> getAllStaff() {
        return staffDao.findAll();
    }

    public List<Staff> getStaffByDepartment(Long departmentId) {
        return staffDao.findByDepartment(departmentId);
    }

    public Staff updateStaffDepartment(String staffNumber, Long newDepartmentId) {
        Staff staff = getStaffByStaffNumber(staffNumber);
        staff.setDepartment(newDepartmentId);
        staffDao.update(staff);
        return staff;
    }

    public Staff updateStaffDepartment(Long userId, Long newDepartmentId) {
        Staff staff = getStaffByUserId(userId);
        staff.setDepartment(newDepartmentId);
        staffDao.update(staff);
        return staff;
    }

    public void deleteStaff(String staffNumber) {
        if (!staffDao.findById(staffNumber).isPresent()) {
            throw new IllegalArgumentException("Staff not found");
        }
        staffDao.delete(staffNumber);
    }

    public void deleteStaff(Long userId) {
        Staff staff = getStaffByUserId(userId);
        staffDao.delete(staff.getStaffNumber());
    }

    public boolean isStaffNumberAvailable(String staffNumber) {
        return !staffDao.existsByStaffNumber(staffNumber);
    }
}
