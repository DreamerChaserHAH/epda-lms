package com.htetaung.lms.dao.impl;

import com.htetaung.lms.dao.StaffDao;
import com.htetaung.lms.entity.Staff;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import java.util.List;
import java.util.Optional;

@Stateless
public class StaffDaoImpl implements StaffDao {

    @PersistenceContext
    private EntityManager em;

    @Override
    public void save(Staff staff) {
        em.persist(staff);
    }

    @Override
    public Optional<Staff> findById(String staffNumber) {
        Staff staff = em.find(Staff.class, staffNumber);
        return Optional.ofNullable(staff);
    }

    @Override
    public Optional<Staff> findByUserId(Long userId) {
        try {
            TypedQuery<Staff> query = em.createQuery(
                    "SELECT s FROM Staff s WHERE s.userId = :userId", Staff.class);
            query.setParameter("userId", userId);
            return Optional.of(query.getSingleResult());
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    @Override
    public List<Staff> findAll() {
        return em.createQuery("SELECT s FROM Staff s", Staff.class)
                .getResultList();
    }

    @Override
    public List<Staff> findByDepartment(Long departmentId) {
        TypedQuery<Staff> query = em.createQuery(
                "SELECT s FROM Staff s WHERE s.department = :departmentId", Staff.class);
        query.setParameter("departmentId", departmentId);
        return query.getResultList();
    }

    @Override
    public void update(Staff staff) {
        em.merge(staff);
    }

    @Override
    public void delete(String staffNumber) {
        Staff staff = em.find(Staff.class, staffNumber);
        if (staff != null) {
            em.remove(staff);
        }
    }

    @Override
    public boolean existsByStaffNumber(String staffNumber) {
        TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(s) FROM Staff s WHERE s.staffNumber = :staffNumber", Long.class);
        query.setParameter("staffNumber", staffNumber);
        return query.getSingleResult() > 0;
    }
}
