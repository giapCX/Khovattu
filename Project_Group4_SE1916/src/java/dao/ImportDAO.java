package dao;

import java.sql.Types;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

import Dal.DBContext;
import model.Import;
import model.ImportDetail;

public class ImportDAO {

    private Connection conn;

    public ImportDAO() {
        this.conn = DBContext.getConnection();
    }

    public ImportDAO(Connection conn) {
        this.conn = conn;
    }

    public boolean addImport(Import importOb) throws SQLException {
        String insertImportSQL = "INSERT INTO ImportReceipts(proposal_id, import_type, responsible_id, executor_id, note, import_date) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        conn.setAutoCommit(false);

        try (PreparedStatement ps = conn.prepareStatement(insertImportSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {

            // 1. proposal_id
            ps.setInt(1, importOb.getProposalId());

            // 2. import_type
            ps.setString(2, importOb.getImportType());

            // 3. responsible_id (nullable)
            if (importOb.getResponsibleId() != null) {
                ps.setInt(3, importOb.getResponsibleId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }

            // 4. executor_id (nullable)
            if (importOb.getExecutorId() != null) {
                ps.setInt(4, importOb.getExecutorId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }

            // 5. note
            ps.setString(5, importOb.getNote());

            // 6. import_date
            ps.setTimestamp(6, importOb.getImportDate());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int importId = rs.getInt(1);
                        if (addImportDetails(importId, importOb.getImportDetail())) {
                            conn.commit();
                            return true;
                        }
                    }
                }
            }

            conn.rollback();
            return false;
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    private boolean addImportDetails(int importId, List<ImportDetail> details) throws SQLException {
        String insertDetailSQL = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition, supplier_id, site_id) "
                + "VALUES ( ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(insertDetailSQL)) {
            for (ImportDetail detail : details) {
                ps.setInt(1, importId);
                ps.setInt(2, detail.getMaterialId());
                ps.setDouble(3, detail.getQuantity());

                // 5. price (nullable)
                if (detail.getPrice() != null) {
                    ps.setDouble(4, detail.getPrice());
                } else {
                    ps.setNull(4, Types.DOUBLE);
                }

                // 6. material_condition
                ps.setString(5, detail.getMaterialCondition());

                // 7. supplier_id (nullable)
                if (detail.getSupplierId() != null) {
                    ps.setInt(6, detail.getSupplierId());
                } else {
                    ps.setNull(6, Types.INTEGER);
                }

                // 8. site_id (nullable)
                if (detail.getSiteId() != null) {
                    ps.setInt(7, detail.getSiteId());
                } else {
                    ps.setNull(7, Types.INTEGER);
                }

                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r == PreparedStatement.EXECUTE_FAILED) {
                    return false;
                }
            }

            return true;
        }
    }

    public void addToInventory(List<ImportDetail> details) throws SQLException {
        for (ImportDetail detail : details) {
            addToInventory(detail);
        }
    }

    public void addToInventory(ImportDetail detail) throws SQLException {
        String updateSQL = "UPDATE Inventory SET quantity_in_stock = quantity_in_stock + ? "
                + "WHERE material_id = ? AND material_condition = ?";
        String insertSQL = "INSERT INTO Inventory (material_id, material_condition, quantity_in_stock) "
                + "VALUES (?, ?, ?)";

        try (PreparedStatement updateStmt = conn.prepareStatement(updateSQL)) {
            updateStmt.setDouble(1, detail.getQuantity());
            updateStmt.setInt(2, detail.getMaterialId());
            updateStmt.setString(3, detail.getMaterialCondition());

            int updated = updateStmt.executeUpdate();

            if (updated == 0) {
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSQL)) {
                    insertStmt.setInt(1, detail.getMaterialId());
                    insertStmt.setString(2, detail.getMaterialCondition());
                    insertStmt.setDouble(3, detail.getQuantity());
                    insertStmt.executeUpdate();
                }
            }
        }
    }
    
    public void updateProposalStatusToExecuted(int proposalId) throws SQLException {
    String sql = "UPDATE EmployeeProposals  SET  final_status = ? WHERE proposal_id = ?";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, "executed");
        ps.setInt(2, proposalId);
        ps.executeUpdate();
    }
}


}
