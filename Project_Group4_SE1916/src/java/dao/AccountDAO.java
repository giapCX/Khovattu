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

    public void updatePassword(String username, String newpassword) {
        String sql = "UPDATE users SET password_hash = ?, status = 'active' WHERE username = ?";
//        securityProcessorCore spc = new securityProcessorCore();
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
//            stm.setString(1, spc.md5EncodePassword(newpassword));
            stm.setString(1, newpassword);
            stm.setString(2, username);
            stm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(AccountDAO.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (NoSuchAlgorithmException ex) {
//            Logger.getLogger(AccountDBContext.class.getName()).log(Level.SEVERE, null, ex);
//        }

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
                password = rs.getString("password");
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return password;
    }

    public Account checkAccountExisted(String username) {
        String sql = "SELECT * FROM users \n"
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

    public int getNumberOfPremiumUser() {
        int premium;
        String sql = "SELECT COUNT(*) AS premium FROM [Users] u\n"
                + "JOIN Account a ON a.username = u.username AND a.classify_account = 'premium'";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                premium = rs.getInt("premium");
                return premium;
            }
        } catch (SQLException ex) {
            Logger.getLogger(AccountDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return 0;
    }

    

    public static void main(String[] args) {
        AccountDAO dBContext = new AccountDAO();
        System.out.println(dBContext.getNumberOfPremiumUser());
    }

}
