package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.Module;

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

    public ModuleDTO(Module module){
        this.moduleId = module.getModuleId();
        this.moduleName = module.getModuleName();
        this.createdBy = new AcademicLeaderDTO(module.getCreatedBy());
        this.managedBy = new LecturerDTO(module.getManagedBy());
    }

    public Module toModule(){
        Module module = new Module();
        module.setModuleId(this.moduleId);
        module.setModuleName(this.moduleName);
        module.setCreatedBy(this.createdBy.toAcademicLeader());
        module.setManagedBy(this.managedBy.toLecturer());
        return module;
    }
}
