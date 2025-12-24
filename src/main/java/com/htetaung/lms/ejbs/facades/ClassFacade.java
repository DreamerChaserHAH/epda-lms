package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.ClassEntity;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.List;

@Stateless
public class ClassFacade extends AbstractFacade<ClassEntity> {

    @PersistenceContext
    private EntityManager em;

    public ClassFacade() {
        super(ClassEntity.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public ClassEntity findByClassCode(String classCode) {
        TypedQuery<ClassEntity> query = em.createQuery(
                "SELECT c FROM ClassEntity c WHERE c.classCode = :classCode", 
                ClassEntity.class);
        query.setParameter("classCode", classCode);
        try {
            return query.getSingleResult();
        } catch (jakarta.persistence.NoResultException e) {
            return null;
        }
    }

    public List<ClassEntity> findByLecturerId(Long lecturerId) {
        TypedQuery<ClassEntity> query = em.createQuery(
                "SELECT c FROM ClassEntity c WHERE c.lecturer.userId = :lecturerId AND c.isActive = true ORDER BY c.name ASC", 
                ClassEntity.class);
        query.setParameter("lecturerId", lecturerId);
        return query.getResultList();
    }
}

