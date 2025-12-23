package com.htetaung.lms.dao;

import com.htetaung.lms.entity.Admin;
import java.util.List;
import java.util.Optional;

public interface AdminDao {
    void save(Admin admin);
    Optional<Admin> findByUserId(Long userId);
    List<Admin> findAll();
    List<Admin> findByDepartment(Long departmentId);
    void update(Admin admin);
    void delete(Long id);
}
