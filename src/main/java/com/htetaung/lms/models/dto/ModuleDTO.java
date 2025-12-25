package com.htetaung.lms.models.dto;

public class ModuleDTO {
    public Long moduleId;
    public String moduleName;

    public AcademicLeaderDTO createdBy;
    public LecturerDTO managedBy;

    public ModuleDTO(
            Long moduleId,
            String moduleName,
            AcademicLeaderDTO createdBy,
            LecturerDTO managedBy
    ) {
        this.moduleId = moduleId;
        this.moduleName = moduleName;
        this.createdBy = createdBy;
        this.managedBy = managedBy;
    }
}
