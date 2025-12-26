package com.htetaung.lms.models.dto;

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
}
