package com.htetaung.lms.dao.impl;

import com.htetaung.lms.dao.StudentDao;
import com.htetaung.lms.entity.Student;
import jakarta.ejb.Stateless;
import jakarta.persistence.*;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;

@Stateless
public class StudentDaoImpl implements StudentDao {

    @PersistenceContext
    private EntityManager em;

    @Override
    public Student save(Student student) {
        if (student.getId() == null) {
            em.persist(student);
        } else {
            student = em.merge(student);
        }
        return student;
    }

    @Override
    public Optional<Student> findByUserId(Long id) {
        Student student = em.find(Student.class, id);
        return Optional.ofNullable(student);
    }

    @Override
    public Optional<Student> findByStudentNumber(String studentNumber) {
        try {
            TypedQuery<Student> query = em.createQuery(
                    "SELECT s FROM Student s WHERE s.studentId = :studentNumber", Student.class);
            query.setParameter("studentNumber", studentNumber);
            return Optional.ofNullable(query.getSingleResult());
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    @Override
    public Optional<Student> findByStudentId(String studentId) {
        try {
            TypedQuery<Student> query = em.createQuery(
                    "SELECT s FROM Student s WHERE s.studentId = :studentId", Student.class);
            query.setParameter("studentId", studentId);
            return Optional.ofNullable(query.getSingleResult());
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    @Override
    public void update(Student student) {
        em.merge(student);
    }

    @Override
    public Optional<Student> findLastStudent() {
        TypedQuery<Student> query = em.createQuery(
                "SELECT s FROM Student s ORDER BY s.studentId DESC", Student.class);
        query.setMaxResults(1);
        List<Student> results = query.getResultList();
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    @Override
    public List<Student> findByProgrammeId(Long programmeId) {
        TypedQuery<Student> query = em.createQuery(
                "SELECT s FROM Student s WHERE s.programmeId = :programmeId", Student.class);
        query.setParameter("programmeId", programmeId);
        return query.getResultList();
    }

    @Override
    public List<Student> findAll() {
        TypedQuery<Student> query = em.createQuery("SELECT s FROM Student s", Student.class);
        return query.getResultList();
    }

    @Override
    public void delete(Student student) {
        em.remove(em.contains(student) ? student : em.merge(student));
    }
}
