/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author Giap
 */
import Dal.DBContext;
import model.ImportReceipt;
import model.ImportDetail;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class ImportDAO {

    private Connection conn;

    public ImportDAO() {
        this.conn = DBContext.getConnection();
    }

    public void saveImportReceipt(ImportReceipt receipt, List<ImportDetail> details) throws SQLException {
        String sqlReceipt = "INSERT INTO ImportReceipts (supplier_id, user_id, import_date, note) VALUES (?, ?, ?, ?)";
        String sqlDetail = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition) VALUES (?, ?, ?, ?, ?)";

        try {
            conn.setAutoCommit(false);

            // Insert receipt
            try (PreparedStatement stmtReceipt = conn.prepareStatement(sqlReceipt, PreparedStatement.RETURN_GENERATED_KEYS)) {
                stmtReceipt.setInt(1, receipt.getSupplierId());
                stmtReceipt.setInt(2, receipt.getUserId());
                stmtReceipt.setDate(3, receipt.getImportDate());
                stmtReceipt.setString(4, receipt.getNote());
                stmtReceipt.executeUpdate();

                // Get generated import_id
                int importId;
                try (ResultSet generatedKeys = stmtReceipt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        importId = generatedKeys.getInt(1);
                    } else {
                        throw new SQLException("Creating receipt failed, no ID obtained.");
                    }
                }

                // Insert details
                try (PreparedStatement stmtDetail = conn.prepareStatement(sqlDetail)) {
                    for (ImportDetail detail : details) {
                        stmtDetail.setInt(1, importId);
                        stmtDetail.setInt(2, detail.getMaterialId());
                        stmtDetail.setDouble(3, detail.getQuantity());
                        stmtDetail.setDouble(4, detail.getPricePerUnit());
                        stmtDetail.setString(5, detail.getMaterialCondition());
                        stmtDetail.addBatch();
                    }
                    stmtDetail.executeBatch();
                }

                conn.commit();
            }
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }
    public boolean voucherIdExists(String voucherId) throws SQLException {
        String sql = "SELECT 1 FROM ImportReceipts WHERE voucher_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, voucherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
