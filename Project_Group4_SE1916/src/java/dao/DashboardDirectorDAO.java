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
import java.util.ArrayList;
import java.util.List;
import model.ImportPrice;

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
        String sql = "SELECT COUNT(*) FROM ProposalApprovals WHERE director_status = 'pending' AND admin_status = 'approved'";
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
     
    public List<ImportPrice> getImportPrices() throws SQLException {
        List<ImportPrice> importPrices = new ArrayList<>();
        String sql = "SELECT id.material_id, m.name, id.price_per_unit " +
                     "FROM ImportDetails id JOIN Materials m ON id.material_id = m.material_id " +
                     "WHERE id.price_per_unit IS NOT NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ImportPrice importPrice = new ImportPrice();
                importPrice.setMaterialId(rs.getInt("material_id"));
                importPrice.setMaterialName(rs.getString("name"));
                importPrice.setPricePerUnit(rs.getBigDecimal("price_per_unit"));
                importPrices.add(importPrice);
            }
            System.out.println("Retrieved import prices count: " + importPrices.size());
            return importPrices;
        } catch (SQLException e) {
            System.err.println("SQL Error in getImportPrices: " + e.getMessage());
            throw e;
        }
    }
    
     public List<ImportPrice> getAverageImportPricesByMonth(int year) throws SQLException {
        List<ImportPrice> averagePrices = new ArrayList<>();
        String sql = "SELECT MONTH(ir.import_date) AS month, AVG(id.price_per_unit) AS avg_price " +
                     "FROM ImportDetails id JOIN ImportReceipts ir ON id.import_id = ir.import_id " +
                     "WHERE YEAR(ir.import_date) = ? AND id.price_per_unit IS NOT NULL " +
                     "GROUP BY MONTH(ir.import_date) ORDER BY MONTH(ir.import_date)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportPrice importPrice = new ImportPrice();
                    importPrice.setMaterialName("Month " + rs.getInt("month"));
                    importPrice.setPricePerUnit(rs.getBigDecimal("avg_price"));
                    averagePrices.add(importPrice);
                }
                System.out.println("Retrieved average import prices for year " + year + ": " + averagePrices.size());
                return averagePrices;
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in getAverageImportPricesByMonth: " + e.getMessage());
            throw e;
        }
    }
}
