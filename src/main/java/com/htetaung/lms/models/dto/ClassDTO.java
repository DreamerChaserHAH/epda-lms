package com.htetaung.lms.models.dto;

import java.util.List;

public class ClassDTO {
    public Long classId;
    public String className;

    public String classDescription;
    public ModuleDTO moduleDTO;
    public List<StudentDTO> students;
    public Long studentCount;

    public ClassDTO(
            Long classId,
            String className,
            String classDescription,
            ModuleDTO moduleDTO,
            List<StudentDTO> students,
            Long studentCount
    ) {
        this.classId = classId;
        this.className = className;
        this.classDescription = classDescription;
        this.moduleDTO = moduleDTO;
        this.students = students;
        this.studentCount = studentCount;
    }
}
