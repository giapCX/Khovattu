//exDAO
package dao;

import Dal.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Date;
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

    public int createExportProposal(int proposerId, int receiverId, String note) throws SQLException {
        String sql = "INSERT INTO EmployeeProposals (proposal_type, proposer_id, receiver_id, note, proposal_sent_date) "
                + "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, "export");
            stmt.setInt(2, proposerId);
            stmt.setInt(3, receiverId);
            stmt.setString(4, note);
            stmt.executeUpdate();
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1); // Return generated proposal_id
            }
        }
        return -1;
    }

    public int saveExport(Export export) throws SQLException {
        String sql = "INSERT INTO ExportReceipts (receipt_id, executor_id, receiver_id, proposal_id, export_date, note) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, export.getReceiptId());
            stmt.setInt(2, export.getExporterId());
            stmt.setInt(3, export.getReceiverId());
            stmt.setInt(4, export.getProposalId());
            stmt.setDate(5, Date.valueOf(export.getExportDate()));
            stmt.setString(6, export.getNote());
            stmt.executeUpdate();

            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1); // Return generated export_id
            }
        }
        return -1;
    }

    public void saveExportDetails(List<ExportDetail> details, int exportId) throws SQLException {
        String sql = "INSERT INTO ExportDetails (export_id, material_id, site_id, quantity, material_condition) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (ExportDetail detail : details) {
                stmt.setInt(1, exportId);
                stmt.setInt(2, detail.getMaterialId());
                stmt.setInt(3, detail.getSiteId()); // LUÔN phải có site_id
                stmt.setDouble(4, detail.getQuantity());
                stmt.setString(5, detail.getMaterialCondition());
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
        String sql = "SELECT export_id, receipt_id, executor_id, receiver_id, proposal_id, export_date, note "
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
                export.setProposalId(rs.getInt("proposal_id"));
                export.setExportDate(rs.getDate("export_date").toLocalDate());
                export.setNote(rs.getString("note"));
                return export;
            }
        }
        return null; // Return null if no export is found
    }
}
