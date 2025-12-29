package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Attendance;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.Date;
import java.util.List;

@Stateless
public class AttendanceFacade extends AbstractFacade<Attendance> {

    @PersistenceContext
    private EntityManager em;

    public AttendanceFacade() {
        super(Attendance.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<Attendance> findByClassId(Long classId) {
        TypedQuery<Attendance> query = em.createQuery(
                "SELECT a FROM Attendance a WHERE a.classEntity.id = :classId ORDER BY a.attendanceDate DESC, a.student.fullName ASC", 
                Attendance.class);
        query.setParameter("classId", classId);
        return query.getResultList();
    }

    public List<Attendance> findByClassAndDate(Long classId, Date date) {
        TypedQuery<Attendance> query = em.createQuery(
                "SELECT a FROM Attendance a WHERE a.classEntity.id = :classId AND a.attendanceDate = :date ORDER BY a.student.fullName ASC", 
                Attendance.class);
        query.setParameter("classId", classId);
        query.setParameter("date", date);
        return query.getResultList();
    }

    public List<Attendance> findByStudentId(Long studentId) {
        TypedQuery<Attendance> query = em.createQuery(
                "SELECT a FROM Attendance a WHERE a.student.userId = :studentId ORDER BY a.attendanceDate DESC", 
                Attendance.class);
        query.setParameter("studentId", studentId);
        return query.getResultList();
    }

    public List<Attendance> findByStudentAndClass(Long studentId, Long classId) {
        TypedQuery<Attendance> query = em.createQuery(
                "SELECT a FROM Attendance a WHERE a.student.userId = :studentId AND a.classEntity.id = :classId ORDER BY a.attendanceDate DESC", 
                Attendance.class);
        query.setParameter("studentId", studentId);
        query.setParameter("classId", classId);
        return query.getResultList();
    }

    public Attendance findByClassStudentAndDate(Long classId, Long studentId, Date date) {
        TypedQuery<Attendance> query = em.createQuery(
                "SELECT a FROM Attendance a WHERE a.classEntity.id = :classId AND a.student.userId = :studentId AND a.attendanceDate = :date", 
                Attendance.class);
        query.setParameter("classId", classId);
        query.setParameter("studentId", studentId);
        query.setParameter("date", date);
        try {
            return query.getSingleResult();
        } catch (jakarta.persistence.NoResultException e) {
            return null;
        }
    }

    public Long countPresentByStudentAndClass(Long studentId, Long classId) {
        TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(a) FROM Attendance a WHERE a.student.userId = :studentId AND a.classEntity.id = :classId AND a.status = 'PRESENT'", 
                Long.class);
        query.setParameter("studentId", studentId);
        query.setParameter("classId", classId);
        return query.getSingleResult();
    }

    public Long countTotalByStudentAndClass(Long studentId, Long classId) {
        TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(a) FROM Attendance a WHERE a.student.userId = :studentId AND a.classEntity.id = :classId", 
                Long.class);
        query.setParameter("studentId", studentId);
        query.setParameter("classId", classId);
        return query.getSingleResult();
    }
}

