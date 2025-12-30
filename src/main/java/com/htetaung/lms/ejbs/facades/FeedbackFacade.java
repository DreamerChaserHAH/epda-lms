package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.assessments.Feedback;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Stateless
public class FeedbackFacade extends AbstractFacade<Feedback> {

    @PersistenceContext
    private EntityManager em;

    public FeedbackFacade() {
        super(Feedback.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }
}

