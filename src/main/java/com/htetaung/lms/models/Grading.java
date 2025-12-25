package com.htetaung.lms.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "Grading")
public class Grading {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "grading_id")
    private Long gradingId;

    @Column(name = "grade_symbol", nullable = false, length = 10)
    private String gradeSymbol;

    @Column(name = "min_score", nullable = false)
    private Integer minScore;

    @Column(name = "max_score", nullable = false)
    private Integer maxScore;

    public Grading(String gradeSymbol, Integer minScore, Integer maxScore) {
        this.gradeSymbol = gradeSymbol;
        this.minScore = minScore;
        this.maxScore = maxScore;
    }
}
