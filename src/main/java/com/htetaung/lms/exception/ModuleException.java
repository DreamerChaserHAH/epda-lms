package com.htetaung.lms.exception;

import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = false)
public class ModuleException extends Exception {

    public ModuleException(String message) {
        super(message);
    }

    public ModuleException(String message, Throwable cause) {
        super(message, cause);
    }
}
