package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.UserRole;

import jakarta.persistence.Entity;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name="Admin")
@PrimaryKeyJoinColumn(name="user_id")
public class Admin extends Staff{

    public String permissions;

    public Admin(String username, String full_name, String passwordHash, java.util.Optional<User> createdBy, Long department) {
        super(
                username,
                full_name,
                passwordHash,
                createdBy,
                UserRole.ADMIN,
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
