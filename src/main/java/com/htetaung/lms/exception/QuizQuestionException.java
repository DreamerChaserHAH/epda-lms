package com.htetaung.lms.exception;

public class QuizQuestionException extends Exception {
    public QuizQuestionException() {
        super();
    }

    public QuizQuestionException(String message) {
        super(message);
    }

    public QuizQuestionException(String message, Throwable cause) {
        super(message, cause);
    }

    public QuizQuestionException(Throwable cause) {
        super(cause);
    }
}

