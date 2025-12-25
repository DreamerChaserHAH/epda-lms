package com.htetaung.lms.exception;

import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = false)
public class ScoreOverlapException extends Exception {

    public ScoreOverlapException(String message) {
        super(message);
    }

    public ScoreOverlapException(String message, Throwable cause) {
        super(message, cause);
    }
}
