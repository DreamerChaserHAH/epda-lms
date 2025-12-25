package com.htetaung.lms.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name="Module")
public class Module {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="module_id")
    private Long moduleId;

    @Column(name="module_name", nullable=false)
    private String moduleName;

    @ManyToOne
    @JoinColumn(name="managing_leader", nullable=false)
    ///  Academic Leader that create this module, only this academic leader can update or delete this module
    private AcademicLeader createdBy;

    @ManyToOne
    @JoinColumn(name="managing_lecturer")
    ///  The lecturer that is assigned to manage this module
    private Lecturer managedBy;

    public Module(String moduleName, AcademicLeader createdBy, Lecturer managedBy) {
        this.moduleName = moduleName;
        this.createdBy = createdBy;
        this.managedBy = managedBy;
    }
}
