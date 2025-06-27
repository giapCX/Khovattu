//ExportDAO
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
import java.sql.Statement;
import java.sql.Date;
import java.sql.Types;
import java.util.List;

import model.Export;
import model.ExportDetail;

/**
 *
 * @author ASUS
 */
public class ExportDAO {

    private Connection conn;

    public ExportDAO() {
        this.conn = DBContext.getConnection();
    }

    public ExportDAO(Connection conn) {
        this.conn = conn;
    }

    public int saveExport(Export export) throws SQLException {
        String sql = "INSERT INTO ExportReceipts (voucher_id, user_id, export_date, note) VALUES (?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, export.getVoucherId());
            stmt.setInt(2, export.getUserId());
            stmt.setDate(3, Date.valueOf(export.getExportDate()));
            stmt.setString(4, export.getNote());
            stmt.executeUpdate();

            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1); // return generated export_id
            }
        }
        return -1;
    }

    public void saveExportDetails(List<ExportDetail> details, int exportId) throws SQLException {
        String sql = "INSERT INTO ExportDetails (export_id, material_id, quantity, material_condition, reason) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (ExportDetail detail : details) {
                stmt.setInt(1, exportId);
                stmt.setInt(2, detail.getMaterialId());
                stmt.setDouble(3, detail.getQuantity()); // Sửa: dùng setDouble
                stmt.setString(4, detail.getMaterialCondition());
                stmt.setString(5, detail.getReason());
                stmt.addBatch();
            }
            stmt.executeBatch();
        }
    }

    public boolean checkVoucherIdExists(String voucherId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ExportReceipts WHERE voucher_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, voucherId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    //hàm getExportById
    public Export getExportById(int exportId) throws SQLException {
        String sql = "SELECT export_id, voucher_id, user_id, export_date, note FROM ExportReceipts WHERE export_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, exportId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Export export = new Export();
                export.setExportId(rs.getInt("export_id"));
                export.setVoucherId(rs.getString("voucher_id"));
                export.setUserId(rs.getInt("user_id"));
                export.setExportDate(rs.getDate("export_date").toLocalDate());
                export.setNote(rs.getString("note"));
                return export;
            }
        }
        return null; // Return null if no export is found
    }

}
