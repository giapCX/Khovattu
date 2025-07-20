/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Dal.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author ASUS
 */
public class DashboardDirectorDAO {

    public int countTotalMaterials() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Materials WHERE status = 'active'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countLowStockMaterials(int threshold) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Inventory WHERE quantity_in_stock < ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int countActiveSuppliers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Suppliers WHERE status = 'active'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    public int countOngoingSites() throws SQLException {
        String sql = "SELECT COUNT(*) FROM ConstructionSites WHERE status = 'ongoing'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("Ongoing sites count: " + count);
                return count;
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in countOngoingSites: " + e.getMessage());
            throw e;
        }
        return 0;
    }
    
     public int countUsers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users u JOIN Roles r ON u.role_id = r.role_id " +
                    "WHERE u.status = 'active' AND r.role_name IN ('warehouse', 'employee')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("Warehouse and Employee count: " + count);
                return count;
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in countWarehouseAndEmployeeUsers: " + e.getMessage());
            throw e;
        }
        return 0;
    }
     
     public int countPendingDirectorProposals() throws SQLException {
        String sql = "SELECT COUNT(*) FROM ProposalApprovals WHERE director_status = 'pending'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("Pending director proposals count: " + count);
                return count;
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in countPendingDirectorProposals: " + e.getMessage());
            throw e;
        }
        return 0;
    }
}
