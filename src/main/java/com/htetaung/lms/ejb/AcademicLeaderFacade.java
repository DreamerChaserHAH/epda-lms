package com.htetaung.lms.ejb;

import com.htetaung.lms.dao.AcademicLeaderDao;
import com.htetaung.lms.dao.UserDao;
import com.htetaung.lms.entity.AcademicLeader;
import com.htetaung.lms.entity.User;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;

import java.util.List;
import java.util.Optional;

@Stateless
public class AcademicLeaderFacade {

    @EJB
    private AcademicLeaderDao academicLeaderDao;
    @EJB
    private UserDao userDao;

    public AcademicLeader registerAcademicLeader(String username, String fullName, String passwordHash,
                                                 Optional<User> createdBy) {
        if (userDao.existsByUsername(username)) {
            throw new IllegalArgumentException("Username already exists");
        }

        AcademicLeader academicLeader = new AcademicLeader(
                username,
                fullName,
                passwordHash,
                createdBy,
                0L,
                null
        );
        academicLeaderDao.save(academicLeader);
        return academicLeader;
    }

    public AcademicLeader getAcademicLeaderByUserId(Long userId) {
        return academicLeaderDao.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Academic leader not found for userId " + userId));
    }

    public AcademicLeader getAcademicLeaderById(Long id) {
        return academicLeaderDao.findByUserId(id)
                .orElseThrow(() -> new IllegalArgumentException("Academic leader not found for userId " + id));
    }

    public List<AcademicLeader> getAllAcademicLeaders() {
        return academicLeaderDao.findAll();
    }

    public void deleteAcademicLeader(Long userId) {
        if (academicLeaderDao.findByUserId(userId).isEmpty()) {
            throw new IllegalArgumentException("Academic leader not found");
        }
        userDao.delete(userId);
    }
}
