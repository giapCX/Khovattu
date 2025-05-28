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

    public Account checkAccountExisted(String username) {
        String sql = "SELECT * FROM Account \n"
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
        String sql = "SELECT COUNT(*) AS premium FROM [User] u\n"
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

    public void signup(String username, String password) {
//        securityProcessorCore spc = new securityProcessorCore();
        String sql = "INSERT INTO [dbo].[Account]\n"
                + "           ([username]\n"
                + "           ,[password]\n"
                + "           ,[classify_account])\n"
                + "     VALUES\n"
                + "           (?,\n"
                + "           ?,\n"
                + "           'normal')";

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            stm.setString(2, password);
            stm.executeUpdate();
        } catch (Exception e) {
        }
    }

    public void fillin4(String username, String password) {
        String sql = "INSERT INTO [dbo].[Account]\n"
                + "           ([username]\n"
                + "           ,[password]\n"
                + "           ,[classify_account])\n"
                + "     VALUES\n"
                + "           (?,\n"
                + "           ?,\n"
                + "           'nomal')";

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            stm.setString(2, password);
            stm.executeUpdate();
        } catch (Exception e) {
        }
    }

    public void insertRoll(int role_id, String username) {
        String sql = "INSERT INTO [dbo].[Role_Account]\n"
                + "           ([role_id]\n"
                + "           ,[username])\n"
                + "     VALUES\n"
                + "           (?\n"
                + "           ,?)";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, role_id);
            stm.setString(2, username);
            stm.executeUpdate();
        } catch (Exception e) {
        }
    }

    public Account login(String username, String password) {
//        securityProcessorCore spc = new securityProcessorCore();
        try {
            String sql = "SELECT a.username,a.classify_account\n"
                    + ",r.role_id, r.role_name,\n"
                    + "f.fe_id,f.fe_name,f.[url]\n"
                    + "FROM Account a\n"
                    + "LEFT JOIN Role_Account ra ON a.username = ra.username\n"
                    + "LEFT JOIN [Role] r ON r.role_id= ra.role_id\n"
                    + "LEFT JOIN Role_Feature rf ON rf.role_id = r.role_id\n"
                    + "LEFT JOIN Feature f ON f.fe_id = rf.fe_id\n"
                    + "WHERE a.username = ? AND a.password = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            stm.setString(2, password);
            ResultSet rs = stm.executeQuery();
            Account account = null;
            Role currentRole = new Role();
            currentRole.setRoleId(-1);
            while (rs.next()) {
                if (account == null) {
                    account = new Account();
                    account.setUsername(rs.getString("username"));
                    account.setClassify_account(rs.getString("classify_account"));
                }
                int rid = rs.getInt("role_id");
                if (rid != 0) {
                    if (rid != currentRole.getRoleId()) {
                        currentRole = new Role();
                        currentRole.setRoleId(rs.getInt("role_id"));
                        currentRole.setRoleId(rs.getInt("role_name"));
                        account.getRoles().add(currentRole);
                    }
                }

                int fid = rs.getInt("fe_id");

            }
            return account;
        } catch (SQLException ex) {
            Logger.getLogger(Account.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (NoSuchAlgorithmException ex) {
//            Logger.getLogger(AccountDBContext.class.getName()).log(Level.SEVERE, null, ex);
//        }
            return null;
        }
    }

    public static void main(String[] args) {
        AccountDAO dBContext = new AccountDAO();
        System.out.println(dBContext.getNumberOfPremiumUser());
    }

   
    
}
