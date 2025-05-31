package controller;

import Dal.DBContext;
import dao.UserDAO;
import jakarta.servlet.RequestDispatcher;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
        rd.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try (Connection conn = DBContext.getConnection()) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            UserDAO userDAO = new UserDAO(conn);
            
            User foundAccount = userDAO.getUserByUsername(username);
            
            if (foundAccount != null) {
                String storedHashedPassword = foundAccount.getPassword();
                if (storedHashedPassword != null && storedHashedPassword.startsWith("$2a$")) {
                    if (BCrypt.checkpw(password, storedHashedPassword)) {
                        HttpSession session = request.getSession();
                        session.setAttribute("username", foundAccount.getUsername());
                        session.setAttribute("role", userDAO.getRoleNameByUsername(username));
                        session.setMaxInactiveInterval(30 * 60);

                        String roleName = userDAO.getRoleNameByUsername(username);
                        
                        switch (roleName) {
                            case "admin":
                                response.sendRedirect("view/admin/adminDashboard.jsp");
                                break;
                            case "direction":
                                response.sendRedirect("view/direction/directionDashboard.jsp");
                                break;
                            case "warehouse":
                                response.sendRedirect("view/warehouse/warehouseDashboard.jsp");
                                break;
                            case "employee":
                                response.sendRedirect("view/employee/employeeDashboard.jsp");
                                break;
                            default:
                                response.sendRedirect("login.jsp");
                                break;
                        }
                    } else {
                        request.setAttribute("error", "Tên người dùng hoặc mật khẩu không đúng.");
                        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                        rd.forward(request, response);
                    }
                } else {
                    request.setAttribute("error", "Mật khẩu trong cơ sở dữ liệu không hợp lệ. Vui lòng liên hệ quản trị viên.");
                    RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                    rd.forward(request, response);
                }
            } else {
                request.setAttribute("error", "Tên người dùng hoặc mật khẩu không đúng.");
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi đăng nhập: " + e.getMessage(), e);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet xử lý đăng nhập với mã hóa mật khẩu bằng BCrypt";
    }
}