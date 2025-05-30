package controller;

import Dal.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("username");
        System.out.println("doGet: Username from session: " + username);
        if (username == null) {
            System.out.println("doGet: Redirecting to login.jsp due to null username");
            response.sendRedirect("login.jsp");
            return;
        }

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            System.out.println("doGet: Connection status: " + (conn != null ? "Connected" : "Null"));
            if (conn == null) {
                System.out.println("doGet: Database connection is null!");
                request.setAttribute("error", "Không thể kết nối cơ sở dữ liệu.");
                request.getRequestDispatcher("userProfile.jsp").forward(request, response);
                return;
            }

            String sql = "SELECT u.*, r.role_name FROM users u "
                    + "LEFT JOIN roles r ON u.role_id = r.role_id "
                    + "WHERE u.username = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, username);
                System.out.println("doGet: Executing query for username: " + username);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    System.out.println("doGet: User found: " + rs.getString("username"));
                    request.setAttribute("userId", rs.getInt("user_id"));
                    // ... (các setAttribute khác)
                } else {
                    System.out.println("doGet: No user found for username: " + username);
                    request.setAttribute("error", "Không tìm thấy người dùng.");
                }
            }
        } catch (SQLException e) {
            System.out.println("doGet: SQLException: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("doGet: Error closing connection: " + e.getMessage());
                }
            }
        }
        System.out.println("doGet: Forwarding to userProfile.jsp");
        request.getRequestDispatcher("userProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("username");
        System.out.println("doPost: Post request for username: " + username);
        if (username == null) {
            System.out.println("doPost: Redirecting to login.jsp due to null username");
            response.sendRedirect("login.jsp");
            return;
        }

        String fullName = request.getParameter("fullName");
        String address = request.getParameter("address");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String img = request.getParameter("img");

        System.out.printf("doPost parameters: fullName=%s, address=%s, email=%s, phone=%s, dateOfBirth=%s, img=%s%n",
                fullName, address, email, phone, dateOfBirth, img);

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            if (conn == null) {
                System.out.println("doPost: Database connection failed.");
                request.setAttribute("error", "Không thể kết nối cơ sở dữ liệu.");
                request.getRequestDispatcher("userProfile.jsp").forward(request, response);
                return;
            }

            String sql = "UPDATE users SET full_name = ?, address = ?, email = ?, phone_number = ?, date_of_birth = ?, imageUrl = ? WHERE username = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, fullName);
                stmt.setString(2, address);
                stmt.setString(3, email);
                stmt.setString(4, phone != null && !phone.isEmpty() ? phone : null);
                stmt.setString(5, dateOfBirth != null && !dateOfBirth.isEmpty() ? dateOfBirth : null);
                stmt.setString(6, img != null && !img.isEmpty() ? img : null);
                stmt.setString(7, username);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    System.out.println("doPost: Profile updated successfully for username: " + username);
                    request.setAttribute("message", "Cập nhật hồ sơ thành công!");
                } else {
                    System.out.println("doPost: No rows affected for username: " + username);
                    request.setAttribute("error", "Không thể cập nhật hồ sơ. Vui lòng kiểm tra lại.");
                }
            }

            String fetchSql = "SELECT u.*, r.role_name FROM users u "
                    + "LEFT JOIN roles r ON u.role_id = r.role_id "
                    + "WHERE u.username = ?";
            try (PreparedStatement stmt = conn.prepareStatement(fetchSql)) {
                stmt.setString(1, username);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    request.setAttribute("userId", rs.getInt("user_id"));
                    request.setAttribute("code", rs.getString("code"));
                    request.setAttribute("username", rs.getString("username"));
                    request.setAttribute("fullName", rs.getString("full_name"));
                    request.setAttribute("address", rs.getString("address"));
                    request.setAttribute("email", rs.getString("email"));
                    request.setAttribute("phone", rs.getString("phone_number"));
                    request.setAttribute("img", rs.getString("imageUrl"));
                    request.setAttribute("dateOfBirth", rs.getString("date_of_birth"));
                    request.setAttribute("status", rs.getString("status"));
                    String roleName = rs.getString("role_name");
                    request.setAttribute("roleName", roleName);
                    request.getSession().setAttribute("role", roleName); // Update role in session
                    System.out.println("doPost: Role updated in session: " + roleName);
                }
            }
        } catch (SQLException e) {
            System.out.println("doPost: SQLException: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("doPost: Error closing connection: " + e.getMessage());
                }
            }
        }
        request.getRequestDispatcher("userProfile.jsp").forward(request, response);
    }
}
