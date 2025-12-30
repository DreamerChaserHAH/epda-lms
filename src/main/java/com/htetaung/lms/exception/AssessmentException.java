package com.htetaung.lms.exception;

import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = false)
public class AssessmentException extends Exception {

    public AssessmentException(String message) {
        super(message);
    }

    public AssessmentException(String message, Throwable cause) {
        super(message, cause);
    }
}
