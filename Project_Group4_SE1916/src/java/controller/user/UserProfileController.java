package controller.user;

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
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.SQLException;

@MultipartConfig(maxFileSize = 5242880) // 5MB
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
            request.setAttribute("error", "Cannot identify user information: " + username);
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

        // Get data from form
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
            request.setAttribute("error", "Full name cannot be empty.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email cannot be empty.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }
        if (address == null || address.trim().isEmpty()) {
            request.setAttribute("error", "Address cannot be empty.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }
        if (!email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            request.setAttribute("error", "Invalid email format.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }

        // Handle profile picture
        Part filePart = request.getPart("profilePic");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = username + "_" + System.currentTimeMillis() + "_" + fileName.substring(fileName.lastIndexOf("."));
            String tempPath = System.getProperty("java.io.tmpdir") + File.separator + uniqueFileName;
            String targetPath = getServletContext().getRealPath("") + File.separator + "images" + File.separator + uniqueFileName;

            File tempFile = new File(tempPath);
            File targetDir = new File(getServletContext().getRealPath("") + File.separator + "images");
            if (!targetDir.exists()) {
                if (!targetDir.mkdirs()) {
                    System.out.println("Failed to create images directory at: " + targetPath + ". Permissions: " + targetDir.canWrite());
                    request.setAttribute("error", "Failed to create images directory.");
                    request.setAttribute("user", user);
                    doGet(request, response);
                    return;
                }
            }

            try {
                filePart.write(tempPath);
                FileUtils.copyFile(tempFile, new File(targetPath));
                if (!new File(targetPath).exists()) {
                    System.out.println("Error: Image not copied to " + targetPath + ". Temp file size: " + tempFile.length() + " bytes. Target writable: " + new File(targetPath).canWrite());
                    request.setAttribute("error", "Image file was not copied correctly. Check permissions or disk space.");
                    request.setAttribute("user", user);
                    doGet(request, response);
                    return;
                }
                user.setImg("images/" + uniqueFileName);
                System.out.println("Image copied successfully to " + targetPath + ". Size: " + new File(targetPath).length() + " bytes.");
                tempFile.delete();
            } catch (IOException e) {
                System.out.println("IOException: " + e.getMessage() + " at path: " + targetPath + ". Cause: " + e.getCause() + ". Temp file exists: " + tempFile.exists());
                request.setAttribute("error", "Failed to save image: " + e.getMessage());
                request.setAttribute("user", user);
                doGet(request, response);
                return;
            }
        } else {
            User existingUser = userDao.getUserProfileByUsername(username);
            if (existingUser != null && existingUser.getImg() != null) {
                user.setImg(existingUser.getImg());
            } else {
                System.out.println("No existing image for username: " + username);
            }
        }

        try {
            System.out.println("Attempting to update profile for username: " + username + " with imageUrl: " + user.getImg());
            userDao.updateUserProfile(user);
            user = userDao.getUserProfileByUsername(username); // Lấy lại user để xác nhận
            request.setAttribute("user", user);
            if (user.getImg() != null && !user.getImg().isEmpty()) {
                request.setAttribute("message", "Profile updated successfully! New image: " + user.getImg());
            } else {
                request.setAttribute("message", "Profile updated successfully! No image change.");
            }
            System.out.println("Profile updated successfully for username: " + username + ". New imageUrl: " + user.getImg());
        } catch (SQLException e) {
            System.out.println("SQLException: " + e.getMessage() + " for username: " + username + ". SQL State: " + e.getSQLState() + ". Error Code: " + e.getErrorCode());
            request.setAttribute("error", "Error updating profile: " + e.getMessage());
            request.setAttribute("user", user);
        }

        RequestDispatcher rd = request.getRequestDispatcher("userProfile.jsp");
        rd.forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet that handles user profile information";
    }
}