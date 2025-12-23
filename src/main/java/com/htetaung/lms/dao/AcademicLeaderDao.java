package com.htetaung.lms.dao;

import com.htetaung.lms.entity.AcademicLeader;
import java.util.List;
import java.util.Optional;

public interface AcademicLeaderDao {
    AcademicLeader save(AcademicLeader academicLeader);
    Optional<AcademicLeader> findByUserId(Long id);
    List<AcademicLeader> findByDepartmentId(Long departmentId);
    List<AcademicLeader> findAll();
    void delete(AcademicLeader academicLeader);
}
