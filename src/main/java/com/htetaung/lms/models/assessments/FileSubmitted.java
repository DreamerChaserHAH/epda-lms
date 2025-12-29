package com.htetaung.lms.models.assessments;

import com.htetaung.lms.models.enums.FileFormats;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "file_submitted")
public class FileSubmitted {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "submission_id", nullable = false)
    private AssignmentSubmission assignmentSubmission;

    @Column(name = "file_name", nullable = false)
    private String fileName;

    @Enumerated(EnumType.STRING)
    @Column(name = "file_format", nullable = false)
    private FileFormats fileFormat;

    @Column(name = "file_path", nullable = false)
    private String filePath;
}
