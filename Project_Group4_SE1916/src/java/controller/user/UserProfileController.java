package controller.user;

import dao.UserProfileDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import model.User;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1MB
        maxFileSize = 1024 * 1024 * 5,      // 5MB
        maxRequestSize = 1024 * 1024 * 15   // 15MB
)
public class UserProfileController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UserProfileController.class.getName());
    private UserProfileDAO userDao;

    @Override
    public void init() throws ServletException {
        super.init();
        userDao = new UserProfileDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");
        User user = userDao.getUserProfileByUsername(username);
        if (user != null) {
            request.setAttribute("user", user);
            request.setAttribute("role", user.getRole() != null ? user.getRole().getRoleName() : "unknown");
        } else {
            request.setAttribute("error", "User profile not found for username: " + username);
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
        user.setPhone(phone != null ? phone.trim() : null);
        user.setDateOfBirth(dateOfBirth != null ? dateOfBirth : null);
        user.setStatus(status != null ? status : "active");
        // Validation
        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Full name is required.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required.");
            request.setAttribute("user", user);
            doGet(request, response);
            return;
        }
        if (address == null || address.trim().isEmpty()) {
            request.setAttribute("error", "Address is required.");
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
        // Handle image upload
        Part filePart = request.getPart("profilePic");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = username + "_" + System.currentTimeMillis() + "_" + fileName.substring(fileName.lastIndexOf("."));
            String tempPath = System.getProperty("java.io.tmpdir") + File.separator + uniqueFileName;
            String targetPath = getServletContext().getRealPath("") + File.separator + "images" + File.separator + uniqueFileName;
            
            File targetDir = new File(getServletContext().getRealPath("") + File.separator + "images");
            if (!targetDir.exists()) {
                if (!targetDir.mkdirs()) {
                    LOGGER.log(Level.SEVERE, "Failed to create images directory at: " + targetPath);
                    request.setAttribute("error", "Error creating image storage directory.");
                    request.setAttribute("user", user);
                    doGet(request, response);
                    return;
                }
            }
            
            try {
                filePart.write(tempPath);
                File tempFile = new File(tempPath);
                File targetFile = new File(targetPath);
                FileUtils.copyFile(tempFile, targetFile);
                if (!targetFile.exists() || targetFile.length() <= 0) {
                    LOGGER.log(Level.SEVERE, "Image not copied to: " + targetPath);
                    request.setAttribute("error", "Error saving image. Check permissions or disk space.");
                    request.setAttribute("user", user);
                    doGet(request, response);
                    return;
                }
                user.setImage("images/" + uniqueFileName);
                LOGGER.log(Level.INFO, "Image successfully copied to: " + targetPath);
                tempFile.delete();
            } catch (IOException e) {
                LOGGER.log(Level.SEVERE, "IOException while saving image: " + e.getMessage(), e);
                request.setAttribute("error", "Error saving image: " + e.getMessage());
                request.setAttribute("user", user);
                doGet(request, response);
                return;
            }
        } else {
            User existingUser = userDao.getUserProfileByUsername(username);
            if (existingUser != null && existingUser.getImage() != null) {
                user.setImage(existingUser.getImage());
            }
        }
        // Update user profile
        try {
            LOGGER.log(Level.INFO, "Updating profile for username: " + username);
            userDao.updateUserProfile(user);
            user = userDao.getUserProfileByUsername(username); // Refresh user data
            request.setAttribute("user", user);
            request.setAttribute("message", user.getImage() != null && !user.getImage().isEmpty() ?
                    "Profile updated successfully!" : "Profile updated successfully! No image change.");
            LOGGER.log(Level.INFO, "Profile updated successfully for username: " + username);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "SQL error while updating profile for username: " + username, e);
            request.setAttribute("error", "Error updating profile: " + e.getMessage());
            request.setAttribute("user", user);
        }
        RequestDispatcher rd = request.getRequestDispatcher("userProfile.jsp");
        rd.forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet to handle user profile display and updates";
    }
}