package com.htetaung.lms.dao;

import com.htetaung.lms.entity.Staff;
import java.util.List;
import java.util.Optional;

public interface StaffDao {
    void save(Staff staff);
    Optional<Staff> findById(String staffNumber);
    Optional<Staff> findByUserId(Long userId);
    List<Staff> findAll();
    List<Staff> findByDepartment(Long departmentId);
    void update(Staff staff);
    void delete(String staffNumber);
    boolean existsByStaffNumber(String staffNumber);
}
