//forgetPass
package controller.auth;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.AccountDAO;
import dao.UserDAO;
import java.io.IOException;
import java.util.Properties;
import java.util.Random;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import model.Account;
import model.User;

public class ForgetPassword extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("./forgetPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("Email");
        HttpSession session = request.getSession();

        if (email == null) {
            setErrorAndForward(request, response, "Please enter a valid email!");
            return;
        }

        User user = getUserByEmail(email);
        if (user == null) {
            setErrorAndForward(request, response, "Email not found, please check and try again!");
            return;
        }

        String username = user.getUsername();
        Account account = getAccountByUsername(username);
        if (account == null) {
            setErrorAndForward(request, response, "Account not found for this email!");
            return;
        }

        // Generate a new password
        String newPassword = generateRandomPassword(8);

        // Update the password in the database
        //updatePassword(username, newPassword);

        // Send the new password via email
        if (!sendEmail(email, newPassword)) {
            setErrorAndForward(request, response, "Failed to send email. Please try again.");
            return;
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("../forgetPassword/confirmEmail.jsp");
        request.setAttribute("message", "A new password has been sent to your email.");
        session.setAttribute("passGen", newPassword);
        session.setAttribute("userForgetPass", username);
        session.setAttribute("email", email);
        session.setMaxInactiveInterval(300);
        dispatcher.forward(request, response);
    }

    private Account getAccountByUsername(String username) {
        AccountDAO accountDB = new AccountDAO();
        try {
            return accountDB.checkAccountExisted(username);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private User getUserByEmail(String email) {
        UserDAO userDB = new UserDAO();
        try {
            return userDB.getUserByEmail(email);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void updatePassword(String username, String newPassword) {
        AccountDAO accountDB = new AccountDAO();
        accountDB.updatePassword(username, newPassword);
    }

    private boolean sendEmail(String to, String newPassword) {
        String from = "Ngtungduong04@gmail.com";
        String host = "smtp.gmail.com";
        String port = "587";
        String authPassword = "khxx zrrf jadi eize"; // Use a secure method to store this

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        Session emailSession = Session.getDefaultInstance(props, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(from, authPassword);
            }
        });

        try {
            MimeMessage message = new MimeMessage(emailSession);
            message.setFrom(new InternetAddress(from));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
            message.setSubject("Reset Password");
            message.setText("This is your verify code: " + newPassword + "\nPlease change your password.");
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void setErrorAndForward(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("mess", message);
        request.getRequestDispatcher("./forgetPassword.jsp").forward(request, response);
    }

    private String generateRandomPassword(int length) {
        String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random rand = new Random();
        StringBuilder password = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            password.append(characters.charAt(rand.nextInt(characters.length())));
        }
        return password.toString();
    }

    @Override
    public String getServletInfo() {
        return "Forget Password Servlet";
    }
}
