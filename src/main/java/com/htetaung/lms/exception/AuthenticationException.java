package com.htetaung.lms.exception;

import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = false)
public class AuthenticationException extends Exception {

    public AuthenticationException(String message) {
        super(message);
    }

    public AuthenticationException(String message, Throwable cause) {
        super(message, cause);
    }
}

