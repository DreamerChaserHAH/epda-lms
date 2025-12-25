package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.AcademicLeader;
import com.htetaung.lms.models.Lecturer;
import com.htetaung.lms.exception.AuthenticationException;
import com.htetaung.lms.models.dto.LecturerDTO;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.List;

@Stateless
public class LecturerFacade extends AbstractFacade<Lecturer>{

    @PersistenceContext
    private EntityManager em;

    public static final int PAGE_SIZE = 10;

    public LecturerFacade() {
        super(Lecturer.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public Long countLecturersByAcademicLeaderId(Long academicLeaderId) {
        Long count = em.createQuery(
                "SELECT COUNT(l) FROM Lecturer l WHERE l.academicLeader.userId = :academicLeaderId", Long.class)
                .setParameter("academicLeaderId", academicLeaderId)
                .getSingleResult();
        return count;
    }

    public List<LecturerDTO> listAllLecturersUnderAcademicLeader(Long academicLeaderId){
        List<Lecturer> lecturers = em.createQuery(
                "SELECT l FROM Lecturer l WHERE l.academicLeader.userId = :academicLeaderId", Lecturer.class)
                .setParameter("academicLeaderId", academicLeaderId)
                .getResultList();
        return lecturers.stream().map(
                l -> new LecturerDTO(
                        l.getUserId(),
                        l.getFullName(),
                        l.getAcademicLeader() != null ? l.getAcademicLeader().getUserId() : null
                )
        ).toList();
    }

    public void updateLecturerAcademicLeader(Long lecturerId, Long academicLeaderId, String operatedBy) {
        Lecturer lecturer = find(lecturerId);
        if (lecturer == null) {
            throw new IllegalArgumentException("Lecturer not found");
        }

        if (academicLeaderId != null && academicLeaderId > 0) {
            AcademicLeader academicLeader = em.find(AcademicLeader.class, academicLeaderId);
            if (academicLeader == null) {
                throw new IllegalArgumentException("Academic Leader not found");
            }
            lecturer.setAcademicLeader(academicLeader);
        } else {
            lecturer.setAcademicLeader(null);
        }

        edit(lecturer, operatedBy);
    }
}
