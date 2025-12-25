package com.htetaung.lms.ejbs.services;

import com.htetaung.lms.ejbs.facades.GradingFacade;
import com.htetaung.lms.exception.ScoreOverlapException;
import com.htetaung.lms.models.Grading;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import java.util.List;
import java.util.Optional;

@Stateless
public class GradingServiceFacade {

    @EJB
    private GradingFacade gradingFacade;

    public void createGrading(String gradeSymbol, Integer minScore, Integer maxScore, String operatedBy) throws ScoreOverlapException {
        try {
            validateScoreRange(minScore, maxScore);
            checkForOverlap(minScore, maxScore, null);
        }catch(ScoreOverlapException e){
            throw new ScoreOverlapException("Cannot create grading. " + e.getMessage());
        }

        Grading grading = new Grading(gradeSymbol, minScore, maxScore);
        gradingFacade.create(grading, operatedBy);
    }

    public Optional<Grading> findGradingById(Long gradingId) {
        return Optional.ofNullable(gradingFacade.find(gradingId));
    }

    public Optional<Grading> findGradingBySymbol(String gradeSymbol) {
        return gradingFacade.findByGradeSymbol(gradeSymbol);
    }

    public Optional<Grading> findGradingByScore(int score) {
        return gradingFacade.findByScore(score);
    }

    public List<Grading> getAllGradings() {
        return gradingFacade.findAllGradings();
    }

    public void updateGrading(Long gradingId, String gradeSymbol, Integer minScore, Integer maxScore, String operatedBy) throws ScoreOverlapException {
        try {
            validateScoreRange(minScore, maxScore);
            checkForOverlap(minScore, maxScore, gradingId);
        }catch(ScoreOverlapException e){
            throw new ScoreOverlapException("Cannot update grading. " + e.getMessage());
        }

        Grading grading = gradingFacade.find(gradingId);
        if (grading != null) {
            grading.setGradeSymbol(gradeSymbol);
            grading.setMinScore(minScore);
            grading.setMaxScore(maxScore);
            gradingFacade.edit(grading, operatedBy);
        }
    }

    public void deleteGrading(Long gradingId, String operatedBy) {
        Grading grading = gradingFacade.find(gradingId);
        if (grading != null) {
            gradingFacade.remove(grading, operatedBy);
        }
    }

    private void validateScoreRange(Integer minScore, Integer maxScore) throws ScoreOverlapException{
        if (minScore < 0 || maxScore < 0 || minScore > 100 || maxScore > 100 ) {
            throw new ScoreOverlapException("Scores cannot be negative");
        }
        if (minScore > maxScore) {
            throw new ScoreOverlapException("Min score cannot be greater than max score");
        }
    }

    private void checkForOverlap(Integer minScore, Integer maxScore, Long excludeGradingId) throws ScoreOverlapException{
        List<Grading> existingGradings = gradingFacade.findAllGradings();

        for (Grading existing : existingGradings) {
            if (excludeGradingId != null && existing.getGradingId().equals(excludeGradingId)) {
                continue;
            }

            if (rangesOverlap(minScore, maxScore, existing.getMinScore(), existing.getMaxScore())) {
                throw new ScoreOverlapException("Score range overlaps with existing grading: " + existing.getGradeSymbol());
            }
        }
    }

    private boolean rangesOverlap(int min1, int max1, int min2, int max2) {
        return !(max1 < min2 || max2 < min1);
    }
}
