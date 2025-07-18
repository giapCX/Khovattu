package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import Dal.DBContext;
import model.Import;
import model.ImportDetail;
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
        String insertImportSQL = "INSERT INTO ImportReceipts(proposal_id, import_type, responsible_id, executor_id, note, import_date, delivery_supplier_name, delivery_supplier_phone) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        conn.setAutoCommit(false);

        try (PreparedStatement ps = conn.prepareStatement(insertImportSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, importOb.getProposalId());
            ps.setString(2, importOb.getImportType());
            if (importOb.getResponsibleId() != null) {
                ps.setInt(3, importOb.getResponsibleId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            if (importOb.getExecutorId() != null) {
                ps.setInt(4, importOb.getExecutorId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
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
        String insertDetailSQL = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition, supplier_id, site_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(insertDetailSQL)) {
            for (ImportDetail detail : details) {
                ps.setInt(1, importId);
                ps.setInt(2, detail.getMaterialId());
                ps.setDouble(3, detail.getQuantity());
                if (detail.getPrice() != null) {
                    ps.setDouble(4, detail.getPrice());
                } else {
                    ps.setNull(4, Types.DOUBLE);
                }
                ps.setString(5, detail.getMaterialCondition());
                if (detail.getSupplierId() != null) {
                    ps.setInt(6, detail.getSupplierId());
                } else {
                    ps.setNull(6, Types.INTEGER);
                }
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
        String sql = "UPDATE EmployeeProposals SET final_status = ? WHERE proposal_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "executed");
            ps.setInt(2, proposalId);
            ps.executeUpdate();
        }
    }

    public List<Import> searchImportsWithPagination(String proposalType, String executor, String fromDate, String toDate, int page, int pageSize) throws SQLException {
        List<Import> result = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT i.import_id, i.proposal_id, i.import_type, i.executor_id, i.import_date, i.note, u.full_name " +
            "FROM ImportReceipts i " +
            "JOIN Users u ON i.executor_id = u.user_id " +
            "WHERE 1=1"
        );

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
            params.add(Date.valueOf(fromDate));
        }

        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(i.import_date) <= ?");
            params.add(Date.valueOf(toDate));
        }
        int offset = (page - 1) * pageSize;
        if (offset < 0) offset = 0;
        sql.append(" ORDER BY i.import_date DESC LIMIT ?, ?");

        params.add(offset);
        params.add(pageSize);

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
            "SELECT COUNT(*) FROM ImportReceipts i " +
            "JOIN Users u ON i.executor_id = u.user_id WHERE 1=1"
        );

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
            params.add(Date.valueOf(fromDate));
        }

        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(i.import_date) <= ?");
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