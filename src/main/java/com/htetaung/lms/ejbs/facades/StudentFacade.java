package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Student;
import com.htetaung.lms.exception.AuthenticationException;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

@Stateless
public class StudentFacade extends AbstractFacade<Student>{

    @PersistenceContext
    private EntityManager em;

    @EJB
    private UserFacade userFacade;

    public static final int PAGE_SIZE = 10;

    public StudentFacade() {
        super(Student.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }
}
