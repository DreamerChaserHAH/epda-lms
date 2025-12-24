package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Staff;
import com.htetaung.lms.models.User;
import com.htetaung.lms.exception.AuthenticationException;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

@Stateless
public class StaffFacade extends AbstractFacade<Staff>{

    @PersistenceContext
    private EntityManager em;

    public static final int PAGE_SIZE = 10;

    public StaffFacade() {
        super(Staff.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }
}
