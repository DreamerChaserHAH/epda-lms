package com.htetaung.lms.models.enums;

public enum UserRole {
    STUDENT, LECTURER, ACADEMIC_LEADER, ADMIN;

    public static String roleToString(UserRole role) {
        return switch (role) {
            case STUDENT -> "Student";
            case LECTURER -> "Lecturer";
            case ACADEMIC_LEADER -> "Academic Leader";
            case ADMIN -> "Admin";
        };
    }
}
