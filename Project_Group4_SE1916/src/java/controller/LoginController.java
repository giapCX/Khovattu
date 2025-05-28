package controller;

import Dal.DBContext;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            if (conn == null) {
                request.setAttribute("error", "Database connection failed. Please try again later.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            // Adjusted SQL to use UserRoles table for many-to-many relationship
            String sql = "SELECT u.username, u.password_hash, r.role_name " +
                         "FROM Users u " +
                         "JOIN UserRoles ur ON u.user_id = ur.user_id " +
                         "JOIN Roles r ON ur.role_id = r.role_id " +
                         "WHERE u.username = ? AND u.password_hash = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, username);
                stmt.setString(2, password); // Note: Should use hashed password comparison

                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    // Login successful
                    HttpSession session = request.getSession();
                    session.setAttribute("username", username);

                    // Get the role name
                    String roleName = rs.getString("role_name");

                    // Redirect based on role
                    String redirectPage = "login.jsp"; // Default redirect
                    switch (roleName.toLowerCase()) {
                        case "admin":
                            redirectPage = "view/admin/adminDashboard.jsp";
                            break;
                        case "employee":
                            redirectPage = "view/employee/employeeDashboard.jsp";
                            break;
                        case "direction":
                            redirectPage = "view/direction/directionDashboard.jsp";
                            break;
                        case "warehouse":
                            redirectPage = "view/warehouse/warehouseDashboard.jsp";
                            break;
                        default:
                            request.setAttribute("error", "Role not recognized. Contact administrator.");
                            request.getRequestDispatcher("login.jsp").forward(request, response);
                            return;
                    }

                    response.sendRedirect(redirectPage);
                } else {
                    // Invalid login credentials
                    request.setAttribute("error", "Invalid username or password.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } finally {
            if (conn != null) {
                try {
                    conn.close(); // Ensure connection is closed
                } catch (SQLException e) {
                    System.err.println("Error closing connection: " + e.getMessage());
                }
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet handling login process";
    }
}