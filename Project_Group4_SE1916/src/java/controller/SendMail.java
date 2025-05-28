/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Properties;
import java.util.Random;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import model.User;


public class SendMail extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User newUser = (User) session.getAttribute("userForgetPass");

        if (newUser == null) {
            setErrorAndForward(req, resp, "Đã xảy ra lỗi. Vui lòng thử lại.");
            return;
        }

        String recipient = newUser.getEmail();
        String regexEmail = "\\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\\b";

        if (recipient.matches(regexEmail)) {
            String verifyCode = getRandomNumberString();
            String message = messageProcess(verifyCode);

            HttpSession verifySession = req.getSession();
            verifySession.setAttribute("verifyCode", verifyCode);
            verifySession.setMaxInactiveInterval(2 * 60);

            try {
                sendEmail(recipient, message);
                req.getRequestDispatcher("/forgetPassword/confirmEmail.jsp").forward(req, resp);
            } catch (MessagingException e) {
                setErrorAndForward(req, resp, "Chúng tôi không thể gửi mã code đến email của bạn.");
            }
        } else {
            setErrorAndForward(req, resp, "Email không hợp lệ.");
        }
    }

    private void sendEmail(String recipient, String message) throws MessagingException {
        String host = "smtp.gmail.com";
        String user = System.getenv("EMAIL_USER"); // Use environment variable
        String password = System.getenv("EMAIL_PASSWORD"); // Use environment variable

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", "587");

        Session mailSession = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, password);
            }
        });

        Message msg = new MimeMessage(mailSession);
        msg.setFrom(new InternetAddress(user));
        msg.setRecipient(Message.RecipientType.TO, new InternetAddress(recipient));
        msg.setSubject("Account Verification");
        msg.setText(message);

        javax.mail.Transport.send(msg);
    }

    private void setErrorAndForward(HttpServletRequest req, HttpServletResponse resp, String message)
    throws ServletException, IOException {
        req.setAttribute("mess", message);
        req.getRequestDispatcher("/forgetPassword/forgetPassword.jsp").forward(req, resp);
    }

    public static String getRandomNumberString() {
        Random rnd = new Random();
        int number = rnd.nextInt(999999);
        return String.format("%06d", number);
    }

    public static String messageProcess(String verifyCode) {
        return "Xin chào,\n" +
                "Đây là mã xác nhận quên mật khẩu, không chia sẻ mã code cho bất kỳ ai. " +
                "Nếu bạn không thực hiện hành động này, vui lòng bỏ qua email. " +
                "Mã xác nhận của bạn là: " + verifyCode;
    }
}

