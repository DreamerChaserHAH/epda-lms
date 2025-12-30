package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.Staff;
import com.htetaung.lms.models.Student;
import com.htetaung.lms.models.User;
import com.htetaung.lms.exception.AuthenticationException;
import com.htetaung.lms.models.assessments.Assessment;
import com.htetaung.lms.models.dto.AssessmentDTO;
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
public class AssessmentFacade extends AbstractFacade<Assessment>{

    @PersistenceContext
    private EntityManager em;

    @EJB
    private StudentFacade studentFacade;

    public static final int PAGE_SIZE = 10;

    public AssessmentFacade() {
        super(Assessment.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public AssessmentDTO findAssessmentById(Long assessmentId){
        Assessment assessment = find(assessmentId);
        if(assessment != null){
            return new AssessmentDTO(assessment);
        }
        return null;
    }

    public List<AssessmentDTO> findAssessmentsInClass(Long classId){
        List<Assessment> assessments = em.createQuery("SELECT a FROM Assessment a WHERE a.relatedClass.classId = :classId", Assessment.class)
                .setParameter("classId", classId)
                .getResultList();
        return assessments.stream().map(AssessmentDTO::new).toList();
    }

    public List<AssessmentDTO> findVisibleAssessmentsForStudent(Long classId, Long studentId) {
        // Get the Student entity first
        Student student = studentFacade.find(studentId);
        if (student == null) {
            return List.of(); // Return empty list if student not found
        }

        // Get assessments that are:
        // 1. PUBLIC - visible to all
        // 2. PROTECTED - student is in visibleToStudents list
        // 3. Belong to the specified class
        List<Assessment> assessments = em.createQuery(
                "SELECT a FROM Assessment a " +
                "WHERE a.relatedClass.classId = :classId " +
                "AND (a.visibility = 'PUBLIC' " +
                "OR (a.visibility = 'PROTECTED' AND :student MEMBER OF a.visibleToStudents))",
                Assessment.class)
                .setParameter("classId", classId)
                .setParameter("student", student)
                .getResultList();
        return assessments.stream().map(AssessmentDTO::new).toList();
    }

    public List<AssessmentDTO> findAssessmentsByType(Long classId, AssessmentType assessmentType) {
        List<Assessment> assessments = em.createQuery("SELECT a FROM Assessment a WHERE a.relatedClass.classId = :classId AND a.assessmentType = :assessmentType", Assessment.class)
                .setParameter("classId", classId)
                .setParameter("assessmentType", assessmentType)
                .getResultList();
        return assessments.stream().map(AssessmentDTO::new).toList();
    }

    public List<AssessmentDTO> findAssessmentsByVisibility(Long classId, String visibility) {
        List<Assessment> assessments = em.createQuery("SELECT a FROM Assessment a WHERE a.relatedClass.classId = :classId AND a.visibility = :visibility", Assessment.class)
                .setParameter("classId", classId)
                .setParameter("visibility", visibility)
                .getResultList();
        return assessments.stream().map(AssessmentDTO::new).toList();
    }

    public boolean assessmentExists(Long assessmentId){
        Assessment assessment = find(assessmentId);
        return assessment != null;
    }

    public Assessment updateAssessment(AssessmentDTO assessmentDTO){
        return em.merge(assessmentDTO.toAssessment());
    }

    public void deleteAssessment(Long assessmentId){
        Assessment assessment = find(assessmentId);
        if(assessment != null){
            em.remove(assessment);
        }
    }

    /**
     * Find assessment by ID with explicit query to ensure ID is properly initialized
     * This is needed for JOINED inheritance strategy
     */
    public Assessment findAssessmentWithId(Long assessmentId) {
        try {
            Assessment assessment = em.createQuery("SELECT a FROM Assessment a WHERE a.assessmentId = :id", Assessment.class)
                    .setParameter("id", assessmentId)
                    .getSingleResult();

            // Force initialization of the entity to ensure all fields are loaded
            if (assessment != null) {
                // Access a field to ensure the entity is fully initialized
                assessment.getAssessmentName();

                // Verify ID is set
                if (assessment.getAssessmentId() == null) {
                    System.err.println("AssessmentFacade: WARNING - Query returned assessment with NULL ID! Using getReference fallback...");
                    // Try using getReference as fallback
                    return em.getReference(Assessment.class, assessmentId);
                }

                // Log for debugging
                System.out.println("AssessmentFacade: Loaded assessment ID=" + assessment.getAssessmentId() +
                                 ", Type=" + assessment.getClass().getName());
            }

            return assessment;
        } catch (jakarta.persistence.NoResultException e) {
            System.err.println("AssessmentFacade: No assessment found with ID: " + assessmentId);
            return null;
        } catch (Exception e) {
            System.err.println("AssessmentFacade: Error finding assessment: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}
