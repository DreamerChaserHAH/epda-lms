package com.htetaung.lms.dao;

import com.htetaung.lms.entity.Lecturer;
import java.util.List;
import java.util.Optional;

public interface LecturerDao {
    Lecturer save(Lecturer lecturer);
    Optional<Lecturer> findByUserId(Long id);
    List<Lecturer> findByDepartmentId(Long departmentId);
    List<Lecturer> findAll();
    void delete(Lecturer lecturer);
}
