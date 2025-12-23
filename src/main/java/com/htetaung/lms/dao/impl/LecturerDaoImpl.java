package com.htetaung.lms.dao.impl;

import com.htetaung.lms.dao.LecturerDao;
import com.htetaung.lms.entity.Lecturer;
import jakarta.ejb.Stateless;
import jakarta.persistence.*;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;

@Stateless
public class LecturerDaoImpl implements LecturerDao {

    @PersistenceContext
    private EntityManager em;

    @Override
    public Lecturer save(Lecturer lecturer) {
        if (lecturer.getId() == null) {
            em.persist(lecturer);
        } else {
            lecturer = em.merge(lecturer);
        }
        return lecturer;
    }

    @Override
    public Optional<Lecturer> findByUserId(Long id) {
        Lecturer lecturer = em.find(Lecturer.class, id);
        return Optional.ofNullable(lecturer);
    }

    @Override
    public List<Lecturer> findByDepartmentId(Long departmentId) {
        TypedQuery<Lecturer> query = em.createQuery(
                "SELECT l FROM Lecturer l WHERE l.department = :departmentId", Lecturer.class);
        query.setParameter("departmentId", departmentId);
        return query.getResultList();
    }

    @Override
    public List<Lecturer> findAll() {
        TypedQuery<Lecturer> query = em.createQuery("SELECT l FROM Lecturer l", Lecturer.class);
        return query.getResultList();
    }

    @Override
    public void delete(Lecturer lecturer) {
        em.remove(em.contains(lecturer) ? lecturer : em.merge(lecturer));
    }
}
