package com.htetaung.lms.utils;

import jakarta.servlet.http.HttpServletRequest;

public class MessageModal {
    public static final String MESSAGE_TYPE_SUCCESS = "SUCCESS";
    public static final String MESSAGE_TYPE_ERROR = "ERROR";

    public static final String MESSAGE_TYPE_WARNING = "WARNING";

    public static final String MESSAGE_TYPE_INFO = "INFO";

    public static void DisplaySuccessMessage(String content, HttpServletRequest request){
        request.getSession().setAttribute("messageType", MESSAGE_TYPE_SUCCESS);
        request.getSession().setAttribute("messageContent", content);
    }

    public static void DisplayWarningMessage(String content, HttpServletRequest request){
        request.getSession().setAttribute("messageType", MESSAGE_TYPE_WARNING);
        request.getSession().setAttribute("messageContent", content);
    }

    public static void DisplayErrorMessage(String content, HttpServletRequest request){
        request.getSession().setAttribute("messageType", MESSAGE_TYPE_ERROR);
        request.getSession().setAttribute("messageContent", content);
    }

    public static void DisplayInfoMessage(String content, HttpServletRequest request){
        request.getSession().setAttribute("messageType", MESSAGE_TYPE_INFO);
        request.getSession().setAttribute("messageContent", content);
    }
}
