package com.htetaung.lms.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;
import java.util.Date;
import java.util.Optional;

@Entity
@Inheritance(strategy = InheritanceType.JOINED)
@Table(name = "User")
public class User implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="user_id")
    private Long userId;

    @NotNull
    @Column(unique = true, nullable = false)
    private String username;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @NotNull
    @Column(nullable = false)
    private String passwordHash;

    @ManyToOne(optional = true)
    @JoinColumn(name = "created_by_id", nullable = true, updatable = false)
    private User createdBy;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Date createdAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    private Role role;

    public User(){

    }

    public User(String username, String full_name, String passwordHash, Optional<User> createdBy, Role role) {
        this.username = username;
        this.fullName = full_name;
        this.passwordHash = passwordHash;
        this.createdBy = createdBy != null ? createdBy.orElse(null) : null;
        this.role = role;
    }

    // Getters and Setters
    public Long getId() {
        return userId;
    }

    public void setId(Long id) {
        this.userId = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String password) {
        this.passwordHash = password;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public User getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(User createdBy) {
        this.createdBy = createdBy;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public enum Role {
        STUDENT, LECTURER, ACADEMIC_LEADER, ADMIN
    }

    public static String roleToString(Role role) {
        return switch (role) {
            case STUDENT -> "Student";
            case LECTURER -> "Lecturer";
            case ACADEMIC_LEADER -> "Academic Leader";
            case ADMIN -> "Admin";
        };
    }
}
