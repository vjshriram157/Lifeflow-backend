package com.bloodbank.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

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
}
