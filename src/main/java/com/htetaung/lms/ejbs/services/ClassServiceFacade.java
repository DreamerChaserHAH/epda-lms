package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.ClassFacade;
import com.htetaung.lms.ejbs.facades.ModuleFacade;
import com.htetaung.lms.ejbs.facades.StudentFacade;
import com.htetaung.lms.exception.ClassException;
import com.htetaung.lms.exception.ModuleException;
import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.Module;
import com.htetaung.lms.models.dto.ClassDTO;
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

    public void CreateClass(Long moduleId, String className, String operatedBy) throws ClassException{
        if(!moduleFacade.moduleExists(moduleId)){
            throw new ClassException("Module not found");
        }

        Module m = moduleFacade.find(moduleId);
        Class newClass = new Class(m, className);
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

    public List<ClassDTO> ListAllClassesUnderLecturer(Long lecturerId) throws ClassException {
        List<Module> modules = moduleFacade.listAllModulesUnderLecturer(lecturerId, 1);
        if (modules.isEmpty()) {
            throw new ClassException("No modules found under this lecturer");
        }

        List<ClassDTO> allClasses = new java.util.ArrayList<>();

        for (Module m : modules) {
            // Check if classes exist for THIS module (not lecturer ID)
            if (classFacade.classExists(m.getModuleId())) {
                // Get classes for THIS module (not lecturer ID)
                List<Class> classes = classFacade.listAllClassesUnderModule(m.getModuleId());

                List<ClassDTO> classDTOs = classes.stream().map(
                        classInQuestion -> {
                            try {
                                return GetClass(classInQuestion.getClassId());
                            } catch (ClassException | ModuleException e) {
                                throw new RuntimeException(e);
                            }
                        }
                ).toList();

                allClasses.addAll(classDTOs);
            }
        }

        if (allClasses.isEmpty()) {
            throw new ClassException("No classes found under this lecturer");
        }

        return allClasses;
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

    public void DeleteClass(Long classId, String operatedBy) throws ClassException{
        if(!classFacade.classExists(classId)){
            throw new ClassException("Class not found");
        }

        Class classInQuestion = classFacade.find(classId);
        classFacade.remove(classInQuestion, operatedBy);
    }
}
