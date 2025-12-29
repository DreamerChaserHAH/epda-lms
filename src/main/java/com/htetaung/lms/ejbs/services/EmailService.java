package com.htetaung.lms.ejbs.services;

import jakarta.ejb.Stateless;
// Note: jakarta.mail dependency needs to be added to pom.xml for email functionality
// For now, email sending is disabled. Uncomment and add dependency when ready.
// import jakarta.mail.*;
// import jakarta.mail.internet.InternetAddress;
// import jakarta.mail.internet.MimeMessage;

import java.util.logging.Logger;

@Stateless
public class EmailService {

    private static final Logger logger = Logger.getLogger(EmailService.class.getName());

    public boolean sendEmail(String toEmail, String subject, String body) {
        // Email functionality disabled until jakarta.mail dependency is added
        // To enable: Add jakarta.mail dependency to pom.xml and uncomment the code below
        logger.info("Email sending disabled. Would send to: " + toEmail + " - Subject: " + subject);
        return false;
        
        /* Uncomment when jakarta.mail is available:
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USER, SMTP_PASSWORD);
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(body, "text/html; charset=utf-8");

            Transport.send(message);
            logger.info("Email sent successfully to: " + toEmail);
            return true;
        } catch (MessagingException e) {
            logger.log(Level.SEVERE, "Error sending email to " + toEmail, e);
            return false;
        }
        */
    }

    public void sendNotificationEmail(String toEmail, String notificationType, String title, String message, String link) {
        String subject = "LMS Notification: " + title;
        String body = buildEmailBody(notificationType, title, message, link);
        sendEmail(toEmail, subject, body);
    }

    private String buildEmailBody(String type, String title, String message, String link) {
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html><html><head><meta charset='UTF-8'>");
        html.append("<style>body{font-family:Arial,sans-serif;line-height:1.6;color:#333;}");
        html.append(".container{max-width:600px;margin:0 auto;padding:20px;}");
        html.append(".header{background-color:#2563eb;color:white;padding:20px;text-align:center;}");
        html.append(".content{padding:20px;background-color:#f9fafb;}");
        html.append(".button{display:inline-block;padding:10px 20px;background-color:#2563eb;color:white;text-decoration:none;border-radius:5px;margin-top:10px;}");
        html.append(".footer{padding:20px;text-align:center;color:#6b7280;font-size:12px;}</style></head><body>");
        html.append("<div class='container'>");
        html.append("<div class='header'><h2>APU Learning Management System</h2></div>");
        html.append("<div class='content'>");
        html.append("<h3>").append(escapeHtml(title)).append("</h3>");
        html.append("<p>").append(escapeHtml(message)).append("</p>");
        if (link != null && !link.isEmpty()) {
            html.append("<a href='").append(link).append("' class='button'>View Details</a>");
        }
        html.append("</div>");
        html.append("<div class='footer'>This is an automated notification. Please do not reply to this email.</div>");
        html.append("</div></body></html>");
        return html.toString();
    }

    private String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#39;");
    }
}

