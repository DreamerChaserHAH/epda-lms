package com.htetaung.lms.entity;

import jakarta.persistence.*;

import java.util.Optional;
import java.util.UUID;

@Entity
@Inheritance(strategy=InheritanceType.JOINED)
@PrimaryKeyJoinColumn(name="user_id")
@Table(name="Staff")
public class Staff extends User{

    @Column(name = "staff_number", unique = true, nullable = false)
    private String staffNumber;

    @Column(name="department_id", nullable=false)
    private Long department;

    public Staff(){

    }

    public Staff(String username, String full_name, String passwordHash, Optional<User> createdBy, Role role, Long department) {
        super(
                username,
                full_name,
                passwordHash,
                createdBy,
                role
        );
        this.staffNumber = UUID.randomUUID().toString();
        this.department = department;
    }

    public String getStaffNumber() {
        return staffNumber;
    }

    public Long getDepartment() {
        return department;
    }

    public void setDepartment(Long department) {
        this.department = department;
    }
}
