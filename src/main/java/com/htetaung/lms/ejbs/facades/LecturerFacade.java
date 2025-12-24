package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Lecturer;
import com.htetaung.lms.exception.AuthenticationException;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

@Stateless
public class LecturerFacade extends AbstractFacade<Lecturer>{

    @PersistenceContext
    private EntityManager em;

    public static final int PAGE_SIZE = 10;

    public LecturerFacade() {
        super(Lecturer.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }
}
