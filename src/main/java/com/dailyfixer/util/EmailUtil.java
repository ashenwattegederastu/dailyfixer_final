package com.dailyfixer.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;


public class EmailUtil {
    private static final String FROM_EMAIL;
    private static final String PASSWORD;

    static {
        Properties config = new Properties();
        try (InputStream input = EmailUtil.class.getClassLoader()
                .getResourceAsStream("config.properties")) {
            if (input != null) config.load(input);
        } catch (IOException e) {
            System.err.println("ERROR loading config.properties: " + e.getMessage());
        }
        FROM_EMAIL = config.getProperty("email.from", "");
        PASSWORD = config.getProperty("email.password", "");
    }

    public static void sendEmail(String toEmail, String subject, String body) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(body, "text/html");

        Transport.send(message);
    }
}

