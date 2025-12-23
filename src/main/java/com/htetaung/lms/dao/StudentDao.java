package com.htetaung.lms.dao;

import com.htetaung.lms.entity.Student;
import java.util.List;
import java.util.Optional;

public interface StudentDao {
    Student save(Student student);
    Optional<Student> findByUserId(Long id);
    Optional<Student> findByStudentNumber(String StudentNumber);
    Optional<Student> findByStudentId(String studentId);
    Optional<Student> findLastStudent();
    void update(Student student);
    List<Student> findByProgrammeId(Long programmeId);
    List<Student> findAll();
    void delete(Student student);
}
