package com.htetaung.lms.models.enums;

public enum FileFormats {
    PDF,
    DOCX,
    TXT,
    ZIP,
    RAR;

    public static String toString(FileFormats fileFormat) {
        return switch (fileFormat) {
            case PDF -> ".pdf";
            case DOCX -> ".docx";
            case TXT -> ".txt";
            case ZIP -> ".zip";
            case RAR -> ".rar";
            default -> "UNKNOWN";
        };
    }
}
