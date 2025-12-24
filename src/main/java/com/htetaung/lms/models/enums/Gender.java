package com.htetaung.lms.models.enums;

public enum Gender {
    MALE,
    FEMALE;

    public static String genderToString(Gender gender){
        return switch (gender) {
            case MALE -> "Male";
            case FEMALE -> "Female";
        };
    }
}
