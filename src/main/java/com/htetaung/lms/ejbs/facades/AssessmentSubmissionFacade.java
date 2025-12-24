package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.AssessmentSubmission;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.List;

@Stateless
public class AssessmentSubmissionFacade extends AbstractFacade<AssessmentSubmission> {

    @PersistenceContext
    private EntityManager em;

    public AssessmentSubmissionFacade() {
        super(AssessmentSubmission.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public AssessmentSubmission findByAssessmentAndStudent(Long assessmentId, Long studentId) {
        TypedQuery<AssessmentSubmission> query = em.createQuery(
                "SELECT s FROM AssessmentSubmission s WHERE s.assessment.id = :assessmentId AND s.student.userId = :studentId", 
                AssessmentSubmission.class);
        query.setParameter("assessmentId", assessmentId);
        query.setParameter("studentId", studentId);
        try {
            return query.getSingleResult();
        } catch (jakarta.persistence.NoResultException e) {
            return null;
        }
    }

    public List<AssessmentSubmission> findByAssessmentId(Long assessmentId) {
        TypedQuery<AssessmentSubmission> query = em.createQuery(
                "SELECT s FROM AssessmentSubmission s WHERE s.assessment.id = :assessmentId ORDER BY s.submittedAt DESC", 
                AssessmentSubmission.class);
        query.setParameter("assessmentId", assessmentId);
        return query.getResultList();
    }

    public List<AssessmentSubmission> findByStudentId(Long studentId) {
        TypedQuery<AssessmentSubmission> query = em.createQuery(
                "SELECT s FROM AssessmentSubmission s WHERE s.student.userId = :studentId ORDER BY s.submittedAt DESC", 
                AssessmentSubmission.class);
        query.setParameter("studentId", studentId);
        return query.getResultList();
    }
}

