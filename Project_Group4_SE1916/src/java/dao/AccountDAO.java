
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Dal.DBContext;
import java.sql.*;
import java.util.*;
import model.Account;
import model.Role;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.mindrot.jbcrypt.BCrypt;

/**
 *
 * @author ASUS
 */
public class AccountDAO extends DBContext {

    protected Connection connection;

    public AccountDAO() {
        this.connection = DBContext.getConnection();
    }

    public AccountDAO(Connection connection) {
        this.connection = connection;
    }

    public void updatePassword(String username, String newPassword) {
        String sql = "UPDATE users SET password_hash = ?, status = 'active' WHERE username = ?";

        try {
            String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, hashedPassword);
            stm.setString(2, username);
            stm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(AccountDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public String getPasswordByUsername(String username) {
        String password = null;
        try {
            Connection conn = DBContext.getConnection();
            String sql = "SELECT password_hash FROM users WHERE username = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                password = rs.getString("password_hash");
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return password;
    }

    public Account checkAccountExisted(String username) {
        String sql = "SELECT * FROM users "
                + "WHERE username = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql); //open conextion with SQL
            stm.setString(1, username);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                return new Account(rs.getString(1),
                        rs.getString(2),
                        rs.getString(3));
            }
        } catch (Exception e) {
            System.out.println(e);
        }
        return null;
    }

}
