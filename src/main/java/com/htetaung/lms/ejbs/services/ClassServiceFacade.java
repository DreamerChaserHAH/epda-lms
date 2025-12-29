package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.ClassFacade;
import com.htetaung.lms.ejbs.facades.ModuleFacade;
import com.htetaung.lms.ejbs.facades.StudentFacade;
import com.htetaung.lms.exception.ClassException;
import com.htetaung.lms.exception.ModuleException;
import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.Module;
import com.htetaung.lms.models.dto.ClassDTO;
import com.htetaung.lms.models.dto.ClassEnrollmentDTO;
import com.htetaung.lms.models.dto.ModuleDTO;
import com.htetaung.lms.models.dto.StudentDTO;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import java.util.List;

@Stateless
public class ClassServiceFacade {
    @EJB
    private ClassFacade classFacade;

    @EJB
    private ModuleFacade moduleFacade;

    @EJB
    private StudentFacade studentFacade;

    @EJB
    private ModuleServiceFacade moduleServiceFacade;

    public void CreateClass(Long moduleId, String className, String description, String operatedBy) throws ClassException{
        if(!moduleFacade.moduleExists(moduleId)){
            throw new ClassException("Module not found");
        }

        Module m = moduleFacade.find(moduleId);
        Class newClass = new Class(m, className, description);
        classFacade.create(newClass, operatedBy);
    }

    public ClassDTO GetClass(Long classId) throws ClassException, ModuleException {
        Class classInQuestion = classFacade.find(classId);
        if (classInQuestion == null){
            throw new ClassException("Class not found");
        } else {
            return new ClassDTO(
                    classInQuestion.getClassId(),
                    classInQuestion.getClassName(),
                    classInQuestion.getDescription(),
                    moduleServiceFacade.GetModule(classInQuestion.getModule().getModuleId()),
                    classInQuestion.getEnrolledStudents().stream().map(
                            student -> new StudentDTO(
                                    student.getUserId(),
                                    student.getFullName(),
                                    student.getEmail(),
                                    student.getPhoneNumber()
                            )
                    ).toList(),
                    (long) classInQuestion.getEnrolledStudents().size()
            );
        }
    }

    public List<ClassDTO> ListAllClassesUnderModule(Long moduleId) throws ClassException{
        List<Class> classes = classFacade.listAllClassesUnderModule(moduleId);
        return classes.stream().map(
                classInQuestion -> {
                    try {
                        return GetClass(classInQuestion.getClassId());
                    } catch (ClassException | ModuleException e) {
                        throw new RuntimeException(e);
                    }
                }
        ).toList();
    }

    public void UpdateClass(Long classId, String className, List<StudentDTO> newStudents, List<StudentDTO> studentsToRemove, String operatedBy) throws ClassException{
        if(!classFacade.classExists(classId)){
            throw new ClassException("Class not found");
        }

        Class classInQuestion = classFacade.find(classId);
        classInQuestion.setClassName(className);
        for (StudentDTO studentDTO : newStudents){
            classInQuestion.AddStudent(
                    studentFacade.find(studentDTO.userId)
            );
        }
        for (StudentDTO studentDTO : studentsToRemove){
            classInQuestion.RemoveStudent(
                    studentFacade.find(studentDTO.userId)
            );
        }
        classFacade.edit(classInQuestion, operatedBy);
    }

    public List<ClassEnrollmentDTO> FindEnrollmentsInClass(Long classId) throws ClassException{
        if(!classFacade.classExists(classId)){
            throw new ClassException("Class not found");
        }

        Class classInQuestion = classFacade.find(classId);
        return classInQuestion.getEnrolledStudents().stream().map(
                student -> new ClassEnrollmentDTO(
                        classInQuestion,
                        student
                )
        ).toList();
    }

    public List<ClassEnrollmentDTO> FindClassesOfStudent(Long studentId) throws ClassException{
        if(!studentFacade.studentExists(studentId)){
            throw new ClassException("Student not found");
        }

        List<Class> classes = classFacade.findClassesOfStudent(studentId);
        return classes.stream().map(
                classInQuestion -> {
                    return new ClassEnrollmentDTO(
                            classInQuestion,
                            studentFacade.find(studentId)
                    );
                }
        ).toList();
    }

    public ClassEnrollmentDTO FindClassEnrollmentByStudentAndClass(Long classId, Long studentId) throws ClassException{
        if(!classFacade.classExists(classId)){
            throw new ClassException("Class not found");
        }
        if(!studentFacade.studentExists(studentId)){
            throw new ClassException("Student not found");
        }

        Class classInQuestion = classFacade.find(classId);
        return new ClassEnrollmentDTO(
                classInQuestion,
                studentFacade.find(studentId)
        );
    }

    public void DeleteClass(Long classId, String operatedBy) throws ClassException{
        if(!classFacade.classExists(classId)){
            throw new ClassException("Class not found");
        }

        Class classInQuestion = classFacade.find(classId);
        classFacade.remove(classInQuestion, operatedBy);
    }
}
