package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Assessment;
import com.htetaung.lms.models.enums.AssessmentType;
import com.htetaung.lms.models.enums.Visibility;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.PersistenceException;
import jakarta.persistence.TypedQuery;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Stateless
public class AssessmentFacade extends AbstractFacade<Assessment> {

    @PersistenceContext
    private EntityManager em;

    public AssessmentFacade() {
        super(Assessment.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<Assessment> searchByName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return new ArrayList<>();
        }
        try {
            TypedQuery<Assessment> query = em.createQuery(
                    "SELECT a FROM Assessment a WHERE LOWER(a.name) LIKE :name ORDER BY a.name ASC", Assessment.class);
            query.setParameter("name", "%" + name.toLowerCase() + "%");
            return query.getResultList();
        } catch (PersistenceException e) {
            // Log the exception in production
            return new ArrayList<>();
        }
    }

    public List<Assessment> searchByDeadline(Date deadline) {
        if (deadline == null) {
            return new ArrayList<>();
        }
        try {
            TypedQuery<Assessment> query = em.createQuery(
                    "SELECT a FROM Assessment a WHERE a.deadline = :deadline ORDER BY a.deadline ASC", Assessment.class);
            query.setParameter("deadline", deadline);
            return query.getResultList();
        } catch (PersistenceException e) {
            // Log the exception in production
            return new ArrayList<>();
        }
    }

    public List<Assessment> searchByDeadlineRange(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) {
            return new ArrayList<>();
        }
        try {
            TypedQuery<Assessment> query = em.createQuery(
                    "SELECT a FROM Assessment a WHERE a.deadline BETWEEN :startDate AND :endDate ORDER BY a.deadline ASC", Assessment.class);
            query.setParameter("startDate", startDate);
            query.setParameter("endDate", endDate);
            return query.getResultList();
        } catch (PersistenceException e) {
            // Log the exception in production
            return new ArrayList<>();
        }
    }

    public List<Assessment> searchByVisibility(Visibility visibility) {
        if (visibility == null) {
            return new ArrayList<>();
        }
        try {
            TypedQuery<Assessment> query = em.createQuery(
                    "SELECT a FROM Assessment a WHERE a.visibility = :visibility ORDER BY a.updatedAt DESC", Assessment.class);
            query.setParameter("visibility", visibility);
            return query.getResultList();
        } catch (PersistenceException e) {
            // Log the exception in production
            return new ArrayList<>();
        }
    }

    public List<Assessment> searchByAssessmentType(AssessmentType assessmentType) {
        if (assessmentType == null) {
            return new ArrayList<>();
        }
        try {
            TypedQuery<Assessment> query = em.createQuery(
                    "SELECT a FROM Assessment a WHERE a.assessmentType = :assessmentType ORDER BY a.updatedAt DESC", Assessment.class);
            query.setParameter("assessmentType", assessmentType);
            return query.getResultList();
        } catch (PersistenceException e) {
            // Log the exception in production
            return new ArrayList<>();
        }
    }
}

