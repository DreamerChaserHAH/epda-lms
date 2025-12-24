package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.UserRole;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.Date;
import java.util.Optional;

@Getter
@Setter
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
    private UserRole role;

    public User(){

    }

    public User(String username, String full_name, String passwordHash, Optional<User> createdBy, UserRole role) {
        this.username = username;
        this.fullName = full_name;
        this.passwordHash = passwordHash;
        this.createdBy = createdBy != null ? createdBy.orElse(null) : null;
        this.role = role;
    }

    public User(User user){
        this.username = user.username;
        this.fullName = user.fullName;
        this.passwordHash = user.passwordHash;
        this.createdBy = user.createdBy;
        this.role = user.role;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
    }

}
