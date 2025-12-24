package com.htetaung.lms.models;

import com.htetaung.lms.models.enums.AssessmentType;
import com.htetaung.lms.models.enums.Visibility;
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
@Table(name = "Assessment")
public class Assessment implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "assessment_id")
    private Long id;

    @NotNull
    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "deadline", nullable = false)
    private Date deadline;

    @Enumerated(EnumType.STRING)
    @Column(name = "visibility", nullable = false)
    private Visibility visibility;

    @Enumerated(EnumType.STRING)
    @Column(name = "assessment_type", nullable = false)
    private AssessmentType assessmentType;

    @ManyToOne(optional = true)
    @JoinColumn(name = "created_by_id", nullable = true, updatable = false)
    private User createdBy;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Date createdAt;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "updated_at", nullable = false)
    private Date updatedAt;

    public Assessment() {
    }

    public Assessment(String name, String description, Date deadline, Visibility visibility, 
                     AssessmentType assessmentType, Optional<User> createdBy) {
        this.name = name;
        this.description = description;
        this.deadline = deadline;
        this.visibility = visibility;
        this.assessmentType = assessmentType;
        this.createdBy = createdBy != null ? createdBy.orElse(null) : null;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
        updatedAt = new Date();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = new Date();
    }
}

