package com.htetaung.lms.dao.impl;

import com.htetaung.lms.dao.AcademicLeaderDao;
import com.htetaung.lms.entity.AcademicLeader;
import jakarta.ejb.Stateless;
import jakarta.persistence.*;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;

@Stateless
public class AcademicLeaderDaoImpl implements AcademicLeaderDao {

    @PersistenceContext
    private EntityManager em;

    @Override
    public AcademicLeader save(AcademicLeader academicLeader) {
        if (academicLeader.getId() == null) {
            em.persist(academicLeader);
        } else {
            academicLeader = em.merge(academicLeader);
        }
        return academicLeader;
    }

    @Override
    public Optional<AcademicLeader> findByUserId(Long id) {
        AcademicLeader academicLeader = em.find(AcademicLeader.class, id);
        return Optional.ofNullable(academicLeader);
    }

    @Override
    public List<AcademicLeader> findByDepartmentId(Long departmentId) {
        TypedQuery<AcademicLeader> query = em.createQuery(
                "SELECT al FROM AcademicLeader al WHERE al.department = :departmentId", AcademicLeader.class);
        query.setParameter("departmentId", departmentId);
        return query.getResultList();
    }

    @Override
    public List<AcademicLeader> findAll() {
        TypedQuery<AcademicLeader> query = em.createQuery("SELECT al FROM AcademicLeader al", AcademicLeader.class);
        return query.getResultList();
    }

    @Override
    public void delete(AcademicLeader academicLeader) {
        em.remove(em.contains(academicLeader) ? academicLeader : em.merge(academicLeader));
    }
}
