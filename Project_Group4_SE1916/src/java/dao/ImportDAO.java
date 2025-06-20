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

    public ImportDAO(Connection conn) {
        this.conn = conn;
    }

    public int saveImportReceipt(ImportReceipt receipt, List<ImportDetail> details) throws SQLException {
        String sqlReceipt = "INSERT INTO ImportReceipts (voucher_id, supplier_id, user_id, import_date, note) VALUES (?, ?, ?, ?, ?)";
        String sqlDetail = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition, supplier_id) VALUES (?, ?, ?, ?, ?, ?)";
        String sqlInventory = "INSERT INTO Inventory (material_id, material_condition, quantity_in_stock) VALUES (?, ?, ?) " +
                             "ON DUPLICATE KEY UPDATE quantity_in_stock = quantity_in_stock + ?, last_updated = CURRENT_TIMESTAMP";

        int importId = -1;
        try {
            System.out.println("ImportDAO: Saving receipt: voucherId=" + receipt.getVoucherId() + ", supplierId=" + receipt.getSupplierId() + ", userId=" + receipt.getUserId());

            try (PreparedStatement stmtReceipt = conn.prepareStatement(sqlReceipt, PreparedStatement.RETURN_GENERATED_KEYS)) {
                stmtReceipt.setString(1, receipt.getVoucherId());
                stmtReceipt.setInt(2, receipt.getSupplierId());
                stmtReceipt.setInt(3, receipt.getUserId());
                stmtReceipt.setDate(4, receipt.getImportDate());
                stmtReceipt.setString(5, receipt.getNote());
                int rowsAffected = stmtReceipt.executeUpdate();
                System.out.println("ImportDAO: Receipt inserted, rows affected: " + rowsAffected);

                try (ResultSet generatedKeys = stmtReceipt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        importId = generatedKeys.getInt(1);
                        System.out.println("ImportDAO: Generated importId: " + importId);
                    } else {
                        throw new SQLException("Creating receipt failed, no ID obtained.");
                    }
                }
            }

            try (PreparedStatement stmtDetail = conn.prepareStatement(sqlDetail)) {
                for (ImportDetail detail : details) {
                    System.out.println("ImportDAO: Saving detail: materialId=" + detail.getMaterialId() + ", supplierId=" + detail.getSupplierId() + ", quantity=" + detail.getQuantity());
                    stmtDetail.setInt(1, importId);
                    stmtDetail.setInt(2, detail.getMaterialId());
                    stmtDetail.setDouble(3, detail.getQuantity());
                    stmtDetail.setDouble(4, detail.getPricePerUnit());
                    stmtDetail.setString(5, detail.getMaterialCondition());
                    stmtDetail.setInt(6, detail.getSupplierId());
                    stmtDetail.addBatch();
                }
                int[] batchResult = stmtDetail.executeBatch();
                System.out.println("ImportDAO: Details inserted, batch result: " + java.util.Arrays.toString(batchResult));
            }

            try (PreparedStatement stmtInventory = conn.prepareStatement(sqlInventory)) {
                for (ImportDetail detail : details) {
                    stmtInventory.setInt(1, detail.getMaterialId());
                    stmtInventory.setString(2, detail.getMaterialCondition());
                    stmtInventory.setDouble(3, detail.getQuantity());
                    stmtInventory.setDouble(4, detail.getQuantity());
                    stmtInventory.addBatch();
                }
                int[] batchResult = stmtInventory.executeBatch();
                System.out.println("ImportDAO: Inventory updated, batch result: " + java.util.Arrays.toString(batchResult));
            }

            System.out.println("ImportDAO: Transaction committed successfully");
            return importId;
        } catch (SQLException e) {
            System.err.println("ImportDAO: SQLException: " + e.getMessage());
            throw e;
        }
    }

    public boolean voucherIdExists(String voucherId) throws SQLException {
        String sql = "SELECT 1 FROM ImportReceipts WHERE LOWER(voucher_id) = LOWER(?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, voucherId);
            try (ResultSet rs = ps.executeQuery()) {
                boolean exists = rs.next();
                System.out.println("ImportDAO: Checking voucherId " + voucherId + " exists: " + exists);
                return exists;
            }
        }
    }
}