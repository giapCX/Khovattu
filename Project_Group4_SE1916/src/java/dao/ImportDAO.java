package dao;

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

    public ImportDAO(Connection conn) {
        this.conn = conn;
    }

    public int saveImportReceipt(ImportReceipt receipt, List<ImportDetail> details) throws SQLException {
        String insertReceiptSQL = "INSERT INTO ImportReceipts (voucher_id, supplier_id, user_id, import_date, note) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertReceiptSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, receipt.getVoucherId());
            ps.setInt(2, receipt.getSupplierId());
            ps.setInt(3, receipt.getUserId());
            ps.setDate(4, receipt.getImportDate());
            ps.setString(5, receipt.getNote());
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int importId = rs.getInt(1);
                        if (details != null && !details.isEmpty()) {
                            addImportDetails(importId, details);
                            updateInventory(importId, details); // Cập nhật kho
                        }
                        return importId;
                    }
                }
            }
            return -1;
        }
    }

    private void addImportDetails(int importId, List<ImportDetail> detailsList) throws SQLException {
        String insertDetailSQL = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertDetailSQL)) {
            conn.setAutoCommit(false);
            try {
                for (ImportDetail detail : detailsList) {
                    detail.setImportId(importId); // Gán importId cho từng detail
                    ps.setInt(1, importId);
                    ps.setInt(2, detail.getMaterialId());
                    ps.setDouble(3, detail.getQuantity());
                    ps.setDouble(4, detail.getPricePerUnit());
                    ps.setString(5, detail.getMaterialCondition());
                    ps.addBatch();
                }
                ps.executeBatch();
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private void updateInventory(int importId, List<ImportDetail> details) throws SQLException {
        String sql = "INSERT INTO Inventory (material_id, material_condition, quantity_in_stock) VALUES (?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE quantity_in_stock = quantity_in_stock + ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (ImportDetail detail : details) {
                ps.setInt(1, detail.getMaterialId());
                ps.setString(2, detail.getMaterialCondition());
                ps.setDouble(3, detail.getQuantity());
                ps.setDouble(4, detail.getQuantity());
                ps.addBatch();
            }
            ps.executeBatch();
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