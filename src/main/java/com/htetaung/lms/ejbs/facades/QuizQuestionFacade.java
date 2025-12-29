package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.QuizQuestion;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.List;

@Stateless
public class QuizQuestionFacade extends AbstractFacade<QuizQuestion> {

    @PersistenceContext
    private EntityManager em;

    public QuizQuestionFacade() {
        super(QuizQuestion.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<QuizQuestion> findByAssessmentId(Long assessmentId) {
        TypedQuery<QuizQuestion> query = em.createQuery(
                "SELECT q FROM QuizQuestion q WHERE q.assessment.id = :assessmentId ORDER BY q.id ASC", 
                QuizQuestion.class);
        query.setParameter("assessmentId", assessmentId);
        return query.getResultList();
    }
}

