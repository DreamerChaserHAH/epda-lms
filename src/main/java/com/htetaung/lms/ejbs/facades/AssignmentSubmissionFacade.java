package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.assessments.AssignmentSubmission;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class AssignmentSubmissionFacade extends AbstractFacade<AssignmentSubmission> {

    @PersistenceContext
    private EntityManager em;

    public AssignmentSubmissionFacade() {
        super(AssignmentSubmission.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<AssignmentSubmission> findByStudentId(Long studentId) {
        return em.createQuery(
                "SELECT a FROM AssignmentSubmission a WHERE a.submittedBy.userId = :studentId",
                AssignmentSubmission.class)
                .setParameter("studentId", studentId)
                .getResultList();
    }
}
