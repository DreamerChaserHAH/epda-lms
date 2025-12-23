package com.htetaung.lms.ejb;

import com.htetaung.lms.dao.StudentDao;
import com.htetaung.lms.dao.UserDao;
import com.htetaung.lms.entity.Student;
import com.htetaung.lms.entity.User;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import java.util.List;
import java.util.Optional;

@Stateless
public class StudentFacade {

    @EJB
    private StudentDao studentDao;
    @EJB
    private UserDao userDao;

    public Student registerStudent(String username, String fullName, String passwordHash,
                                   Optional<User> createdBy) {
        if (userDao.existsByUsername(username)) {
            throw new IllegalArgumentException("Username already exists");
        }

        Student student = new Student(username, fullName, passwordHash, createdBy);
        studentDao.save(student);
        return student;
    }

    public Student getStudentByUserId(Long userId) {
        return studentDao.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Student not found for userId " + userId));
    }

    public Student getStudentByStudentNumber(String studentNumber) {
        return studentDao.findByStudentNumber(studentNumber)
                .orElseThrow(() -> new IllegalArgumentException("Student not found for studentNumber " + studentNumber));
    }

    public List<Student> getAllStudents() {
        return studentDao.findAll();
    }

    public List<Student> getStudentsByProgramme(Long programme) {
        return studentDao.findByProgrammeId(programme);
    }

    public Student updateStudentProgramme(Long userId, Long newProgrammeId) {
        Student student = getStudentByUserId(userId);
        student.setProgrammeId(newProgrammeId);
        studentDao.update(student);
        return student;
    }

    public void deleteStudent(String studentNumber) {
        Optional<Student> studentOpt = studentDao.findByStudentNumber(studentNumber);
        if (studentOpt.isEmpty()) {
            throw new IllegalArgumentException("Student not found");
        }
        studentDao.delete(studentOpt.get());
    }
}
