package dao;

import Dal.DBContext;
import model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.mindrot.jbcrypt.BCrypt;

public class UserProfileDAO {

    private Connection conn;

    public UserProfileDAO() {
        this.conn = DBContext.getConnection();
        if (this.conn == null) {
            Logger.getLogger(UserProfileDAO.class.getName()).log(Level.SEVERE, "Database connection is null");
        }
    }

    public UserProfileDAO(Connection conn) {
        this.conn = conn;
        if (this.conn == null) {
            Logger.getLogger(UserProfileDAO.class.getName()).log(Level.SEVERE, "Provided connection is null");
        }
    }

    public User getUserProfileByUsername(String username) {
        User user = null;
        String sql = "SELECT u.*, r.role_name "
                + "FROM Users u "
                + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setCode(rs.getString("code"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(rs.getString("password_hash")); // Lưu ý: Không hiển thị mật khẩu thực tế
                    user.setFullName(rs.getString("full_name"));
                    user.setAddress(rs.getString("address"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone_number"));
                    user.setImage(rs.getString("imageUrl")); // Ánh xạ imageUrl từ DB sang Image trong User
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));
                    model.Role role = new model.Role();
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserProfileDAO.class.getName()).log(Level.SEVERE, "Error fetching user profile for username: " + username, ex);
        }
        return user;
    }

    public void updateUserProfile(User user) throws SQLException {
        if (conn == null) {
            throw new SQLException("Database connection is null");
        }

        StringBuilder sql = new StringBuilder("UPDATE Users SET ");
        List<String> updates = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (user.getFullName() != null && !user.getFullName().isEmpty()) {
            updates.add("full_name = ?");
            params.add(user.getFullName());
        }
        if (user.getAddress() != null && !user.getAddress().isEmpty()) {
            updates.add("address = ?");
            params.add(user.getAddress());
        }
        if (user.getEmail() != null && !user.getEmail().isEmpty()) {
            updates.add("email = ?");
            params.add(user.getEmail());
        }
        if (user.getPhone() != null && !user.getPhone().isEmpty()) {
            updates.add("phone_number = ?");
            params.add(user.getPhone());
        }
        if (user.getImage() != null && !user.getImage().isEmpty()) {
            updates.add("imageUrl = ?"); // Cập nhật cột imageUrl trong DB với giá trị từ Image
            params.add(user.getImage());
        }
        if (user.getDateOfBirth() != null && !user.getDateOfBirth().isEmpty()) {
            updates.add("date_of_birth = ?");
            params.add(user.getDateOfBirth());
        }
        if (user.getStatus() != null && !user.getStatus().isEmpty()) {
            updates.add("status = ?");
            params.add(user.getStatus());
        }

        if (updates.isEmpty()) {
            Logger.getLogger(UserProfileDAO.class.getName()).log(Level.INFO, "No fields to update for username: " + user.getUsername());
            return; // Không có gì để cập nhật
        }

        sql.append(String.join(", ", updates));
        sql.append(" WHERE username = ?");
        params.add(user.getUsername());

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                Logger.getLogger(UserProfileDAO.class.getName()).log(Level.WARNING, "No rows updated for username: " + user.getUsername());
            } else {
                Logger.getLogger(UserProfileDAO.class.getName()).log(Level.INFO, "Updated " + rowsAffected + " row(s) for username: " + user.getUsername());
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserProfileDAO.class.getName()).log(Level.SEVERE, "Error updating user profile for username: " + user.getUsername(), ex);
            throw ex;
        }
    }

    public void updateUserPassword(String username, String newPassword) throws SQLException {
        if (conn == null) {
            throw new SQLException("Database connection is null");
        }

        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        String sql = "UPDATE Users SET password_hash = ? WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, hashedPassword);
            stmt.setString(2, username);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                Logger.getLogger(UserProfileDAO.class.getName()).log(Level.WARNING, "No rows updated for password change of username: " + username);
            } else {
                Logger.getLogger(UserProfileDAO.class.getName()).log(Level.INFO, "Password updated for username: " + username);
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserProfileDAO.class.getName()).log(Level.SEVERE, "Error updating password for username: " + username, ex);
            throw ex;
        }
    }
}