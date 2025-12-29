package com.htetaung.lms.models.enums;

/// Defines visibility levels for assessments
/// - PUBLIC: Visible to all students that are enrolled to the class
/// - PROTECTED: Visible to students that the lecturer pick
/// - PRIVATE: Visible only to the lecturer and admins
public enum Visibility {
    PUBLIC,
    PROTECTED,
    PRIVATE
}
