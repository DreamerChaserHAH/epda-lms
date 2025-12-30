package com.htetaung.lms.ejbs;

import com.htetaung.lms.models.dto.QuizIndividualQuestionDTO;
import jakarta.ejb.Remove;
import jakarta.ejb.Stateful;
import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Stateful
public class QuizSessionBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long assessmentId;
    private Long studentId;
    private List<QuizIndividualQuestionDTO> questions;
    private Map<Long, Integer> answers; // questionId -> selectedOptionIndex
    private int currentQuestionIndex;
    private long startTime;

    public QuizSessionBean() {
        this.answers = new HashMap<>();
        this.currentQuestionIndex = 0;
        this.startTime = System.currentTimeMillis();
    }

    public void initializeQuiz(Long assessmentId, Long studentId, List<QuizIndividualQuestionDTO> questions) {
        this.assessmentId = assessmentId;
        this.studentId = studentId;
        this.questions = questions;
        this.currentQuestionIndex = 0;
        this.answers.clear();
        this.startTime = System.currentTimeMillis();
    }

    public QuizIndividualQuestionDTO getCurrentQuestion() {
        if (questions == null || questions.isEmpty() || currentQuestionIndex >= questions.size()) {
            return null;
        }
        return questions.get(currentQuestionIndex);
    }

    public void answerCurrentQuestion(Integer selectedOption) {
        if (questions != null && currentQuestionIndex < questions.size()) {
            QuizIndividualQuestionDTO currentQuestion = questions.get(currentQuestionIndex);
            answers.put(currentQuestion.getQuizQuestionId(), selectedOption);
        }
    }

    public boolean hasNextQuestion() {
        return questions != null && (currentQuestionIndex + 1) < questions.size();
    }

    public boolean hasPreviousQuestion() {
        return currentQuestionIndex > 0;
    }

    public void moveToNextQuestion() {
        if (hasNextQuestion()) {
            currentQuestionIndex++;
        }
    }

    public void moveToPreviousQuestion() {
        if (hasPreviousQuestion()) {
            currentQuestionIndex--;
        }
    }

    public void moveToQuestion(int index) {
        if (questions != null && index >= 0 && index < questions.size()) {
            currentQuestionIndex = index;
        }
    }

    public Integer getAnswerForCurrentQuestion() {
        QuizIndividualQuestionDTO current = getCurrentQuestion();
        if (current != null) {
            return answers.get(current.getQuizQuestionId());
        }
        return null;
    }

    public Integer getAnswerForQuestion(Long questionId) {
        return answers.get(questionId);
    }

    public boolean isQuestionAnswered(int questionIndex) {
        if (questions == null || questionIndex >= questions.size()) {
            return false;
        }
        Long questionId = questions.get(questionIndex).getQuizQuestionId();
        return answers.containsKey(questionId);
    }

    public boolean areAllQuestionsAnswered() {
        if (questions == null || questions.isEmpty()) {
            return false;
        }
        return answers.size() == questions.size();
    }

    public int getAnsweredQuestionsCount() {
        return answers.size();
    }

    public int getTotalQuestionsCount() {
        return questions != null ? questions.size() : 0;
    }

    public int getCurrentQuestionIndex() {
        return currentQuestionIndex;
    }

    public int getCurrentQuestionNumber() {
        return currentQuestionIndex + 1;
    }

    public Map<Long, Integer> getAllAnswers() {
        return new HashMap<>(answers);
    }

    public Long getAssessmentId() {
        return assessmentId;
    }

    public Long getStudentId() {
        return studentId;
    }

    public List<QuizIndividualQuestionDTO> getAllQuestions() {
        return questions;
    }

    public long getElapsedTimeInSeconds() {
        return (System.currentTimeMillis() - startTime) / 1000;
    }

    public double getProgressPercentage() {
        if (questions == null || questions.isEmpty()) {
            return 0.0;
        }
        return (answers.size() * 100.0) / questions.size();
    }

    @Remove
    public void completeQuiz() {
        // This method will be called to remove the stateful bean after quiz submission
        this.questions = null;
        this.answers.clear();
    }

    public boolean isQuizInitialized() {
        return questions != null && !questions.isEmpty();
    }
}

