package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.QuizAnswer;
import com.htetaung.lms.models.User;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.List;

@Stateless
public class QuizAnswerFacade extends AbstractFacade<QuizAnswer> {

    @PersistenceContext
    private EntityManager em;

    public QuizAnswerFacade() {
        super(QuizAnswer.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<QuizAnswer> findByAssessmentAndStudent(Long assessmentId, Long studentId) {
        TypedQuery<QuizAnswer> query = em.createQuery(
                "SELECT a FROM QuizAnswer a WHERE a.question.assessment.id = :assessmentId AND a.student.userId = :studentId", 
                QuizAnswer.class);
        query.setParameter("assessmentId", assessmentId);
        query.setParameter("studentId", studentId);
        return query.getResultList();
    }

    public boolean hasStudentAnsweredQuiz(Long assessmentId, Long studentId) {
        TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(a) FROM QuizAnswer a WHERE a.question.assessment.id = :assessmentId AND a.student.userId = :studentId", 
                Long.class);
        query.setParameter("assessmentId", assessmentId);
        query.setParameter("studentId", studentId);
        return query.getSingleResult() > 0;
    }
}

