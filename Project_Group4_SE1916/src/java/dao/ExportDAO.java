//exDAO

package dao;

import Dal.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Date;
import java.util.Arrays;
import java.util.List;
import model.Export;
import model.ExportDetail;

public class ExportDAO {

    private Connection conn;

    public ExportDAO() {
        this.conn = DBContext.getConnection();
    }

    public ExportDAO(Connection conn) {
        this.conn = conn;
    }

    public int saveExport(Export export) throws SQLException {
        String sql = "INSERT INTO ExportReceipts (executor_id, receiver_id, export_date, note, site_id) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            //stmt.setString(1, export.getReceiptId());
            stmt.setInt(1, export.getExporterId());
            stmt.setInt(2, export.getReceiverId());
            stmt.setDate(3, Date.valueOf(export.getExportDate()));
            stmt.setString(4, export.getNote());
            stmt.setInt(5, export.getSiteId());
            stmt.executeUpdate();

            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1); // Return generated export_id
            }
        }
        return -1;
    }

    public void saveExportDetails(List<ExportDetail> details, int exportId) throws SQLException {
        String sql = "INSERT INTO ExportDetails (export_id, material_id, quantity, material_condition) VALUES (?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (ExportDetail detail : details) {
                stmt.setInt(1, exportId);
                stmt.setInt(2, detail.getMaterialId());
                stmt.setDouble(3, detail.getQuantity());
                stmt.setString(4, detail.getMaterialCondition());

                stmt.addBatch();
            }
            stmt.executeBatch();
        }
    }

    public boolean checkReceiptIdExists(String receiptId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ExportReceipts WHERE receipt_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, receiptId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    public Export getExportById(int exportId) throws SQLException {
        String sql = "SELECT export_id, receipt_id, executor_id, receiver_id, export_date, note, site_id "
                + "FROM ExportReceipts WHERE export_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, exportId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Export export = new Export();
                export.setExportId(rs.getInt("export_id"));
                export.setReceiptId(rs.getString("receipt_id"));
                export.setExporterId(rs.getInt("executor_id"));
                export.setReceiverId(rs.getInt("receiver_id"));
                export.setExportDate(rs.getDate("export_date").toLocalDate());
                export.setNote(rs.getString("note"));
                export.setSiteId(rs.getInt("site_id"));
                return export;
            }
        }
        return null; // Return null if no export is found
    }

    public void exportMaterial(int exportId, int materialId, double quantity, String condition) throws SQLException {
        // Insert export detail
        String insertDetailSql = "INSERT INTO ExportDetails (export_id, material_id, quantity, material_condition) " +
                                "VALUES (?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(insertDetailSql)) {
            stmt.setInt(1, exportId);
            stmt.setInt(2, materialId);
            stmt.setDouble(3, quantity);
            stmt.setString(4, condition);
            stmt.executeUpdate();
        }

        // Update inventory
        String updateInventorySql = "UPDATE Inventory SET quantity_in_stock = quantity_in_stock - ? " +
                                   "WHERE material_id = ? AND material_condition = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateInventorySql)) {
            stmt.setDouble(1, quantity);
            stmt.setInt(2, materialId);
            stmt.setString(3, condition);
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Cannot update inventory  " + materialId);
            }
        }
    }
}
