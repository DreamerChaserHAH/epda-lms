package com.htetaung.lms.models;

import com.htetaung.lms.models.assessments.Assessment;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name="Class")
public class Class {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="class_id")
    private Long classId;

    @ManyToOne
    @JoinColumn(name="module_id", nullable=false)
    private Module module;

    @Column(name="class_name", nullable=false)
    private String className;

    @ManyToMany
    @JoinTable(
            name = "class_enrollment",
            joinColumns = @JoinColumn(name = "class_id"),
            inverseJoinColumns = @JoinColumn(name = "user_id")
    )
    private List<Student> enrolledStudents = new ArrayList<>();

    @OneToMany(mappedBy = "relatedClass", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Assessment> assessments = new ArrayList<>(); // All assessments for this class

    public Class(Module module, String className) {
        this.module = module;
        this.className = className;
        this.enrolledStudents = new ArrayList<>();
    }

    public void AddStudent(Student student) {
        this.enrolledStudents.add(student);
    }

    public void RemoveStudent(Student student) {
        this.enrolledStudents.remove(student);
    }
}
