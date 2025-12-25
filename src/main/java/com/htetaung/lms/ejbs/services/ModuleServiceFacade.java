package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.AcademicLeaderFacade;
import com.htetaung.lms.ejbs.facades.LecturerFacade;
import com.htetaung.lms.ejbs.facades.ModuleFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.exception.ModuleException;
import com.htetaung.lms.models.AcademicLeader;
import com.htetaung.lms.models.Lecturer;
import com.htetaung.lms.models.Module;
import com.htetaung.lms.models.User;
import com.htetaung.lms.models.dto.AcademicLeaderDTO;
import com.htetaung.lms.models.dto.LecturerDTO;
import com.htetaung.lms.models.dto.ModuleDTO;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import java.util.List;

@Stateless
public class ModuleServiceFacade {
    @EJB
    private ModuleFacade moduleFacade;

    @EJB
    private LecturerFacade lecturerFacade;

    @EJB
    private AcademicLeaderFacade academicLeaderFacade;

    @EJB
    private UserFacade userFacade;


    public void CreateModule(String moduleName, Long academicLeaderId, Long lecturerId, String operatedBy) throws ModuleException {
        if(academicLeaderId == null || academicLeaderId <= 0) {
            throw new ModuleException("Academic Leader is required");
        }
        AcademicLeader academicLeader = academicLeaderFacade.find(academicLeaderId);
        if(academicLeader == null) {
            throw new ModuleException("Academic Leader not found");
        }
        Lecturer lecturer = null;
        if (lecturerId != null && lecturerId > 0) {
            lecturer = lecturerFacade.find(lecturerId);
            if(lecturer == null) {
                throw new ModuleException("Lecturer not found");
            }
        }
        Module newModule = new Module(moduleName, academicLeader, lecturer);
        moduleFacade.create(newModule, operatedBy);
    }

    public List<ModuleDTO> ListAllModulesUnderAcademicLeader(Long academicLeaderId, int page) throws ModuleException {
        AcademicLeader academicLeader = academicLeaderFacade.find(academicLeaderId);
        if(academicLeader == null) {
            throw new ModuleException("Academic Leader not found");
        }
        List<Module> modules = moduleFacade.listAllModulesUnderAcademicLeader(academicLeaderId, page);
        return modules.stream().map(
                m -> new ModuleDTO(
                        m.getModuleId(),
                        m.getModuleName(),
                        new AcademicLeaderDTO(m.getCreatedBy()),
                        m.getManagedBy() != null ? new LecturerDTO(m.getManagedBy()) : null
                )
        ).toList();
    }

    public void UpdateModule(Long moduleId, String moduleName, Long lecturerId, String operatedBy) throws ModuleException {
        Module module = moduleFacade.find(moduleId);
        if(module == null) {
            throw new ModuleException("Module not found");
        }
        Lecturer lecturer = null;
        if (lecturerId != null && lecturerId > 0) {
            lecturer = lecturerFacade.find(lecturerId);
            if(lecturer == null) {
                throw new ModuleException("Lecturer not found");
            }
        }
        module.setModuleName(moduleName);
        module.setManagedBy(lecturer);
        moduleFacade.edit(module, operatedBy);
    }

    public void DeleteModule(Long moduleId, String operatedBy) throws ModuleException {
        Module module = moduleFacade.find(moduleId);
        if(module == null) {
            throw new ModuleException("Module not found");
        }
        moduleFacade.remove(module, operatedBy);
    }
}
