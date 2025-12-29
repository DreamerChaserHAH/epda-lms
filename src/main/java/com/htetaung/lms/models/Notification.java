package com.htetaung.lms.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.Date;

@Getter
@Setter
@Entity
@Table(name = "Notification")
public class Notification implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String message;

    @Column(name = "notification_type", nullable = false, length = 50)
    private String type; // NEW_ASSIGNMENT, GRADE_POSTED, DEADLINE_REMINDER, ANNOUNCEMENT

    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;

    @Column(name = "related_id")
    private Long relatedId; // ID of related assessment, submission, etc.

    @Column(name = "related_type", length = 50)
    private String relatedType; // ASSESSMENT, SUBMISSION, etc.

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Date createdAt;

    @Column(name = "email_sent")
    private Boolean emailSent = false;

    public Notification() {
    }

    public Notification(User user, String title, String message, String type) {
        this.user = user;
        this.title = title;
        this.message = message;
        this.type = type;
        this.isRead = false;
        this.emailSent = false;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
        if (isRead == null) {
            isRead = false;
        }
        if (emailSent == null) {
            emailSent = false;
        }
    }
}

