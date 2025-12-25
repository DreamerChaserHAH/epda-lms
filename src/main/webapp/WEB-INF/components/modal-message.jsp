<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.enums.ModalMessageType" %>
<%
    String messageTypeObject = (String) session.getAttribute("messageType");
    String message = (String) session.getAttribute("messageContent");

    ModalMessageType messageType = null;
    try {
        if(messageTypeObject == null){
            return;
        }
        messageType = ModalMessageType.valueOf(messageTypeObject);
    } catch (IllegalArgumentException e) {
        return;
    }

    if (messageType != null && message != null && !message.isEmpty()) {
        String alertClass = "";
        String iconPath = "";

        switch (messageType) {
            case SUCCESS:
                alertClass = "alert-success";
                iconPath = "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z";
                break;
            case ERROR:
                alertClass = "alert-error";
                iconPath = "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z";
                break;
            case WARNING:
                alertClass = "alert-warning";
                iconPath = "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z";
                break;
            case INFO:
                alertClass = "alert-info";
                iconPath = "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z";
                break;
            default:
                alertClass = "alert-info";
                iconPath = "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z";
        }
%>
<div role="alert" class="alert <%= alertClass %> fixed bottom-0 left-0 right-0 w-full rounded-none z-50 m-0">
    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="<%= iconPath %>" />
    </svg>
    <span><%= message %></span>
</div>
<%
        session.removeAttribute("messageType");
        session.removeAttribute("messageContent");
    }
%>
