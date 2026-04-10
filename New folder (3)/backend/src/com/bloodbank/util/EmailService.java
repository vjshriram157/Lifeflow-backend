package com.bloodbank.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;

public class EmailService {

    // ⚠️ IMPORTANT: You must replace these with your actual Gmail and App Password!
    // For Gmail, you must enable 2-Step Verification and generate an "App Password"
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String USERNAME = "vijay.shriram157@gmail.com"; 
    private static final String PASSWORD = "nvukgmzdvpgbszmy";

    public static void sendOtpEmail(String toAddress, String otp) {
        System.out.println("Attempting to send real OTP email to: " + toAddress);
        System.out.println("=====================================================");
        System.out.println("🔑 [LOCAL FALLBACK] GENERATED OTP FOR " + toAddress + ": " + otp);
        System.out.println("=====================================================");

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
            message.setSubject("LifeFlow - Your Password Reset OTP");
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 20px; color: #333;'>"
                    + "<h2 style='color: #e11d48;'>LifeFlow Password Reset</h2>"
                    + "<p>You recently requested to reset your password. Use the following OTP to complete the process:</p>"
                    + "<h1 style='background: #f1f5f9; padding: 15px; border-radius: 8px; letter-spacing: 5px; text-align: center; color: #0f172a;'>" + otp + "</h1>"
                    + "<p style='font-size: 0.9em; color: #666;'>If you did not make this request, please ignore this email.</p>"
                    + "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ Real OTP email sent successfully to " + toAddress);
        } catch (MessagingException e) {
            System.err.println("❌ Failed to send email. Ensure your Gmail App Password is correct.");
            e.printStackTrace();
        }
    }

    public static void sendRegistrationCompleteEmail(String toAddress, String fullName) {
        CompletableFuture.runAsync(() -> {
            System.out.println("Attempting to send Registration Confirmation email to: " + toAddress);

            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USERNAME, PASSWORD);
                }
            });

            try {
                Message message = new MimeMessage(session);
                message.setFrom(new InternetAddress(USERNAME));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
                message.setSubject("Welcome to LifeFlow!");

                String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 20px; color: #333;'>"
                        + "<h2 style='color: #e11d48;'>Welcome to LifeFlow!</h2>"
                        + "<p>Hi <b>" + fullName + "</b>,</p>"
                        + "<p>Your registration is complete. Welcome to the LifeFlow family!</p>"
                        + "<p>Thank you for taking a step towards saving lives by joining our blood donation community.</p>"
                        + "<br><p>Best Regards,</p>"
                        + "<p><b>The LifeFlow Team</b></p>"
                        + "</div>";

                message.setContent(htmlBody, "text/html");
                Transport.send(message);
                System.out.println("✅ Registration confirmation email sent to " + toAddress);
            } catch (MessagingException e) {
                System.err.println("❌ Failed to send registration email to " + toAddress);
                e.printStackTrace();
            }
        });
    }

    public static void sendEmergencyRequestEmail(String toAddress, String fullName, String bloodGroup, String requestMessage) {
        CompletableFuture.runAsync(() -> {
            System.out.println("Attempting to send Emergency Request email to: " + toAddress);

            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USERNAME, PASSWORD);
                }
            });

            try {
                Message message = new MimeMessage(session);
                message.setFrom(new InternetAddress(USERNAME));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
                message.setSubject("🚨 Urgent Blood Request: " + bloodGroup + " Needed!");

                String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 20px; color: #333;'>"
                        + "<h2 style='color: #e11d48;'>🚨 Urgent Blood Request</h2>"
                        + "<p>Hi <b>" + fullName + "</b>,</p>"
                        + "<p>There is an urgent need for <b>" + bloodGroup + "</b> blood near you.</p>"
                        + "<p style='padding: 15px; border-left: 4px solid #e11d48; background: #fff1f2;'>"
                        + requestMessage + "</p>"
                        + "<p>If you are eligible and available to donate, please check the LifeFlow app for more details and help save a life!</p>"
                        + "<br><p>Thank you,</p>"
                        + "<p><b>The LifeFlow Team</b></p>"
                        + "</div>";

                message.setContent(htmlBody, "text/html");
                Transport.send(message);
                System.out.println("✅ Emergency alert email sent to " + toAddress);
            } catch (MessagingException e) {
                System.err.println("❌ Failed to send emergency email to " + toAddress);
                e.printStackTrace();
            }
        });
    }
}
