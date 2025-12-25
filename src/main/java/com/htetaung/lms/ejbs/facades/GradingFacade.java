package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.ejbs.facades.AbstractFacade;
import com.htetaung.lms.models.Grading;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.List;
import java.util.Optional;

@Stateless
public class GradingFacade extends AbstractFacade<Grading> {

    @PersistenceContext
    private EntityManager em;

    public GradingFacade() {
        super(Grading.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public Optional<Grading> findByGradeSymbol(String gradeSymbol) {
        TypedQuery<Grading> query = em.createQuery(
                "SELECT g FROM Grading g WHERE g.gradeSymbol = :gradeSymbol", Grading.class);
        query.setParameter("gradeSymbol", gradeSymbol);
        return Optional.ofNullable(query.getResultStream().findFirst().orElse(null));
    }

    public Optional<Grading> findByScore(int score) {
        TypedQuery<Grading> query = em.createQuery(
                "SELECT g FROM Grading g WHERE :score BETWEEN g.minScore AND g.maxScore", Grading.class);
        query.setParameter("score", score);
        return Optional.ofNullable(query.getResultStream().findFirst().orElse(null));
    }

    public List<Grading> findAllGradings() {
        TypedQuery<Grading> query = em.createQuery(
                "SELECT g FROM Grading g ORDER BY g.minScore DESC", Grading.class);
        return query.getResultList();
    }
}