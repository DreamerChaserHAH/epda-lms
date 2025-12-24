package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.Gender;
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

    @Column(name = "date_of_birth", nullable = false)
    private Date dateOfBirth;

    @Column(name = "ic", nullable = false, unique = true)
    private String ic;

    @Column(name = "email", nullable = false)
    private String email;

    @Column(name = "phone_number", nullable = true)
    private String phoneNumber;

    @Column(name = "address", nullable = true)
    private String address;

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

    @Enumerated(EnumType.STRING)
    @Column(name = "gender", nullable = false)
    private Gender gender;

    public User(){

    }

    public User(
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
            Gender gender
    ) {
        this.username = username;
        this.fullName = full_name;
        this.dateOfBirth = dateOfBirth;
        this.ic = ic;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.passwordHash = passwordHash;
        this.createdBy = createdBy != null ? createdBy.orElse(null) : null;
        this.role = role;
        this.gender = gender;
    }

    public User(User user){
        this.username = user.username;
        this.fullName = user.fullName;
        this.dateOfBirth = user.dateOfBirth;
        this.ic = user.ic;
        this.email = user.email;
        this.phoneNumber = user.phoneNumber;
        this.address = user.address;
        this.passwordHash = user.passwordHash;
        this.createdBy = user.createdBy;
        this.role = user.role;
        this.gender = user.gender;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
    }

}
