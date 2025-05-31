package controller;

import Dal.DBContext;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.User;

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
                    request.getSession().setAttribute("role", roleName);
                    System.out.println("doGet: Role set in session: " + roleName);
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
        System.out.println("doPost: Processing for username: " + username);
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String fullName = request.getParameter("fullName") != null ? request.getParameter("fullName").trim() : null;
        String address = request.getParameter("address") != null ? request.getParameter("address").trim() : null;
        String email = request.getParameter("email") != null ? request.getParameter("email").trim() : null;
        String phone = request.getParameter("phone") != null ? request.getParameter("phone").trim() : null;
        String dateOfBirth = request.getParameter("dob");
        String status = request.getParameter("status");

        System.out.println("doPost: fullName: '" + fullName + "', address: '" + address + "', email: '" + email + "'");

        if (fullName == null || fullName.isEmpty()) {
            request.setAttribute("error", "Họ và tên không được để trống.");
            doGet(request, response);
            return;
        }
        if (email == null || email.isEmpty()) {
            request.setAttribute("error", "Email không được để trống.");
            doGet(request, response);
            return;
        }
        if (address == null || address.isEmpty()) {
            request.setAttribute("error", "Địa chỉ không được để trống.");
            doGet(request, response);
            return;
        }

        if (!email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            request.setAttribute("error", "Email không hợp lệ.");
            doGet(request, response);
            return;
        }

        String img = null;
        Part filePart = request.getPart("profilePic");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();
            String uploadPath = getServletContext().getRealPath("") + File.separator + "images";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }
            filePart.write(uploadPath + File.separator + fileName);
            img = "images/" + fileName;
        }

        Connection conn = null;
        UserDAO userDAO = null;
        try {
            conn = new DBContext().getConnection();
            if (conn == null) {
                request.setAttribute("error", "Không thể kết nối cơ sở dữ liệu.");
                doGet(request, response);
                return;
            }
            userDAO = new UserDAO(conn);
            User user = userDAO.getUserByUsername(username);
            if (user == null) {
                request.setAttribute("error", "Không tìm thấy người dùng để cập nhật.");
                doGet(request, response);
                return;
            }

            user.setFullName(fullName);
            user.setAddress(address);
            user.setEmail(email);
            user.setPhone(phone != null && !phone.isEmpty() ? phone : user.getPhone());
            user.setDateOfBirth(dateOfBirth != null && !dateOfBirth.isEmpty() ? dateOfBirth : user.getDateOfBirth());
            user.setStatus(status != null && !status.isEmpty() ? status : user.getStatus());
            if (img != null) {
                user.setImg(img);
            }

            userDAO.updateUser(user);
            request.setAttribute("message", "Cập nhật hồ sơ thành công!");
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
        doGet(request, response);
    }
}
