package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.assessments.QuizSubmission;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class QuizSubmissionFacade extends AbstractFacade<QuizSubmission> {

    @PersistenceContext
    private EntityManager em;

    public QuizSubmissionFacade() {
        super(QuizSubmission.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<QuizSubmission> findByStudentId(Long studentId) {
        return em.createQuery(
                "SELECT q FROM QuizSubmission q WHERE q.submittedBy.userId = :studentId",
                QuizSubmission.class)
                .setParameter("studentId", studentId)
                .getResultList();
    }
}

