package com.htetaung.lms.utils;

import jakarta.servlet.http.HttpServletRequest;

public class RequestParameterProcessor {
    public static String getStringValue(String param, HttpServletRequest request, String defaultValue){
        String value = request.getParameter(param);
        if(value != null && !value.isEmpty()){
            return value;
        }
        Object value_object = request.getAttribute(param);
        request.removeAttribute(param);
        if(value_object != null){
            try {
                value = value_object.toString();
                return value;
            }catch (Exception e){
                return defaultValue;
            }
        }
        return defaultValue;
    }
}
