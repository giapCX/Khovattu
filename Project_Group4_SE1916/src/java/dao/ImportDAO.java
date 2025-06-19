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

    public boolean saveImportReceipt(ImportReceipt receipt, List<ImportDetail> details) throws SQLException {
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
                            return addImportDetails(importId, details);
                        }
                    }
                }
            }
            return false;
        }
    }

    private boolean addImportDetails(int importId, List<ImportDetail> detailsList) throws SQLException {
        String insertDetailSQL = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertDetailSQL)) {
            conn.setAutoCommit(false);
            try {
                for (ImportDetail detail : detailsList) {
                    ps.setInt(1, importId);
                    ps.setInt(2, detail.getMaterialId());
                    ps.setDouble(3, detail.getQuantity());
                    ps.setDouble(4, detail.getPricePerUnit());
                    ps.setString(5, detail.getMaterialCondition());
                    ps.addBatch();
                }
                int[] result = ps.executeBatch();
                for (int i : result) {
                    if (i == PreparedStatement.EXECUTE_FAILED) {
                        conn.rollback();
                        return false;
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
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
