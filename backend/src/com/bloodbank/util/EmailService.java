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

    public static void sendEmergencyBroadcastEmail(java.util.List<String> bccEmails, String bloodGroup, String facilityName, String emergencyMessage) {
        if (bccEmails == null || bccEmails.isEmpty()) return;
        
        System.out.println("Attempting to send EMERGENCY email broadcast to " + bccEmails.size() + " donors.");

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
            message.setFrom(new InternetAddress(USERNAME, "LifeFlow Emergency Center"));
            
            // Set all donors as BCC to protect their privacy
            InternetAddress[] bccAddresses = new InternetAddress[bccEmails.size()];
            for (int i = 0; i < bccEmails.size(); i++) {
                bccAddresses[i] = new InternetAddress(bccEmails.get(i));
            }
            message.setRecipients(Message.RecipientType.BCC, bccAddresses);
            
            // So the 'To' field isn't completely blank, set it to the system email
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(USERNAME));
            
            message.setSubject("🚨 URGENT: " + bloodGroup + " Blood Needed Immediately at " + facilityName);
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #e11d48; border-radius: 8px;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h1 style='color: #e11d48; margin: 0;'>CRITICAL DEMAND</h1>"
                    + "  <p style='color: #666; font-size: 1.2em; margin-top: 5px;'>Your community needs you.</p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em;'>Dear Donor,</p>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>A medical emergency has resulted in a critical shortage of <strong>" + bloodGroup + "</strong> blood. Because you are uniquely positioned to help, we are contacting you immediately.</p>"
                    + "<div style='background: #fee2e2; border-left: 4px solid #ef4444; padding: 15px; margin: 25px 0;'>"
                    + "  <p style='margin: 0; font-size: 1.1em; color: #7f1d1d;'><strong>Facility:</strong> " + facilityName + "</p>"
                    + "  <p style='margin: 10px 0 0 0; font-size: 1.0em; color: #991b1b;'><em>\"" + (emergencyMessage != null ? emergencyMessage : "Urgent stock required to handle trauma/surgical event.") + "\"</em></p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>If you are healthy and able to donate, please proceed to the facility or open your LifeFlow App to book a fast-track appointment.</p>"
                    + "<div style='text-align: center; margin-top: 30px;'>"
                    + "  <a href='http://localhost:9090/blood-bank/login.jsp' style='background-color: #e11d48; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 1.1em;'>Respond to Request</a>"
                    + "</div>"
                    + "<p style='font-size: 0.8em; color: #999; margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px; text-align: center;'>This is an automated emergency broadcast generated by the LifeFlow Medical Grid.</p>"
                    + "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ EMERGENCY Email broadcast successfully sent to " + bccEmails.size() + " donors.");
        } catch (Exception e) {
            System.err.println("❌ Failed to broadcast emergency email.");
            e.printStackTrace();
        }
    }
}
