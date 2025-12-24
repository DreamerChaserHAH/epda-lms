package com.htetaung.lms.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.Date;

@Getter
@Setter
@Entity
@Table(name = "Class")
public class ClassEntity implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "class_id")
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(name = "class_code", unique = true, nullable = false)
    private String classCode;

    @Column(columnDefinition = "TEXT")
    private String description;

    @ManyToOne(optional = true)
    @JoinColumn(name = "lecturer_id", nullable = true)
    private User lecturer;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Date createdAt;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "updated_at", nullable = false)
    private Date updatedAt;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    public ClassEntity() {
    }

    public ClassEntity(String name, String classCode, String description, User lecturer) {
        this.name = name;
        this.classCode = classCode;
        this.description = description;
        this.lecturer = lecturer;
        this.isActive = true;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
        updatedAt = new Date();
        if (isActive == null) {
            isActive = true;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = new Date();
    }
}

