package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.Class;
import com.htetaung.lms.models.Student;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@Getter
@Setter
public class ClassEnrollmentDTO {
    public ClassDTO classDTO;
    public StudentDTO studentDTO;

    public ClassEnrollmentDTO(ClassDTO classDTO, StudentDTO studentDTO) {
        this.classDTO = classDTO;
        this.studentDTO = studentDTO;
    }

    public ClassEnrollmentDTO(Class classEntity, Student student){
        this.classDTO = new ClassDTO(
                classEntity.getClassId(),
                classEntity.getClassName(),
                classEntity.getDescription(),
                new ModuleDTO(
                        classEntity.getModule().getModuleId(),
                        classEntity.getModule().getModuleName(),
                        new AcademicLeaderDTO(classEntity.getModule().getCreatedBy()),
                        new LecturerDTO(classEntity.getModule().getManagedBy())
                ),
                null,
                (long) classEntity.getEnrolledStudents().size()
        );

        this.studentDTO = new StudentDTO(
                student.getUserId(),
                student.getFullName(),
                student.getEmail(),
                student.getPhoneNumber()
        );
    }
}
