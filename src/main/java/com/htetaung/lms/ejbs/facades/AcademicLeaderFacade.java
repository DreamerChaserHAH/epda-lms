package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.AcademicLeader;
import com.htetaung.lms.exception.AuthenticationException;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.List;

@Stateless
public class AcademicLeaderFacade extends AbstractFacade<AcademicLeader>{

    @PersistenceContext
    private EntityManager em;

    public static final int PAGE_SIZE = 10;

    public AcademicLeaderFacade() {
        super(AcademicLeader.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<AcademicLeader> getAllAcademicLeaders() {
        return em.createQuery("SELECT a FROM AcademicLeader a", AcademicLeader.class)
                 .getResultList();
    }
}
