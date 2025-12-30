package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.assessments.Quiz;
import com.htetaung.lms.models.dto.QuizDTO;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class QuizFacade extends AbstractFacade<Quiz> {

    @PersistenceContext
    private EntityManager em;

    public static final int PAGE_SIZE = 10;

    public QuizFacade() {
        super(Quiz.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public QuizDTO findAssessmentById(Long assessmentId) {
        Quiz quiz = find(assessmentId);
        if (quiz != null) {
            return new QuizDTO(quiz);
        }
        return null;
    }

    public List<QuizDTO> findQuizzesInClass(Long classId) {
        List<Quiz> quizzes = em.createQuery("SELECT q FROM Quiz q WHERE q.relatedClass.classId = :classId", Quiz.class)
                .setParameter("classId", classId)
                .getResultList();
        return quizzes.stream().map(QuizDTO::new).toList();
    }

    public List<QuizDTO> findQuizzesByVisibility(Long classId, String visibility) {
        List<Quiz> quizzes = em.createQuery("SELECT q FROM Quiz q WHERE q.relatedClass.classId = :classId AND q.visibility = :visibility", Quiz.class)
                .setParameter("classId", classId)
                .setParameter("visibility", visibility)
                .getResultList();
        return quizzes.stream().map(QuizDTO::new).toList();
    }

    public boolean quizExists(Long quizId) {
        Quiz quiz = find(quizId);
        return quiz != null;
    }

    public Quiz updateQuiz(QuizDTO quizDTO) {
        return em.merge(quizDTO.toQuiz());
    }

    public void deleteQuiz(Long quizId) {
        Quiz quiz = find(quizId);
        if (quiz != null) {
            em.remove(quiz);
        }
    }
}