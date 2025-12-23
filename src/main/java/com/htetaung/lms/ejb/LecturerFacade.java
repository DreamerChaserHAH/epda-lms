package com.htetaung.lms.ejb;

import com.htetaung.lms.dao.LecturerDao;
import com.htetaung.lms.dao.UserDao;
import com.htetaung.lms.entity.Admin;
import com.htetaung.lms.entity.Lecturer;
import com.htetaung.lms.entity.User;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import java.util.List;
import java.util.Optional;

@Stateless
public class LecturerFacade {

    @EJB
    private LecturerDao lecturerDao;
    @EJB
    private UserDao userDao;

    public Lecturer registerLecturer(String username, String fullName, String passwordHash,
                                     Optional<User> createdBy) {
        if (userDao.existsByUsername(username)) {
            throw new IllegalArgumentException("Username already exists");
        }

        Lecturer lecturer = new Lecturer(
                username,
                fullName,
                passwordHash,
                createdBy,
                0L,
                null
        );
        lecturerDao.save(lecturer);
        return lecturer;
    }

    public Lecturer getLecturerByUserId(Long userId) {
        return lecturerDao.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Lecturer not found for userId " + userId));
    }

    public Lecturer getLecturerByLecturerNumber(Long id) {
        return lecturerDao.findByUserId(id)
                .orElseThrow(() -> new IllegalArgumentException("Lecturer not found for userId " + id));
    }

    public List<Lecturer> getAllLecturers() {
        return lecturerDao.findAll();
    }

    public void deleteLecturer(Long userId) {
        if (lecturerDao.findByUserId(userId).isEmpty()) {
            throw new IllegalArgumentException("Lecturer not found");
        }
        userDao.delete(userId);
    }
}
