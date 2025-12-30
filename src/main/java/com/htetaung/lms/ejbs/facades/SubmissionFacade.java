package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.assessments.Submission;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class SubmissionFacade extends AbstractFacade<Submission> {

    @PersistenceContext
    private EntityManager em;

    public SubmissionFacade() {
        super(Submission.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<Submission> findByStudentId(Long studentId) {
        return em.createQuery(
                "SELECT s FROM Submission s " +
                "LEFT JOIN FETCH s.feedback " +
                "LEFT JOIN FETCH s.submittedBy " +
                "LEFT JOIN FETCH s.assessment " +
                "WHERE s.submittedBy.userId = :studentId",
                Submission.class)
                .setParameter("studentId", studentId)
                .getResultList();
    }

    public Submission findByStudentAndAssessment(Long studentId, Long assessmentId) {
        List<Submission> results = em.createQuery(
                "SELECT s FROM Submission s " +
                "LEFT JOIN FETCH s.feedback " +
                "LEFT JOIN FETCH s.submittedBy " +
                "LEFT JOIN FETCH s.assessment " +
                "WHERE s.submittedBy.userId = :studentId AND s.assessment.assessmentId = :assessmentId",
                Submission.class)
                .setParameter("studentId", studentId)
                .setParameter("assessmentId", assessmentId)
                .getResultList();

        return results.isEmpty() ? null : results.get(0);
    }

    public List<Submission> findByAssessmentId(Long assessmentId) {
        return em.createQuery(
                "SELECT s FROM Submission s " +
                "LEFT JOIN FETCH s.feedback " +
                "LEFT JOIN FETCH s.submittedBy " +
                "LEFT JOIN FETCH s.assessment " +
                "WHERE s.assessment.assessmentId = :assessmentId",
                Submission.class)
                .setParameter("assessmentId", assessmentId)
                .getResultList();
    }

    public boolean submissionExists(Long submissionId) {
        return find(submissionId) != null;
    }
}
