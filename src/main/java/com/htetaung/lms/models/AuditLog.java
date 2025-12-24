package com.htetaung.lms.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "AuditLog")
public class AuditLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "entity_name")
    private String entityName;

    @Column(name = "operation")
    private String operation;

    @Column(name = "timestamp", nullable = false)
    private LocalDateTime timestamp;

    @JoinColumn(name = "operated_by", nullable = false)
    private String operatedBy;

    public AuditLog(String entityName, String operation, String operatedBy) {
        this.entityName = entityName;
        this.operation = operation;
        this.timestamp = LocalDateTime.now();
        this.operatedBy = operatedBy;
    }
}
