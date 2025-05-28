package dao;

import Dal.DBContext;
import model.Role;
import model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {

    private Connection conn;

    public UserDAO() {
        this.conn = DBContext.getConnection();
    }

    public UserDAO(Connection conn) {
        this.conn = conn;
    }

    public List<User> getAllUsersWithRoles() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.role_id, r.role_name " +
                     "FROM Users u " +
                     "LEFT JOIN Roles r ON u.role_id = r.role_id";

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
                user.setImg(rs.getString("imageUrl"));
                user.setDateOfBirth(rs.getString("date_of_birth"));
                user.setStatus(rs.getString("status"));

                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleName(rs.getString("role_name"));
                user.setRole(role);
                users.add(user);
            }
        }
        return users;
    }

    public User getUserByUsername(String username) {
        User user = null;
        String sql = "SELECT u.*, r.role_id, r.role_name " +
                     "FROM Users u " +
                     "LEFT JOIN Roles r ON u.role_id = r.role_id " +
                     "WHERE u.username = ?";
        try (PreparedStatement stm = conn.prepareStatement(sql)) {
            stm.setString(1, username);
            ResultSet rs = stm.executeQuery();
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
                user.setImg(rs.getString("imageUrl"));
                user.setDateOfBirth(rs.getString("date_of_birth"));
                user.setStatus(rs.getString("status"));

                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleName(rs.getString("role_name"));
                user.setRole(role);
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return user;
    }
    
    public String getUserRoleName(String username) {
    String sql = "SELECT r.role_name " +
                 "FROM users u " +
                 "JOIN roles r ON u.role_id = r.role_id " +
                 "WHERE u.username = ?";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            return rs.getString("role_name");
        }
    } catch (SQLException e) {
        e.printStackTrace(); // Có thể thay bằng ghi log
    }

    return null;
}


    public void updateUserRoleAndStatus(int userId, int roleId, String status) throws SQLException {
        String sql = "UPDATE Users SET status = ?, role_id = ? WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, roleId);
            stmt.setInt(3, userId);
            stmt.executeUpdate();
        }
    }

    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT u.*, r.role_id, r.role_name " +
                     "FROM Users u " +
                     "LEFT JOIN Roles r ON u.role_id = r.role_id " +
                     "WHERE u.user_id = ?";

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
                    user.setImg(rs.getString("imageUrl"));
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    return user;
                }
            }
        }
        return null;
    }

    public void insertUserWithRole(User user, int roleId) throws SQLException {
        String insertUserSql = "INSERT INTO Users (code, username, password_hash, full_name, address, email, phone_number, imageUrl, date_of_birth, status, role_id) " +
                              "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = conn.prepareStatement(insertUserSql)) {
            stmt.setString(1, user.getCode());
            stmt.setString(2, user.getUsername());
            stmt.setString(3, user.getPassword());
            stmt.setString(4, user.getFullName());
            stmt.setString(5, user.getAddress());
            stmt.setString(6, user.getEmail());
            stmt.setString(7, user.getPhone());
            stmt.setString(8, user.getImg());
            if (user.getDateOfBirth() != null && !user.getDateOfBirth().isEmpty()) {
                stmt.setDate(9, java.sql.Date.valueOf(user.getDateOfBirth()));
            } else {
                stmt.setNull(9, java.sql.Types.DATE);
            }
            stmt.setString(10, user.getStatus());
            stmt.setInt(11, roleId);

            stmt.executeUpdate();
        }
    }

    public List<User> searchUsersByName(String keyword) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.role_id, r.role_name " +
                     "FROM Users u " +
                     "LEFT JOIN Roles r ON u.role_id = r.role_id " +
                     "WHERE u.username LIKE ? OR u.full_name LIKE ?";

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
                    user.setImg(rs.getString("imageUrl"));
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    users.add(user);
                }
            }
        }
        return users;
    }

    public List<User> searchUsersByNameAndRole(String name, Integer roleId) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.role_id, r.role_name " +
                     "FROM Users u " +
                     "LEFT JOIN Roles r ON u.role_id = r.role_id " +
                     "WHERE (? IS NULL OR u.full_name LIKE ?) " +
                     "AND (? IS NULL OR r.role_id = ?)";

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
                    user.setImg(rs.getString("imageUrl"));
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    users.add(user);
                }
            }
        }
        return users;
    }

    public List<User> getUsersByPage(int offset, int limit) throws SQLException {
        String sql = "SELECT u.*, r.role_id, r.role_name " +
                     "FROM Users u " +
                     "LEFT JOIN Roles r ON u.role_id = r.role_id " +
                     "LIMIT ? OFFSET ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            stmt.setInt(2, offset);
            return extractUsersFromResultSet(stmt.executeQuery());
        }
    }

    public int countAllUsers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public List<User> searchUsersByName(String keyword, int offset, int limit) throws SQLException {
        String sql = "SELECT u.*, r.role_id, r.role_name " +
                     "FROM Users u " +
                     "LEFT JOIN Roles r ON u.role_id = r.role_id " +
                     "WHERE u.username LIKE ? OR u.full_name LIKE ? " +
                     "LIMIT ? OFFSET ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            String like = "%" + keyword + "%";
            stmt.setString(1, like);
            stmt.setString(2, like);
            stmt.setInt(3, limit);
            stmt.setInt(4, offset);
            return extractUsersFromResultSet(stmt.executeQuery());
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
            user.setImg(rs.getString("imageUrl"));
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

    public int countUsersByNameAndRole(String name, Integer roleId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users u " +
                     "LEFT JOIN Roles r ON u.role_id = r.role_id " +
                     "WHERE (? IS NULL OR u.full_name LIKE ?) AND (? IS NULL OR r.role_id = ?)";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setString(2, name != null ? "%" + name + "%" : null);
            if (roleId != null) {
                stmt.setInt(3, roleId);
                stmt.setInt(4, roleId);
            } else {
                stmt.setNull(3, java.sql.Types.INTEGER);
                stmt.setNull(4, java.sql.Types.INTEGER);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<User> searchUsersByNameAndRoleWithPaging(String name, Integer roleId, int offset, int limit) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.role_id, r.role_name " +
                     "FROM Users u " +
                     "LEFT JOIN Roles r ON u.role_id = r.role_id " +
                     "WHERE (? IS NULL OR u.full_name LIKE ?) " +
                     "AND (? IS NULL OR r.role_id = ?) " +
                     "LIMIT ? OFFSET ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setString(2, name != null ? "%" + name + "%" : null);
            if (roleId != null) {
                stmt.setInt(3, roleId);
                stmt.setInt(4, roleId);
            } else {
                stmt.setNull(3, java.sql.Types.INTEGER);
                stmt.setNull(4, java.sql.Types.INTEGER);
            }
            stmt.setInt(5, limit);
            stmt.setInt(6, offset);

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
                    user.setImg(rs.getString("imageUrl"));
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    users.add(user);
                }
            }
        }
        return users;
    }

    public List<User> searchUsersByNameRoleStatus(String name, Integer roleId, String status) throws SQLException {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT u.*, r.role_id, r.role_name " +
                    "FROM Users u " +
                    "LEFT JOIN Roles r ON u.role_id = r.role_id " +
                    "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (name != null && !name.trim().isEmpty()) {
            sql.append(" AND u.full_name LIKE ? ");
            params.add("%" + name.trim() + "%");
        }

        if (roleId != null && roleId > 0) {
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
                while (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setCode(rs.getString("code"));
                    user.setUsername(rs.getString("username"));
                    user.setFullName(rs.getString("full_name"));
                    user.setAddress(rs.getString("address"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone_number"));
                    user.setImg(rs.getString("imageUrl"));
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    list.add(user);
                }
            }
        }
        return list;
    }

    public int countUsersByNameRoleStatus(String search, Integer roleId, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Users u " +
            "LEFT JOIN Roles r ON u.role_id = r.role_id " +
            "WHERE 1=1 "
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
        }
        return 0;
    }

    public List<User> searchUsersByNameRoleStatusWithPaging(String search, Integer roleId, String status, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT u.*, r.role_id, r.role_name FROM Users u " +
            "LEFT JOIN Roles r ON u.role_id = r.role_id " +
            "WHERE 1=1 "
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
                    user.setImg(rs.getString("imageUrl"));
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setStatus(rs.getString("status"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    user.setRole(role);

                    list.add(user);
                }
            }
        }
        return list;
    }

    public List<User> getUsersWithLoginInfo() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.username, u.password_hash, r.role_id, r.role_name " +
                     "FROM Users u JOIN Roles r ON u.role_id = r.role_id " +
                     "WHERE u.status = 'active'";

        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
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
        }
        return users;
    }

    public String getRoleNameByUsername(String username) throws SQLException {
        String sql = "SELECT r.role_name " +
                     "FROM Users u JOIN Roles r ON u.role_id = r.role_id " +
                     "WHERE u.username = ? AND u.status = 'active'";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("role_name");
                }
            }
        }
        return null;
    }
}
