package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.Staff;
import com.htetaung.lms.models.User;
import com.htetaung.lms.exception.AuthenticationException;
import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.assessments.Assignment;
import com.htetaung.lms.models.dto.AssessmentDTO;
import com.htetaung.lms.models.dto.AssignmentDTO;
import com.htetaung.lms.models.enums.AssessmentType;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.List;

@Stateless
public class AssignmentFacade extends AbstractFacade<Assignment>{

    @PersistenceContext
    private EntityManager em;

    public static final int PAGE_SIZE = 10;

    public AssignmentFacade() {
        super(Assignment.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public AssignmentDTO findAssessmentById(Long assessmentId){
        Assignment assignment = find(assessmentId);
        if(assignment != null){
            return new AssignmentDTO(assignment);
        }
        return null;
    }

    public List<AssignmentDTO> findAssignmentsInClass(Long classId){
        List<Assignment> assignments = em.createQuery("SELECT a FROM Assessment a WHERE a.relatedClass.classId = :classId", Assignment.class)
                .setParameter("classId", classId)
                .getResultList();
        return assignments.stream().map(AssignmentDTO::new).toList();
    }

    public List<AssignmentDTO> findAssignmentssByVisibility(Long classId, String visibility) {
        List<Assignment> assessments = em.createQuery("SELECT a FROM Assessment a WHERE a.relatedClass.classId = :classId AND a.visibility = :visibility", Assignment.class)
                .setParameter("classId", classId)
                .setParameter("visibility", visibility)
                .getResultList();
        return assessments.stream().map(AssignmentDTO::new).toList();
    }

    public boolean assignmentExists(Long assignmentId){
        Assignment assignment = find(assignmentId);
        return assignment != null;
    }

    public Assignment updateAssignment(AssignmentDTO assignmentDTO){
        return em.merge(assignmentDTO.toAssignment());
    }

    public void deleteAssignment(Long assigmentId){
        Assignment assignment = find(assigmentId);
        if(assignment != null){
            em.remove(assignment);
        }
    }
}
