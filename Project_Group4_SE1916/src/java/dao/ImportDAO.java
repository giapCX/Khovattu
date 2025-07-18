package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Import;
import model.ImportDetail;
import Dal.DBContext;
import model.User;

public class ImportDAO {

    private Connection conn;

    public ImportDAO() {
        this.conn = DBContext.getConnection();
    }

    public ImportDAO(Connection conn) {
        this.conn = conn;
    }

    public boolean addImport(Import importOb) throws SQLException {
        String insertImportSQL = "INSERT INTO ImportReceipts (proposal_id, import_type, responsible_id, executor_id, note, import_date, delivery_supplier_name, delivery_supplier_phone) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        conn.setAutoCommit(false);

        try (PreparedStatement ps = conn.prepareStatement(insertImportSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, importOb.getProposalId());
            ps.setString(2, importOb.getImportType());
            ps.setObject(3, importOb.getResponsibleId());
            ps.setObject(4, importOb.getExecutorId());
            ps.setString(5, importOb.getNote());
            ps.setTimestamp(6, importOb.getImportDate());
            ps.setString(7, importOb.getDeliverySupplierName());
            ps.setString(8, importOb.getDeliverySupplierPhone());

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
        String insertDetailSQL = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(insertDetailSQL)) {
            if (details != null) {
                for (ImportDetail detail : details) {
                    ps.setInt(1, importId);
                    ps.setInt(2, detail.getMaterialId());
                    ps.setDouble(3, detail.getQuantity());
                    ps.setObject(4, detail.getPrice());
                    ps.setString(5, detail.getMaterialCondition());
                    ps.addBatch();
                }
                int[] results = ps.executeBatch();
                for (int r : results) {
                    if (r == PreparedStatement.EXECUTE_FAILED) {
                        return false;
                    }
                }
            }
            return true;
        }
    }

    public void addToInventory(List<ImportDetail> details) throws SQLException {
        if (details != null) {
            for (ImportDetail detail : details) {
                addToInventory(detail);
            }
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
<<<<<<< Updated upstream
        String sql = "UPDATE EmployeeProposals  SET  final_status = ? WHERE proposal_id = ?";
=======
        String sql = "UPDATE EmployeeProposals SET final_status = ? WHERE proposal_id = ?";
>>>>>>> Stashed changes

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "executed");
            ps.setInt(2, proposalId);
            ps.executeUpdate();
        }
    }

    public List<Import> searchImportsWithPagination(String proposalType, String executor, String fromDate, String toDate, int page, int pageSize) throws SQLException {
        List<Import> result = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
<<<<<<< Updated upstream
                "SELECT i.import_id, i.proposal_id, i.import_type, i.executor_id, i.import_date, i.note, u.full_name "
                + "FROM ImportReceipts i "
                + "JOIN Users u ON i.executor_id = u.user_id "
                + "WHERE 1=1"
        );
=======
                "SELECT i.import_id, i.proposal_id, i.import_type, i.executor_id, i.import_date, i.note, i.delivery_supplier_name, i.delivery_supplier_phone, u.full_name "
                + "FROM ImportReceipts i "
                + "JOIN Users u ON i.executor_id = u.user_id "
                + "WHERE 1=1");
>>>>>>> Stashed changes

        List<Object> params = new ArrayList<>();

        if (proposalType != null && !proposalType.isEmpty()) {
            sql.append(" AND i.import_type LIKE ?");
            params.add("%" + proposalType + "%");
        }

        if (executor != null && !executor.isEmpty()) {
            sql.append(" AND u.full_name LIKE ?");
            params.add("%" + executor + "%");
        }

        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(i.import_date) >= ?");
<<<<<<< Updated upstream
            params.add(Date.valueOf(fromDate));
=======
            params.add(java.sql.Date.valueOf(fromDate));
>>>>>>> Stashed changes
        }

        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(i.import_date) <= ?");
<<<<<<< Updated upstream
            params.add(Date.valueOf(toDate));
        }

        int offset = (page - 1) * pageSize;
        if (offset < 0) {
            offset = 0;
        }
        sql.append(" ORDER BY i.import_date DESC LIMIT ?, ?");
        params.add(offset);
        params.add(pageSize);
=======
            params.add(java.sql.Date.valueOf(toDate));
        }

        int offset = (page - 1) * pageSize;
        if (offset < 0) offset = 0;
        sql.append(" ORDER BY i.import_date DESC LIMIT ? OFFSET ?");

        params.add(pageSize);
        params.add(offset);
>>>>>>> Stashed changes

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Import importObj = new Import();
                importObj.setImportId(rs.getInt("import_id"));
                importObj.setProposalId(rs.getInt("proposal_id"));
                importObj.setImportType(rs.getString("import_type"));
                importObj.setExecutorId(rs.getInt("executor_id"));
                importObj.setImportDate(rs.getTimestamp("import_date"));
                importObj.setNote(rs.getString("note"));
<<<<<<< Updated upstream
=======
                importObj.setDeliverySupplierName(rs.getString("delivery_supplier_name"));
                importObj.setDeliverySupplierPhone(rs.getString("delivery_supplier_phone"));
>>>>>>> Stashed changes

                User executorObj = new User();
                executorObj.setUserId(rs.getInt("executor_id"));
                executorObj.setFullName(rs.getString("full_name"));
                importObj.setExecutor(executorObj);

                result.add(importObj);
            }
        }

        return result;
    }

    public int countSearchImports(String proposalType, String executor, String fromDate, String toDate) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM ImportReceipts i "
<<<<<<< Updated upstream
                + "JOIN Users u ON i.executor_id = u.user_id WHERE 1=1"
        );
=======
                + "JOIN Users u ON i.executor_id = u.user_id WHERE 1=1");
>>>>>>> Stashed changes

        List<Object> params = new ArrayList<>();

        if (proposalType != null && !proposalType.isEmpty()) {
            sql.append(" AND i.import_type LIKE ?");
            params.add("%" + proposalType + "%");
        }

        if (executor != null && !executor.isEmpty()) {
            sql.append(" AND u.full_name LIKE ?");
            params.add("%" + executor + "%");
        }

        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(i.import_date) >= ?");
<<<<<<< Updated upstream
            params.add(Date.valueOf(fromDate));
=======
            params.add(java.sql.Date.valueOf(fromDate));
>>>>>>> Stashed changes
        }

        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(i.import_date) <= ?");
<<<<<<< Updated upstream
            params.add(Date.valueOf(toDate));
=======
            params.add(java.sql.Date.valueOf(toDate));
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
}
=======
}
>>>>>>> Stashed changes
