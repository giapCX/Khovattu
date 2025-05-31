package controller;

import dao.UserProfileDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.User;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.SQLException;


public class UserProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");
        UserProfileDAO userDao = new UserProfileDAO();
        User user = userDao.getUserProfileByUsername(username);

        if (user != null) {
            request.setAttribute("user", user);
            request.setAttribute("role", user.getRole() != null ? user.getRole().getRoleName() : "unknown");
        } else {
            request.setAttribute("error", "Không thể xác định thông tin người dùng: " + username);
        }
        RequestDispatcher rd = request.getRequestDispatcher("userProfile.jsp");
        rd.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");
        UserProfileDAO userDao = new UserProfileDAO();

        // Lấy dữ liệu từ form
        String fullName = request.getParameter("fullName");
        String address = request.getParameter("address");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String status = request.getParameter("status");

        User user = new User();
        user.setUsername(username);
        user.setFullName(fullName != null ? fullName.trim() : "");
        user.setAddress(address != null ? address.trim() : "");
        user.setEmail(email != null ? email.trim() : "");
        user.setPhone(phone);
        user.setDateOfBirth(dateOfBirth);
        user.setStatus(status);

        // Validation
        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Họ và tên không được để trống.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email không được để trống.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }
        if (address == null || address.trim().isEmpty()) {
            request.setAttribute("error", "Địa chỉ không được để trống.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }
        if (!email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            request.setAttribute("error", "Email không hợp lệ.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }

        // Xử lý ảnh đại diện
        Part filePart = request.getPart("profilePic");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }
            String filePath = uploadPath + File.separator + fileName;
            filePart.write(filePath);
            user.setImg("uploads/" + fileName);
        }

        try {
            userDao.updateUserProfile(user);
            user = userDao.getUserProfileByUsername(username);
            request.setAttribute("user", user);
            request.setAttribute("message", "Cập nhật hồ sơ thành công!");
        } catch (SQLException e) {
            request.setAttribute("error", "Lỗi khi cập nhật thông tin: " + e.getMessage());
            request.setAttribute("user", user);
        }

        RequestDispatcher rd = request.getRequestDispatcher("userProfile.jsp");
        rd.forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet xử lý thông tin hồ sơ người dùng";
    }
}
