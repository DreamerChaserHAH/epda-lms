package com.htetaung.lms.models.dto;

import com.htetaung.lms.models.assessments.FileSubmitted;
import com.htetaung.lms.models.enums.FileFormats;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class FileSubmittedDTO {
    private Long id;
    private String fileName;
    private FileFormats fileFormat;
    private String filePath;

    public FileSubmittedDTO(FileSubmitted file) {
        this.id = file.getId();
        this.fileName = file.getFileName();
        this.fileFormat = file.getFileFormat();
        this.filePath = file.getFilePath();
    }
}

