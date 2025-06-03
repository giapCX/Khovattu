//changepass.java
package controller;

import dao.AccountDAO;
import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.User;
import org.mindrot.jbcrypt.BCrypt;

public class ChangePassword extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String newPass = request.getParameter("password");
        String newCfPass = request.getParameter("cfpassword");
//        Account acc =  (Account) request.getSession().getAttribute("accountForgetPass");
//        String username = acc.getUsername();

        String username = (String) session.getAttribute("username");
//        UserDAO userDAO = new UserDAO();
//        String roleName = userDAO.getUserRoleName(username);
//        session.setAttribute("role", roleName);

        String passwordRegex = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#&()–[{}]:;',?/*~$^+=<>]).{8,20}$";

        AccountDAO accdb = new AccountDAO();
        String oldHashedPassword = accdb.getPasswordByUsername(username); // Lấy mật khẩu hiện tại
        if (!newPass.equals(newCfPass)) {
            request.setAttribute("mess2", "Password do not match.Please re-enter");
            request.getRequestDispatcher("./changePassword.jsp").forward(request, response);
        } //        else if (newPass.equals(oldPassword)) {
        //            request.setAttribute("mess2", "New password cannot be the same as old password!");
        //            request.getRequestDispatcher("./changePassword.jsp").forward(request, response);
        //        }
        else if (BCrypt.checkpw(newPass, oldHashedPassword)) {
            request.setAttribute("mess2", "New password cannot be the same as old password!");
            request.getRequestDispatcher("./changePassword.jsp").forward(request, response);

        } else {
            if (newPass.matches(passwordRegex)) {
//                AccountDAO accdb = new AccountDAO();
                //String hashedPassword = BCrypt.hashpw(newPass, BCrypt.gensalt());

                accdb.updatePassword(username, newPass);
                response.sendRedirect("./changePasswordSuccess.jsp");

            } else {
                request.setAttribute("mess1", "Password must be 8 or more characters and must include uppercase letters, lowercase letters, numbers from 0 to 9 and include special characters!");
                request.getRequestDispatcher("./changePassword.jsp").forward(request, response);
            }

        }

    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("./changePassword.jsp").forward(request, response);
    }

    /**
     * * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
