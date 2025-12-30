package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.assessments.FileSubmitted;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Stateless
public class FileSubmittedFacade extends AbstractFacade<FileSubmitted> {

    @PersistenceContext
    private EntityManager em;

    public FileSubmittedFacade() {
        super(FileSubmitted.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }
}

