package controller.user;

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
        // Chuyển tiếp yêu cầu GET đến trang login.jsp để hiển thị form đăng nhập
        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
        rd.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try (Connection conn = DBContext.getConnection()) {
            // Lấy username và password từ form đăng nhập
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            // Tạo instance UserDAO với kết nối cơ sở dữ liệu
            UserDAO userDAO = new UserDAO(conn);
            
            // Lấy thông tin người dùng từ cơ sở dữ liệu dựa trên username
            User foundAccount = userDAO.getUserByUsername(username);
            
            // Kiểm tra nếu tài khoản tồn tại
            if (foundAccount != null) {
                // Kiểm tra trạng thái tài khoản (active hoặc inactive)
                if (!"active".equalsIgnoreCase(foundAccount.getStatus())) {
                    // Nếu trạng thái không phải là active, trả về lỗi
                    request.setAttribute("error", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.");
                    RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                    rd.forward(request, response);
                    return;
                }

                // Lấy mật khẩu đã mã hóa từ tài khoản
                String storedHashedPassword = foundAccount.getPassword();
                // Kiểm tra định dạng mật khẩu có hợp lệ (bắt đầu bằng "$2a$" của BCrypt)
                if (storedHashedPassword != null && storedHashedPassword.startsWith("$2a$")) {
                    // So sánh mật khẩu nhập vào với mật khẩu đã mã hóa
                    if (BCrypt.checkpw(password, storedHashedPassword)) {
                        // Tạo session và lưu thông tin người dùng
                        HttpSession session = request.getSession();
                        session.setAttribute("username", foundAccount.getUsername());
                        session.setAttribute("userId", foundAccount.getUserId());
                        session.setAttribute("userFullName", foundAccount.getFullName());
                        session.setAttribute("role", userDAO.getRoleNameByUsername(username));
                        // Đặt thời gian sống của session là 30 phút
                        session.setMaxInactiveInterval(30 * 60);

                        // Lấy tên vai trò của người dùng
                        String roleName = userDAO.getRoleNameByUsername(username);
                        
                        // Chuyển hướng đến dashboard tương ứng với vai trò
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
                        // Nếu mật khẩu không đúng, trả về lỗi
                        request.setAttribute("error", "Tên người dùng hoặc mật khẩu không đúng.");
                        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                        rd.forward(request, response);
                    }
                } else {
                    // Nếu mật khẩu trong cơ sở dữ liệu không hợp lệ
                    request.setAttribute("error", "Mật khẩu trong cơ sở dữ liệu không hợp lệ. Vui lòng liên hệ quản trị viên.");
                    RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                    rd.forward(request, response);
                }
            } else {
                // Nếu không tìm thấy tài khoản
                request.setAttribute("error", "Tên người dùng hoặc mật khẩu không đúng.");
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);
            }
        } catch (Exception e) {
            // Xử lý ngoại lệ và ném ServletException
            throw new ServletException("Lỗi đăng nhập: " + e.getMessage(), e);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet xử lý đăng nhập với mã hóa mật khẩu bằng BCrypt.";
    }
}