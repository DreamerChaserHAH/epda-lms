package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.AcademicLeaderFacade;
import com.htetaung.lms.ejbs.facades.LecturerFacade;
import com.htetaung.lms.ejbs.facades.UserFacade;
import com.htetaung.lms.models.dto.AcademicLeaderDTO;
import com.htetaung.lms.models.dto.LecturerDTO;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import java.util.List;

@Stateless
public class StaffServiceFacade {
    @EJB
    public UserFacade userFacade;

    @EJB
    public LecturerFacade lecturerFacade;

    @EJB
    public AcademicLeaderFacade academicLeaderFacade;

    public List<AcademicLeaderDTO> getAllAcademicLeaders() {
        return academicLeaderFacade.getAllAcademicLeaders().stream().map(
                al -> new AcademicLeaderDTO(
                        al.getUserId(),
                        al.getFullName(),
                        lecturerFacade.countLecturersByAcademicLeaderId(al.getUserId())
                )
        ).toList();
    }

    public List<LecturerDTO> getAllLecturers() {
        return lecturerFacade.findAll().stream().map(
                l -> new LecturerDTO(
                        l.getUserId(),
                        l.getFullName(),
                        l.getAcademicLeader() != null ? l.getAcademicLeader().getUserId() : null
                )
        ).toList();
    }

    public void updateLecturerAcademicLeader(Long lecturerId, Long academicLeaderId, String operatedBy) {
        lecturerFacade.updateLecturerAcademicLeader(lecturerId, academicLeaderId, operatedBy);
    }
}
