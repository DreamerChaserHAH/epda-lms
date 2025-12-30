package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.assessments.QuizIndividualQuestion;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class QuizIndividualQuestionFacade extends AbstractFacade<QuizIndividualQuestion> {

    @PersistenceContext
    private EntityManager em;

    public QuizIndividualQuestionFacade() {
        super(QuizIndividualQuestion.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<QuizIndividualQuestion> findQuestionsByQuizId(Long quizId) {
        return em.createQuery(
                "SELECT q FROM QuizIndividualQuestion q JOIN Quiz quiz ON q MEMBER OF quiz.questions WHERE quiz.assessmentId = :quizId",
                QuizIndividualQuestion.class)
                .setParameter("quizId", quizId)
                .getResultList();
    }

    public boolean questionExists(Long questionId) {
        QuizIndividualQuestion question = find(questionId);
        return question != null;
    }

    public void deleteQuestion(Long questionId) {
        QuizIndividualQuestion question = find(questionId);
        if (question != null) {
            em.remove(question);
        }
    }
}

