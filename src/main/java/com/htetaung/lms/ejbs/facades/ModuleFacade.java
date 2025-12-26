package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Module;
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
public class ModuleFacade extends AbstractFacade<Module>{

    @PersistenceContext
    private EntityManager em;

    public static final int PAGE_SIZE = 20;

    public ModuleFacade() {
        super(Module.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<Module> listAllModules(int page){
        return em.createQuery("SELECT m FROM Module m", Module.class)
                .setFirstResult((page - 1) * PAGE_SIZE)
                .setMaxResults(PAGE_SIZE)
                .getResultList();
    }

    public List<Module> listAllModulesUnderAcademicLeader(Long academicLeaderId, int page){
        return em.createQuery("SELECT m FROM Module m WHERE m.createdBy.userId = :academicLeaderId", Module.class)
                .setParameter("academicLeaderId", academicLeaderId)
                .setFirstResult((page - 1) * PAGE_SIZE)
                .setMaxResults(PAGE_SIZE)
                .getResultList();
    }

    public List<Module> listAllModulesUnderLecturer(Long lecturerId, int page){
        return em.createQuery("SELECT m FROM Module m WHERE m.managedBy.userId = :lecturerId", Module.class)
                .setParameter("lecturerId", lecturerId)
                .setFirstResult((page - 1) * PAGE_SIZE)
                .setMaxResults(PAGE_SIZE)
                .getResultList();
    }

    public boolean moduleExists(Long moduleId){
        Module m = find(moduleId);
        return m != null;
    }
}
