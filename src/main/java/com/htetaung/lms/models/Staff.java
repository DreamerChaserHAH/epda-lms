package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.Gender;
import com.htetaung.lms.models.enums.UserRole;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;
import java.util.Optional;
import java.util.UUID;

@Getter
@Setter
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
        this.staffNumber = UUID.randomUUID().toString();
    }

    public Staff(
            String username,
            String full_name,
            Date dateOfBirth,
            String ic,
            String email,
            String phoneNumber,
            String address,
            String passwordHash,
            Optional<User> createdBy,
            UserRole role,
            Gender gender,
            Long department
    ) {
        super(
                username,
                full_name,
                dateOfBirth,
                ic,
                email,
                phoneNumber,
                address,
                passwordHash,
                createdBy,
                role,
                gender
        );
        this.staffNumber = UUID.randomUUID().toString();
        this.department = department;
    }

    public Staff(User user, Long department){
        super(user);
        this.staffNumber = UUID.randomUUID().toString();
        this.department = department;
    }

    public void changeRole(UserRole role){
        setRole(role);
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
