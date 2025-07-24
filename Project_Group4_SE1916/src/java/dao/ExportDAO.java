//exDAO
package dao;

import Dal.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;

import java.util.List;
import java.sql.*;

import model.Export;
import model.ExportDetail;
import model.User;

public class ExportDAO {

    private Connection conn;

    public ExportDAO() {
        this.conn = DBContext.getConnection();
    }

    public ExportDAO(Connection conn) {
        this.conn = conn;
    }

    public boolean checkProposalIdExists(int proposalId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ExportReceipts WHERE proposal_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, proposalId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    public int saveExport(Export export) throws SQLException {
        String sql = "INSERT INTO ExportReceipts (proposal_id, executor_id, receiver_id, export_date, note, site_id) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        conn.setAutoCommit(false);
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, export.getProposalId());
            ps.setInt(2, export.getExporterId());
            ps.setInt(3, export.getReceiverId());
            ps.setTimestamp(4, export.getExportDate());
            ps.setString(5, export.getNote());
            ps.setInt(6, export.getSiteId());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int exportId = rs.getInt(1);
                        if (export.getExportDetail() != null && !export.getExportDetail().isEmpty()) {
                            if (addExportDetails(exportId, export.getExportDetail())) {
                                conn.commit();
                                return exportId;
                            }
                        } else {
                            conn.rollback();
                            return -1;
                        }
                    }
                }
            }
            conn.rollback();
            return -1;
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    private boolean addExportDetails(int exportId, List<ExportDetail> details) throws SQLException {
        String sql = "INSERT INTO ExportDetails (export_id, material_id, quantity, material_condition) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (ExportDetail detail : details) {
                ps.setInt(1, exportId);
                ps.setInt(2, detail.getMaterialId());
                ps.setDouble(3, detail.getQuantity());
                ps.setString(4, detail.getMaterialCondition());
                ps.addBatch();
            }
            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r == Statement.EXECUTE_FAILED) {
                    return false;
                }
            }
            return true;
        }
    }

    public void exportMaterial(int exportId, List<ExportDetail> details) throws SQLException {
        conn.setAutoCommit(false);
        try {
            for (ExportDetail detail : details) {
                String updateSql = "UPDATE Inventory SET quantity_in_stock = quantity_in_stock - ? "
                        + "WHERE material_id = ? AND material_condition = ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setDouble(1, detail.getQuantity());
                    updateStmt.setInt(2, detail.getMaterialId());
                    updateStmt.setString(3, detail.getMaterialCondition());
                    int updated = updateStmt.executeUpdate();
                    if (updated == 0) {
                        throw new SQLException("Cannot update inventory for material ID " + detail.getMaterialId() + " with condition " + detail.getMaterialCondition());
                    }
                }
                String insertDetailSql = "INSERT INTO ExportDetails (export_id, material_id, quantity, material_condition) VALUES (?, ?, ?, ?)";
                try (PreparedStatement insertStmt = conn.prepareStatement(insertDetailSql)) {
                    insertStmt.setInt(1, exportId);
                    insertStmt.setInt(2, detail.getMaterialId());
                    insertStmt.setDouble(3, detail.getQuantity());
                    insertStmt.setString(4, detail.getMaterialCondition());
                    insertStmt.executeUpdate();
                }
            }
            conn.commit();
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    public void updateProposalStatusToExecuted(int proposalId) throws SQLException {
        String sql = "UPDATE EmployeeProposals SET final_status = ? WHERE proposal_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "executed");
            ps.setInt(2, proposalId);
            ps.executeUpdate();
        }
    }

    public List<Export> searchExportsWithPagination(String purpose, String executor, String fromDate, String toDate, int page, int pageSize) throws SQLException {
        List<Export> result = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT e.export_id, e.proposal_id, e.executor_id, e.receiver_id, e.export_date, e.note, e.site_id, u.full_name "
                + "FROM ExportReceipts e "
                + "JOIN Users u ON e.executor_id = u.user_id "
                + "JOIN EmployeeProposals ep ON e.proposal_id = ep.proposal_id "
                + "WHERE 1=1"
        );

        List<Object> params = new ArrayList<>();

        if (purpose != null && !purpose.isEmpty()) {
            sql.append(" AND ep.purpose LIKE ?");
            params.add("%" + purpose + "%");
        }

        if (executor != null && !executor.isEmpty()) {
            sql.append(" AND u.full_name LIKE ?");
            params.add("%" + executor + "%");
        }

        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(e.export_date) >= ?");
            params.add(Date.valueOf(fromDate));
        }

        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(e.export_date) <= ?");
            params.add(Date.valueOf(toDate));
        }

        int offset = (page - 1) * pageSize;
        if (offset < 0) {
            offset = 0;
        }
        sql.append(" ORDER BY e.export_date DESC LIMIT ?, ?");
        params.add(offset);
        params.add(pageSize);

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Export export = new Export();
                export.setExportId(rs.getInt("export_id"));
                export.setProposalId(rs.getInt("proposal_id"));
                export.setExporterId(rs.getInt("executor_id"));
                export.setReceiverId(rs.getInt("receiver_id"));
                export.setExportDate(rs.getTimestamp("export_date"));
                export.setNote(rs.getString("note"));
                export.setSiteId(rs.getInt("site_id"));
                User executorObj = new User();
                executorObj.setUserId(rs.getInt("executor_id"));
                executorObj.setFullName(rs.getString("full_name"));
                export.setExecutor(executorObj);
                result.add(export);
            }
        }
        return result;
    }

    public int countSearchExports(String purpose, String executor, String fromDate, String toDate) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM ExportReceipts e "
                + "JOIN Users u ON e.executor_id = u.user_id "
                + "JOIN EmployeeProposals ep ON e.proposal_id = ep.proposal_id WHERE 1=1"
        );

        List<Object> params = new ArrayList<>();

        if (purpose != null && !purpose.isEmpty()) {
            sql.append(" AND ep.purpose LIKE ?");
            params.add("%" + purpose + "%");
        }

        if (executor != null && !executor.isEmpty()) {
            sql.append(" AND u.full_name LIKE ?");
            params.add("%" + executor + "%");
        }

        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(e.export_date) >= ?");
            params.add(Date.valueOf(fromDate));
        }

        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(e.export_date) <= ?");
            params.add(Date.valueOf(toDate));
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
}
