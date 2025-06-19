package controller.auth;

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

/**
 *
 * @author ASUS
 */
public class ChangePasswordByForget extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(); 
        String newPass = request.getParameter("password");
        String newCfPass = request.getParameter("cfpassword");

        String username = (String) session.getAttribute("userForgetPass");

        String passwordRegex = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#&()–[{}]:;',?/*~$^+=<>]).{8,20}$";

        if (!newPass.equals(newCfPass)) {
            request.setAttribute("mess2", "Password do not match.Please re-enter!");
            request.getRequestDispatcher("./changePasswordByForget.jsp").forward(request, response);
        } else {
            if (newPass.matches(passwordRegex)) {
                AccountDAO accdb = new AccountDAO();

                //String hashedPassword = BCrypt.hashpw(newPass, BCrypt.gensalt());
                accdb.updatePassword(username, newPass);
                response.sendRedirect("./changePasswordSuccess.jsp");

            } else {
                request.setAttribute("mess1", "Password must be 8 or more characters and must include uppercase letters, lowercase letters, numbers from 0 to 9 and include special characters!");
                request.getRequestDispatcher("./changePasswordByForget.jsp").forward(request, response);
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
        request.getRequestDispatcher("./changePasswordByForget.jsp").forward(request, response);
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
