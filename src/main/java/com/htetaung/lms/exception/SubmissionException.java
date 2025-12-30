package com.htetaung.lms.exception;

public class SubmissionException extends Exception {
    public SubmissionException() {
        super();
    }

    public SubmissionException(String message) {
        super(message);
    }

    public SubmissionException(String message, Throwable cause) {
        super(message, cause);
    }

    public SubmissionException(Throwable cause) {
        super(cause);
    }
}

