/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

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
    }

    public UserDAO(Connection conn) {
        this.conn = conn;
    }

    public List<User> getAllUsersWithRoles() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.role_id, r.role_name "
                + "FROM Users u "
                + "JOIN UserRoles ur ON u.user_id = ur.user_id "
                + "JOIN Roles r ON ur.role_id = r.role_id";

        try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setAddress(rs.getString("address"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone_number"));
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
        User user = new User();
        String sql = "SELECT * FROM [User] WHERE username = ?";
        try {
            PreparedStatement stm = conn.prepareStatement(sql);
            stm.setString(1, username);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
                user.setStatus(rs.getString("status"));
                user.setUsername(username);
                return user;
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    public void updateUserRoleAndStatus(int userId, int roleId, String status) throws SQLException {
        // Cập nhật status
        String updateUserSql = "UPDATE Users SET status = ? WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateUserSql)) {
            stmt.setString(1, status);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        }

        // Cập nhật role (có thể dùng cách đơn giản: xóa rồi thêm)
        String deleteRoleSql = "DELETE FROM UserRoles WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(deleteRoleSql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        }

        String insertRoleSql = "INSERT INTO UserRoles(user_id, role_id) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(insertRoleSql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, roleId);
            stmt.executeUpdate();
        }
    }

    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT u.*, r.role_id, r.role_name FROM Users u "
                + "JOIN UserRoles ur ON u.user_id = ur.user_id "
                + "JOIN Roles r ON ur.role_id = r.role_id WHERE u.user_id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setFullName(rs.getString("full_name"));
                    user.setAddress(rs.getString("address"));
                    user.setEmail(rs.getString("email"));
                    user.setPhone(rs.getString("phone_number"));
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
        String insertUserSql = "INSERT INTO Users (username, password_hash, full_name, address, email, phone_number, date_of_birth, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getFullName());
            stmt.setString(4, user.getAddress());
            stmt.setString(5, user.getEmail());
            stmt.setString(6, user.getPhone());
            if (user.getDateOfBirth() != null && !user.getDateOfBirth().isEmpty()) {
                stmt.setDate(7, java.sql.Date.valueOf(user.getDateOfBirth()));
            } else {
                stmt.setNull(7, java.sql.Types.DATE);
            }
            stmt.setString(8, user.getStatus());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating user failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int newUserId = generatedKeys.getInt(1);

                    // Gán role cho user mới
                    String insertRoleSql = "INSERT INTO UserRoles (user_id, role_id) VALUES (?, ?)";
                    try (PreparedStatement stmtRole = conn.prepareStatement(insertRoleSql)) {
                        stmtRole.setInt(1, newUserId);
                        stmtRole.setInt(2, roleId);
                        stmtRole.executeUpdate();
                    }
                } else {
                    throw new SQLException("Creating user failed, no ID obtained.");
                }
            }
        }
    }
    
    public List<User> searchUsersByName(String keyword) throws SQLException {
    List<User> users = new ArrayList<>();
    String sql = "SELECT u.user_id, u.username, u.full_name, u.address, u.email, u.phone_number, u.status, r.role_id, r.role_name " +
                 "FROM Users u " +
                 "LEFT JOIN UserRoles ur ON u.user_id = ur.user_id " +
                 "LEFT JOIN Roles r ON ur.role_id = r.role_id " +
                 "WHERE u.username LIKE ? OR u.full_name LIKE ?";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        String likeKeyword = "%" + keyword + "%";
        stmt.setString(1, likeKeyword);
        stmt.setString(2, likeKeyword);

        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setAddress(rs.getString("address"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone_number"));
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
                 "JOIN UserRoles ur ON u.user_id = ur.user_id " +
                 "JOIN Roles r ON ur.role_id = r.role_id " +
                 "WHERE (? IS NULL OR u.full_name LIKE ?) " +
                 "AND (? IS NULL OR r.role_id = ?)";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, name == null || name.isEmpty() ? null : name);
        stmt.setString(2, "%" + name + "%");
        if (roleId == null) {
            stmt.setNull(3, java.sql.Types.INTEGER);
            stmt.setNull(4, java.sql.Types.INTEGER);
        } else {
            stmt.setInt(3, roleId);
            stmt.setInt(4, roleId);
        }

        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            User user = new User();
            user.setUserId(rs.getInt("user_id"));
            user.setUsername(rs.getString("username"));
            user.setFullName(rs.getString("full_name"));
            user.setAddress(rs.getString("address"));
            user.setEmail(rs.getString("email"));
            user.setPhone(rs.getString("phone_number"));
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
    
//Phân trang
public List<User> getUsersByPage(int offset, int limit) throws SQLException {
    String sql = "SELECT u.*, r.role_id, r.role_name " +
                 "FROM Users u " +
                 "LEFT JOIN UserRoles ur ON u.user_id = ur.user_id " +
                 "LEFT JOIN Roles r ON ur.role_id = r.role_id " +
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
                 "LEFT JOIN UserRoles ur ON u.user_id = ur.user_id " +
                 "LEFT JOIN Roles r ON ur.role_id = r.role_id " +
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
public int countSearchUsers(String keyword) throws SQLException {
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
        user.setUsername(rs.getString("username"));
        user.setFullName(rs.getString("full_name"));
        user.setAddress(rs.getString("address"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone_number"));
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
                 "JOIN UserRoles ur ON u.user_id = ur.user_id " +
                 "WHERE (? IS NULL OR u.full_name LIKE ?) AND (? IS NULL OR ur.role_id = ?)";

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
                 "JOIN UserRoles ur ON u.user_id = ur.user_id " +
                 "JOIN Roles r ON ur.role_id = r.role_id " +
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
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setAddress(rs.getString("address"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone_number"));
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
        "JOIN UserRoles ur ON u.user_id = ur.user_id " +
        "JOIN Roles r ON ur.role_id = r.role_id " +
        "WHERE 1=1 "
    );

    // Danh sách tham số tương ứng với câu lệnh SQL
    List<Object> params = new ArrayList<>();

    if (name != null && !name.trim().isEmpty()) {
        sql.append("AND u.full_name LIKE ? ");
        params.add("%" + name.trim() + "%");
    }

    if (roleId != null && roleId > 0) {
        sql.append("AND r.role_id = ? ");
        params.add(roleId);
    }

    if (status != null && !status.trim().isEmpty()) {
        sql.append("AND u.status = ? ");
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
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setAddress(rs.getString("address"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone_number"));
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

//public int countUsersByNameRoleStatus(String name, Integer roleId, String status) throws SQLException {
//    StringBuilder sql = new StringBuilder(
//        "SELECT COUNT(*) FROM Users u " +
//        "JOIN UserRoles ur ON u.user_id = ur.user_id " +
//        "JOIN Roles r ON r.role_id = ur.role_id WHERE 1=1"
//    );
//
//    List<Object> params = new ArrayList<>();
//
//    if (name != null && !name.isEmpty()) {
//        sql.append(" AND u.full_name LIKE ?");
//        params.add("%" + name + "%");
//    }
//
//    if (roleId != null && roleId != 0) {
//        sql.append(" AND r.role_id = ?");
//        params.add(roleId);
//    }
//
//    if (status != null && !status.isEmpty()) {
//        sql.append(" AND u.status = ?");
//        params.add(status);
//    }
//
//    try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
//        for (int i = 0; i < params.size(); i++) {
//            stmt.setObject(i + 1, params.get(i));
//        }
//
//        try (ResultSet rs = stmt.executeQuery()) {
//            if (rs.next()) return rs.getInt(1);
//        }
//    }
//
//    return 0;
//}
public int countUsersByNameRoleStatus(String search, Integer roleId, String status) throws SQLException {
    StringBuilder sql = new StringBuilder(
        "SELECT COUNT(*) FROM Users u " +
        "JOIN UserRoles ur ON u.user_id = ur.user_id " +
        "JOIN Roles r ON ur.role_id = r.role_id " +
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
        "JOIN UserRoles ur ON u.user_id = ur.user_id " +
        "JOIN Roles r ON ur.role_id = r.role_id " +
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
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setAddress(rs.getString("address"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone_number"));
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


}
