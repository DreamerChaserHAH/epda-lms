package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.exception.UserException;
import com.htetaung.lms.models.Student;
import com.htetaung.lms.exception.AuthenticationException;
import com.htetaung.lms.models.dto.StudentDTO;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.List;

@Stateless
public class StudentFacade extends AbstractFacade<Student>{

    @PersistenceContext
    private EntityManager em;

    @EJB
    private UserFacade userFacade;

    public static final int PAGE_SIZE = 10;

    public StudentFacade() {
        super(Student.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<StudentDTO> getAllStudents(){
        List<Student> students = em.createQuery("SELECT s FROM Student s", Student.class)
                .getResultList();
        return students.stream().map(
                s -> new StudentDTO(
                        s.getUserId(),
                        s.getFullName(),
                        s.getEmail(),
                        s.getPhoneNumber()
                )
        ).toList();
    }

    public StudentDTO getStudentById(Long studentId) throws UserException{
        Student student = find(studentId);
        if (student == null) {
            throw new UserException("Student with User ID " + studentId + " not found");
        }
        return new StudentDTO(
                student.getUserId(),
                student.getFullName(),
                student.getEmail(),
                student.getPhoneNumber()
        );
    }

    public List<StudentDTO> getStudentsByIds(List<Long> studentIds){
        List<Student> students = em.createQuery("SELECT s FROM Student s WHERE s.userId IN :ids", Student.class)
                .setParameter("ids", studentIds)
                .getResultList();
        return students.stream().map(
                s -> new StudentDTO(
                        s.getUserId(),
                        s.getFullName(),
                        s.getEmail(),
                        s.getPhoneNumber()
                )
        ).toList();
    }

    public boolean studentExists(Long studentId){
        Student student = find(studentId);
        return student != null;
    }
}
