package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.ClassEnrollment;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.List;

@Stateless
public class ClassEnrollmentFacade extends AbstractFacade<ClassEnrollment> {

    @PersistenceContext
    private EntityManager em;

    public ClassEnrollmentFacade() {
        super(ClassEnrollment.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<ClassEnrollment> findByStudentId(Long studentId) {
        TypedQuery<ClassEnrollment> query = em.createQuery(
                "SELECT e FROM ClassEnrollment e WHERE e.student.userId = :studentId AND e.isActive = true", 
                ClassEnrollment.class);
        query.setParameter("studentId", studentId);
        return query.getResultList();
    }

    public List<ClassEnrollment> findByClassId(Long classId) {
        TypedQuery<ClassEnrollment> query = em.createQuery(
                "SELECT e FROM ClassEnrollment e WHERE e.classEntity.id = :classId AND e.isActive = true ORDER BY e.student.fullName ASC", 
                ClassEnrollment.class);
        query.setParameter("classId", classId);
        return query.getResultList();
    }

    public ClassEnrollment findByClassAndStudent(Long classId, Long studentId) {
        TypedQuery<ClassEnrollment> query = em.createQuery(
                "SELECT e FROM ClassEnrollment e WHERE e.classEntity.id = :classId AND e.student.userId = :studentId", 
                ClassEnrollment.class);
        query.setParameter("classId", classId);
        query.setParameter("studentId", studentId);
        try {
            return query.getSingleResult();
        } catch (jakarta.persistence.NoResultException e) {
            return null;
        }
    }
}

