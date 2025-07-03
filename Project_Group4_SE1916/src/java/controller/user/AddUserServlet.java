/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.user;

import dao.RoleDAO;
import dao.UserDAO;
import Dal.DBContext;
import model.Role;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.List;

/**
 *
 * @author quanh
 */
public class AddUserServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet Add_user_servlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet Add_user_servlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
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
        request.setCharacterEncoding("UTF-8");
        try (Connection conn = DBContext.getConnection()) {
            UserDAO userDAO = new UserDAO(conn);
            RoleDAO roleDAO = new RoleDAO(conn);

            List<Role> roles = roleDAO.getAllRoles();

            request.setAttribute("roles", roles);
            request.getRequestDispatcher("/view/admin/addUser.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }

    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // Lấy dữ liệu từ form
        String code = request.getParameter("code");
        String username = request.getParameter("username");
        String fullName = request.getParameter("fullName");
        String address = request.getParameter("address");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String status = request.getParameter("status");
        String roleIdParam = request.getParameter("roleId");
        if (username == null || username.trim().isEmpty()
                || fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || status == null || status.trim().isEmpty()
                || roleIdParam == null || roleIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin bắt buộc.");
            request.getRequestDispatcher("view/admin/addUser.jsp").forward(request, response);
            return;
        }
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        if (!email.matches(emailRegex)) {
            request.setAttribute("error", "Email không hợp lệ.");
            request.getRequestDispatcher("view/admin/addUser.jsp").forward(request, response);
            return;
        }
        if (phone != null && !phone.trim().isEmpty() && !phone.matches("^\\d{10}$")) {
            request.setAttribute("error", "Số điện thoại phải gồm đúng 10 chữ số.");
            request.getRequestDispatcher("view/admin/addUser.jsp").forward(request, response);
            return;
        }
        int roleId;
        try {
            roleId = Integer.parseInt(roleIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Role ID không hợp lệ.");
            request.getRequestDispatcher("view/admin/addUser.jsp").forward(request, response);
            return;
        }
        try (Connection conn = DBContext.getConnection()) {
            UserDAO userDAO = new UserDAO(conn);
            boolean exists = userDAO.isUsernameOrEmailExists(username, email);
            if (exists) {
                request.setAttribute("error", "Username or Email existed.");
                request.getRequestDispatcher("view/admin/addUser.jsp").forward(request, response);
                return;
            }
            // Mật khẩu mặc định (chưa mã hóa)
            String defaultPassword = "123456";

            // Tạo user và set thông tin
            User user = new User();
            user.setCode(code);
            user.setUsername(username);
            user.setFullName(fullName);
            user.setAddress(address != null ? address : "");
            user.setEmail(email);
            user.setPhone(phone != null ? phone : "");
            user.setDateOfBirth((dob != null && !dob.isEmpty()) ? dob : null);
            user.setStatus(status);
            user.setPassword(defaultPassword);

            // Gọi DAO thêm user và gán role
            userDAO.insertUserWithRole(user, roleId);

            response.sendRedirect("listuser");
        } catch (Exception e) {
            throw new ServletException(e);
        }
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
