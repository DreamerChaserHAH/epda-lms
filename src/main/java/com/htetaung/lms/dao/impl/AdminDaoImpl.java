package com.htetaung.lms.dao.impl;

import com.htetaung.lms.dao.AdminDao;
import com.htetaung.lms.entity.Admin;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;

@Stateless
public class AdminDaoImpl implements AdminDao {

    @PersistenceContext
    private EntityManager em;

    @Override
    public void save(Admin admin) {
        em.persist(admin);
    }

    @Override
    public Optional<Admin> findByUserId(Long userId) {
        try {
            TypedQuery<Admin> query = em.createQuery(
                    "SELECT a FROM Admin a WHERE a.userId = :userId", Admin.class);
            query.setParameter("userId", userId);
            return Optional.of(query.getSingleResult());
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    @Override
    public List<Admin> findAll() {
        return em.createQuery("SELECT a FROM Admin a", Admin.class)
                .getResultList();
    }

    @Override
    public List<Admin> findByDepartment(Long departmentId) {
        TypedQuery<Admin> query = em.createQuery(
                "SELECT a FROM Admin a WHERE a.department = :departmentId", Admin.class);
        query.setParameter("departmentId", departmentId);
        return query.getResultList();
    }

    @Override
    public void update(Admin admin) {
        em.merge(admin);
    }

    @Override
    public void delete(Long id) {
        Admin admin = em.find(Admin.class, id);
        if (admin != null) {
            em.remove(admin);
        }
    }
}
