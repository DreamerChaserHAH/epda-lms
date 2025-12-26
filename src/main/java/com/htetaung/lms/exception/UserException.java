package com.htetaung.lms.exception;

import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = false)
public class UserException extends Exception {

    public UserException(String message) {
        super(message);
    }

    public UserException(String message, Throwable cause) {
        super(message, cause);
    }
}
