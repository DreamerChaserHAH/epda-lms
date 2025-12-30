package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Class;
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
import java.util.List;

@Stateless
public class ClassFacade extends AbstractFacade<Class>{

    @PersistenceContext
    private EntityManager em;

    public static final int PAGE_SIZE = 10;

    public ClassFacade() {
        super(Class.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public boolean classExists(Long classId){
        Class classInQuestion = find(classId);
        return classInQuestion != null;
    }

    public List<Class> listAllClassesUnderModule(Long moduleId){
        return em.createQuery("SELECT c FROM Class c WHERE c.module.moduleId = :moduleId", Class.class)
                .setParameter("moduleId", moduleId)
                .getResultList();
    }

    public List<Class> listAllClassesUnderStudent(Long studentId){
        return em.createQuery("SELECT c FROM Class c JOIN c.enrolledStudents s WHERE s.userId = :studentId", Class.class)
                .setParameter("studentId", studentId)
                .getResultList();
    }
}
