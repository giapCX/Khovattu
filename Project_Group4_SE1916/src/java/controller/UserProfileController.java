package controller;

import Dal.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class UserProfileController extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("username");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            if (conn == null) {
                request.setAttribute("error", "Database connection failed.");
                request.getRequestDispatcher("userProfile.jsp").forward(request, response);
                return;
            }

            String sql = "UPDATE users SET full_name = ?, email = ?, phone = ? WHERE username = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, fullName);
                stmt.setString(2, email);
                stmt.setString(3, phone != null && !phone.isEmpty() ? phone : null);
                stmt.setString(4, username);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    request.setAttribute("message", "Cập nhật hồ sơ thành công!");
                } else {
                    request.setAttribute("error", "Không thể cập nhật hồ sơ.");
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("Error closing connection: " + e.getMessage());
                }
            }
        }
        request.getRequestDispatcher("userProfile.jsp").forward(request, response);
    }
}