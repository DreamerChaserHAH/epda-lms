package com.htetaung.lms.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;

import java.util.Optional;

@Entity
@Table(name="Admin")
@PrimaryKeyJoinColumn(name="user_id")
public class Admin extends Staff{

    public String permissions;

    public Admin(){

    }

    public Admin(String username, String full_name, String passwordHash, java.util.Optional<User> createdBy, Long department) {
        super(
                username,
                full_name,
                passwordHash,
                createdBy,
                Role.ADMIN,
                department
        );
        this.permissions = "ALL";
    }
}
