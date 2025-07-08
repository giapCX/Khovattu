//UserDAO
package dao;

import Dal.DBContext;
import model.Role;
import model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.mindrot.jbcrypt.BCrypt;

public class UserDAO {

    private Connection conn;
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public UserDAO() {
        this.conn = DBContext.getConnection();
        if (this.conn == null) {
            LOGGER.log(Level.SEVERE, "Database connection is null");
        }
    }

    public UserDAO(Connection conn) {
        this.conn = conn;
        if (this.conn == null) {
            LOGGER.log(Level.SEVERE, "Provided connection is null");
        }
    }

    public List<User> getAllUsersWithRoles() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.role_id, r.role_name "
                + "FROM Users u "
                + "LEFT JOIN Roles r ON u.role_id = r.role_id";

        try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setCode(rs.getString("code"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setAddress(rs.getString("address"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone_number"));
                user.setImage(rs.getString("imageUrl")); // Đổi từ setImg sang setImage
                user.setDateOfBirth(rs.getString("date_of_birth"));
                user.setStatus(rs.getString("status"));

                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleName(rs.getString("role_name"));
                user.setRole(role);
                users.add(user);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching all users with roles", ex);
            throw ex;
        }
        return users;
    }

    public User getUserByEmail(String email) {
        User user = null;
        String sql = "SELECT u.*, r.role_id, r.role_name "
                + "FROM Users u "
                + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setCode(rs.getString("code"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(rs.getString("password_hash"));
                    user.setFullName(rs.getString("full_name"));
                    user.setAddress(rs.getString("address"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone_number"));
                    user.setImage(rs.getString("imageUrl")); // Đổi từ setImg sang setImage
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching user by email: " + email, ex);
        }
        return user;
    }

    public void updateUser(User user) throws SQLException {
        String sql = "UPDATE Users SET full_name = ?, address = ?, email = ?, phone_number = ?, date_of_birth = ?, imageUrl = ?, status = ? WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getAddress());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getPhone() != null && !user.getPhone().isEmpty() ? user.getPhone() : null);
            stmt.setString(5, user.getDateOfBirth() != null && !user.getDateOfBirth().isEmpty() ? user.getDateOfBirth() : null);
            stmt.setString(6, user.getImage() != null && !user.getImage().isEmpty() ? user.getImage() : null); // Đổi từ getImg sang getImage
            stmt.setString(7, user.getStatus());
            stmt.setString(8, user.getUsername());
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                LOGGER.log(Level.WARNING, "No rows updated for username: " + user.getUsername());
            } else {
                LOGGER.log(Level.INFO, "Updated " + rowsAffected + " row(s) for username: " + user.getUsername());
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating user: " + user.getUsername(), ex);
            throw ex;
        }
    }

    public User getUserByUsername(String username) {
        User user = null;
        String sql = "SELECT u.*, r.role_id, r.role_name "
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
                    user.setPassword(rs.getString("password_hash"));
                    user.setFullName(rs.getString("full_name"));
                    user.setAddress(rs.getString("address"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone_number"));
                    user.setImage(rs.getString("imageUrl")); // Đổi từ setImg sang setImage
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching user by username: " + username, ex);
        }
        return user;
    }

    public String getUserRoleName(String username) {
        String sql = "SELECT r.role_name "
                + "FROM Users u "
                + "JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.username = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("role_name");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching role name for username: " + username, e);
        }
        return null;
    }

    public void updateUserRoleAndStatus(int userId, int roleId, String status) throws SQLException {
        String sql = "UPDATE Users SET status = ?, role_id = ? WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, roleId);
            stmt.setInt(3, userId);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                LOGGER.log(Level.WARNING, "No rows updated for userId: " + userId);
            } else {
                LOGGER.log(Level.INFO, "Updated " + rowsAffected + " row(s) for userId: " + userId);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating role and status for userId: " + userId, ex);
            throw ex;
        }
    }

    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT u.*, r.role_id, r.role_name "
                + "FROM Users u "
                + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.user_id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setCode(rs.getString("code"));
                    user.setUsername(rs.getString("username"));
                    user.setFullName(rs.getString("full_name"));
                    user.setAddress(rs.getString("address"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone_number"));
                    user.setImage(rs.getString("imageUrl")); // Đổi từ setImg sang setImage
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    return user;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching user by id: " + userId, ex);
            throw ex;
        }
        return null;
    }

    public void insertUserWithRole(User user, int roleId) throws SQLException {
        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
        String insertUserSql = "INSERT INTO Users (code, username, password_hash, full_name, address, email, phone_number, imageUrl, date_of_birth, status, role_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = conn.prepareStatement(insertUserSql)) {
            stmt.setString(1, user.getCode());
            stmt.setString(2, user.getUsername());
            stmt.setString(3, hashedPassword);
            stmt.setString(4, user.getFullName());
            stmt.setString(5, user.getAddress());
            stmt.setString(6, user.getEmail());
            stmt.setString(7, user.getPhone());
            stmt.setString(8, user.getImage()); // Đổi từ getImg sang getImage
            if (user.getDateOfBirth() != null && !user.getDateOfBirth().isEmpty()) {
                stmt.setDate(9, java.sql.Date.valueOf(user.getDateOfBirth()));
            } else {
                stmt.setNull(9, java.sql.Types.DATE);
            }
            stmt.setString(10, user.getStatus());
            stmt.setInt(11, roleId);

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                LOGGER.log(Level.WARNING, "No rows inserted for username: " + user.getUsername());
            } else {
                LOGGER.log(Level.INFO, "Inserted " + rowsAffected + " row(s) for username: " + user.getUsername());
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting user: " + user.getUsername(), ex);
            throw ex;
        }
    }

    public List<User> searchUsersByName(String keyword) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.role_id, r.role_name "
                + "FROM Users u "
                + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.username LIKE ? OR u.full_name LIKE ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            String likeKeyword = "%" + keyword + "%";
            stmt.setString(1, likeKeyword);
            stmt.setString(2, likeKeyword);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setCode(rs.getString("code"));
                    user.setUsername(rs.getString("username"));
                    user.setFullName(rs.getString("full_name"));
                    user.setAddress(rs.getString("address"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone_number"));
                    user.setImage(rs.getString("imageUrl")); // Đổi từ setImg sang setImage
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    users.add(user);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error searching users by name: " + keyword, ex);
            throw ex;
        }
        return users;
    }

    public List<User> searchUsersByNameAndRole(String name, Integer roleId) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.role_id, r.role_name "
                + "FROM Users u "
                + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE (? IS NULL OR u.full_name LIKE ?) "
                + "AND (? IS NULL OR r.role_id = ?)";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name == null || name.isEmpty() ? null : name);
            stmt.setString(2, name == null || name.isEmpty() ? null : "%" + name + "%");
            if (roleId == null) {
                stmt.setNull(3, java.sql.Types.INTEGER);
                stmt.setNull(4, java.sql.Types.INTEGER);
            } else {
                stmt.setInt(3, roleId);
                stmt.setInt(4, roleId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setCode(rs.getString("code"));
                    user.setUsername(rs.getString("username"));
                    user.setFullName(rs.getString("full_name"));
                    user.setAddress(rs.getString("address"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone_number"));
                    user.setImage(rs.getString("imageUrl")); // Đổi từ setImg sang setImage
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    users.add(user);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error searching users by name and role: name=" + name + ", roleId=" + roleId, ex);
            throw ex;
        }
        return users;
    }

    public List<User> getUsersByPage(int offset, int limit) throws SQLException {
        String sql = "SELECT u.*, r.role_id, r.role_name "
                + "FROM Users u "
                + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                + "LIMIT ? OFFSET ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            stmt.setInt(2, offset);
            return extractUsersFromResultSet(stmt.executeQuery());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching users by page: offset=" + offset + ", limit=" + limit, ex);
            throw ex;
        }
    }

    public int countAllUsers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users";
        try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting all users", ex);
            throw ex;
        }
    }

    public List<User> searchUsersByName(String keyword, int offset, int limit) throws SQLException {
        String sql = "SELECT u.*, r.role_id, r.role_name "
                + "FROM Users u "
                + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.username LIKE ? OR u.full_name LIKE ? "
                + "LIMIT ? OFFSET ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            String like = "%" + keyword + "%";
            stmt.setString(1, like);
            stmt.setString(2, like);
            stmt.setInt(3, limit);
            stmt.setInt(4, offset);
            return extractUsersFromResultSet(stmt.executeQuery());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error searching users by name with pagination: keyword=" + keyword, ex);
            throw ex;
        }
    }

    public int countUsersSearch(String keyword) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users WHERE username LIKE ? OR full_name LIKE ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            String like = "%" + keyword + "%";
            stmt.setString(1, like);
            stmt.setString(2, like);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting users search: keyword=" + keyword, ex);
            throw ex;
        }
    }

    private List<User> extractUsersFromResultSet(ResultSet rs) throws SQLException {
        List<User> list = new ArrayList<>();
        while (rs.next()) {
            User user = new User();
            user.setUserId(rs.getInt("user_id"));
            user.setCode(rs.getString("code"));
            user.setUsername(rs.getString("username"));
            user.setFullName(rs.getString("full_name"));
            user.setAddress(rs.getString("address"));
            user.setEmail(rs.getString("email"));
            user.setPhone(rs.getString("phone_number"));
            user.setImage(rs.getString("imageUrl")); // Đổi từ setImg sang setImage
            user.setDateOfBirth(rs.getString("date_of_birth"));
            user.setStatus(rs.getString("status"));

            Role role = new Role();
            role.setRoleId(rs.getInt("role_id"));
            role.setRoleName(rs.getString("role_name"));
            user.setRole(role);

            list.add(user);
        }
        return list;
    }

    public int countUsersByNameRoleStatus(String search, Integer roleId, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Users u "
                + "JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE r.role_name != 'admin' "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND u.username LIKE ? ");
            params.add("%" + search.trim() + "%");
        }
        if (roleId != null) {
            sql.append(" AND r.role_id = ? ");
            params.add(roleId);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND u.status = ? ");
            params.add(status.trim());
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting users by name, role, status: search=" + search + ", roleId=" + roleId + ", status=" + status, ex);
            throw ex;
        }
        return 0;
    }

    public List<User> searchUsersByNameRoleStatusWithPaging(String search, Integer roleId, String status, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT u.*, r.role_name FROM Users u "
                + "JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE r.role_name != 'admin' "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND u.username LIKE ? ");
            params.add("%" + search.trim() + "%");
        }
        if (roleId != null) {
            sql.append(" AND r.role_id = ? ");
            params.add(roleId);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND u.status = ? ");
            params.add(status.trim());
        }

        sql.append(" ORDER BY u.user_id LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<User> list = new ArrayList<>();

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setCode(rs.getString("code"));
                    user.setUsername(rs.getString("username"));
                    user.setFullName(rs.getString("full_name"));
                    user.setAddress(rs.getString("address"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone_number"));
                    user.setImage(rs.getString("imageUrl")); // Đổi từ setImg sang setImage
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    list.add(user);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error searching users by name, role, status with paging: search=" + search + ", roleId=" + roleId + ", status=" + status, ex);
            throw ex;
        }
        return list;
    }

    public List<User> getUsersWithLoginInfo() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.username, u.password_hash, r.role_id, r.role_name "
                + "FROM Users u JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.status = 'active'";

        try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                User user = new User();
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password_hash"));

                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleName(rs.getString("role_name"));
                user.setRole(role);

                users.add(user);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching users with login info", ex);
            throw ex;
        }
        return users;
    }

    public String getRoleNameByUsername(String username) throws SQLException {
        String sql = "SELECT r.role_name "
                + "FROM Users u JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE u.username = ? AND u.status = 'active'";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("role_name");
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching role name by username: " + username, ex);
            throw ex;
        }
        return null;
    }

    public boolean isUsernameOrEmailExists(String username, String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users WHERE username = ? OR email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setString(2, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking username or email existence: username=" + username + ", email=" + email, ex);
            throw ex;
        }
        return false;
    }
}
