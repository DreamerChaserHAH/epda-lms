package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.Gender;
import com.htetaung.lms.models.enums.UserRole;

import jakarta.persistence.Entity;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name="Admin")
@PrimaryKeyJoinColumn(name="user_id")
public class Admin extends Staff{

    public String permissions;

    public Admin(
            String username,
            String full_name,
            Date dateOfBirth,
            String ic,
            String email,
            String phoneNumber,
            String address,
            String passwordHash,
            java.util.Optional<User> createdBy,
            Gender gender,
            Long department) {
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
                UserRole.ADMIN,
                gender,
                department
        );
        this.permissions = "ALL";
    }

    public Admin(User user, Long department){
        super(user, department);
        user.setRole(UserRole.ADMIN);
        this.permissions = "ALL";
    }
}
