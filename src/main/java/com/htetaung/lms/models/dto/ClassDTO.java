package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.Class;

import java.util.ArrayList;
import java.util.List;

public class ClassDTO {
    public Long classId;
    public String className;
    public ModuleDTO moduleDTO;
    public List<StudentDTO> students;
    public Long studentCount;

    public ClassDTO(
            Long classId,
            String className,
            ModuleDTO moduleDTO,
            List<StudentDTO> students,
            Long studentCount
    ) {
        this.classId = classId;
        this.className = className;
        this.moduleDTO = moduleDTO;
        this.students = students;
        this.studentCount = studentCount;
    }

    public ClassDTO(Class classEntity) {
        this.classId = classEntity.getClassId();
        this.className = classEntity.getClassName();
        this.moduleDTO = new ModuleDTO(classEntity.getModule());
        this.students = new ArrayList<>();
        for (var student : classEntity.getEnrolledStudents()) {
            this.students.add(new StudentDTO(
                    student.getUserId(),
                    student.getFullName(),
                    student.getEmail(),
                    student.getPhoneNumber()
            ));
        }
        this.studentCount = (long) classEntity.getEnrolledStudents().size();
    }

    public Class toClass(){
        Class classEntity = new Class();
        classEntity.setClassId(this.classId);
        classEntity.setClassName(this.className);
        classEntity.setModule(this.moduleDTO.toModule());
        return classEntity;
    }
}
