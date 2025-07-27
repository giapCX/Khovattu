//invenDAO

package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Inventory;

public class InventoryDAO {
    private Connection conn;

    public InventoryDAO(Connection conn) {
        this.conn = conn;
    }

    public List<Inventory> searchInventory(String materialId, String materialName, String condition, Date fromDate, Date toDate, int page, int pageSize, String sortOrder) throws SQLException {
        List<Inventory> inventoryList = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT i.material_id, m.name, i.material_condition, i.quantity_in_stock, DATE(i.last_updated) AS last_updated " +
                "FROM Inventory i " +
                "JOIN Materials m ON i.material_id = m.material_id " +
                "WHERE 1=1 "
        );

        // Add search conditions
        if (materialId != null && !materialId.trim().isEmpty()) {
            sql.append("AND i.material_id = ? ");
        }
        if (materialName != null && !materialName.trim().isEmpty()) {
            sql.append("AND m.name LIKE ? ");
        }
        if (condition != null && !condition.trim().isEmpty()) {
            sql.append("AND i.material_condition LIKE ? ");
        }
        if (fromDate != null) {
            sql.append("AND DATE(i.last_updated) <= ? ");
        }        

        // Add sorting
        if ("ASC".equalsIgnoreCase(sortOrder)) {
            sql.append("ORDER BY i.quantity_in_stock ASC ");
        } else if ("DESC".equalsIgnoreCase(sortOrder)) {
            sql.append("ORDER BY i.quantity_in_stock DESC ");
        } else {
            sql.append("ORDER BY i.last_updated DESC ");
        }

        // Add pagination
        if (pageSize > 0) {
            sql.append("LIMIT ? OFFSET ?");
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;

            // Set parameters
            if (materialId != null && !materialId.trim().isEmpty()) {
                try {
                    ps.setInt(index++, Integer.parseInt(materialId));
                } catch (NumberFormatException e) {
                    return inventoryList; // Return empty list if materialId is not a valid integer
                }
            }
            if (materialName != null && !materialName.trim().isEmpty()) {
                ps.setString(index++, "%" + materialName + "%");
            }
            if (condition != null && !condition.trim().isEmpty()) {
                ps.setString(index++, "%" + condition + "%");
            }
            if (fromDate != null) {
                ps.setDate(index++, fromDate);
            }
            if (toDate != null) {
                ps.setDate(index++, toDate);
            }
            if (pageSize > 0) {
                ps.setInt(index++, pageSize);
                ps.setInt(index++, (page - 1) * pageSize);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Inventory inv = new Inventory();
                inv.setMaterialId(rs.getInt("material_id"));
                inv.setMaterialName(rs.getString("name"));
                inv.setMaterialCondition(rs.getString("material_condition"));
                inv.setQuantityInStock(rs.getDouble("quantity_in_stock"));
                inv.setLastUpdated(rs.getDate("last_updated"));
                inventoryList.add(inv);
            }
            System.out.println("Inventory records found: " + inventoryList.size()); // Debugging
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return inventoryList;
    }

    // Overload: Lọc theo số lượng tồn kho nhỏ hơn ngưỡng
    public List<Inventory> searchInventory(String materialId, String materialName, String condition, Date fromDate, Date toDate, int page, int pageSize, String sortOrder, int quantityThreshold) throws SQLException {
        List<Inventory> inventoryList = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT i.material_id, m.name, i.material_condition, i.quantity_in_stock, DATE(i.last_updated) AS last_updated " +
                "FROM Inventory i " +
                "JOIN Materials m ON i.material_id = m.material_id " +
                "WHERE 1=1 "
        );

        if (materialId != null && !materialId.trim().isEmpty()) {
            sql.append("AND i.material_id = ? ");
        }
        if (materialName != null && !materialName.trim().isEmpty()) {
            sql.append("AND m.name LIKE ? ");
        }
        if (condition != null && !condition.trim().isEmpty()) {
            sql.append("AND i.material_condition LIKE ? ");
        }
        if (fromDate != null) {
            sql.append("AND DATE(i.last_updated) <= ? ");
        }
        if (quantityThreshold > 0) {
            sql.append("AND i.quantity_in_stock < ? ");
        }
        if ("ASC".equalsIgnoreCase(sortOrder)) {
            sql.append("ORDER BY i.quantity_in_stock ASC ");
        } else if ("DESC".equalsIgnoreCase(sortOrder)) {
            sql.append("ORDER BY i.quantity_in_stock DESC ");
        } else {
            sql.append("ORDER BY i.last_updated DESC ");
        }
        if (pageSize > 0) {
            sql.append("LIMIT ? OFFSET ?");
        }
        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (materialId != null && !materialId.trim().isEmpty()) {
                try {
                    ps.setInt(index++, Integer.parseInt(materialId));
                } catch (NumberFormatException e) {
                    return inventoryList;
                }
            }
            if (materialName != null && !materialName.trim().isEmpty()) {
                ps.setString(index++, "%" + materialName + "%");
            }
            if (condition != null && !condition.trim().isEmpty()) {
                ps.setString(index++, "%" + condition + "%");
            }
            if (fromDate != null) {
                ps.setDate(index++, fromDate);
            }
            if (quantityThreshold > 0) {
                ps.setInt(index++, quantityThreshold);
            }
            if (pageSize > 0) {
                ps.setInt(index++, pageSize);
                ps.setInt(index++, (page - 1) * pageSize);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Inventory inv = new Inventory();
                inv.setMaterialId(rs.getInt("material_id"));
                inv.setMaterialName(rs.getString("name"));
                inv.setMaterialCondition(rs.getString("material_condition"));
                inv.setQuantityInStock(rs.getDouble("quantity_in_stock"));
                inv.setLastUpdated(rs.getDate("last_updated"));
                inventoryList.add(inv);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return inventoryList;
    }

    public int countInventory(String materialId, String materialName, String condition, Date fromDate, Date toDate) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) " +
                "FROM Inventory i " +
                "JOIN Materials m ON i.material_id = m.material_id " +
                "WHERE 1=1 "
        );

        if (materialId != null && !materialId.trim().isEmpty()) {
            sql.append("AND i.material_id = ? ");
        }
        if (materialName != null && !materialName.trim().isEmpty()) {
            sql.append("AND m.name LIKE ? ");
        }
        if (condition != null && !condition.trim().isEmpty()) {
            sql.append("AND i.material_condition LIKE ? ");
        }
        if (fromDate != null) {
            sql.append("AND DATE(i.last_updated) <= ? ");
        }       

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;

            if (materialId != null && !materialId.trim().isEmpty()) {
                try {
                    ps.setInt(index++, Integer.parseInt(materialId));
                } catch (NumberFormatException e) {
                    return 0; // Return 0 if materialId is not a valid integer
                }
            }
            if (materialName != null && !materialName.trim().isEmpty()) {
                ps.setString(index++, "%" + materialName + "%");
            }
            if (condition != null && !condition.trim().isEmpty()) {
                ps.setString(index++, "%" + condition + "%");
            }
            if (fromDate != null) {
                ps.setDate(index++, fromDate);
            }
            if (toDate != null) {
                ps.setDate(index++, toDate);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("Total inventory records: " + count); // Debugging
                return count;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    // Overload: Đếm số lượng bản ghi với filter số lượng tồn kho
    public int countInventory(String materialId, String materialName, String condition, Date fromDate, Date toDate, int quantityThreshold) throws SQLException {
        int count = 0;
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Inventory i JOIN Materials m ON i.material_id = m.material_id WHERE 1=1 "
        );
        if (materialId != null && !materialId.trim().isEmpty()) {
            sql.append("AND i.material_id = ? ");
        }
        if (materialName != null && !materialName.trim().isEmpty()) {
            sql.append("AND m.name LIKE ? ");
        }
        if (condition != null && !condition.trim().isEmpty()) {
            sql.append("AND i.material_condition LIKE ? ");
        }
        if (fromDate != null) {
            sql.append("AND DATE(i.last_updated) <= ? ");
        }
        if (quantityThreshold > 0) {
            sql.append("AND i.quantity_in_stock < ? ");
        }
        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (materialId != null && !materialId.trim().isEmpty()) {
                try {
                    ps.setInt(index++, Integer.parseInt(materialId));
                } catch (NumberFormatException e) {
                    return 0;
                }
            }
            if (materialName != null && !materialName.trim().isEmpty()) {
                ps.setString(index++, "%" + materialName + "%");
            }
            if (condition != null && !condition.trim().isEmpty()) {
                ps.setString(index++, "%" + condition + "%");
            }
            if (fromDate != null) {
                ps.setDate(index++, fromDate);
            }
            if (quantityThreshold > 0) {
                ps.setInt(index++, quantityThreshold);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }
    public double getReservedQuantity(int materialId) throws SQLException {
    String sql = """
        SELECT SUM(pd.quantity)
        FROM ProposalDetails pd
        JOIN EmployeeProposals ep ON pd.proposal_id = ep.proposal_id
        WHERE pd.material_id = ?
          AND ep.final_status = 'approved'
          AND NOT EXISTS (
              SELECT 1 FROM ExportReceipts er WHERE er.proposal_id = ep.proposal_id
          )
    """;
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, materialId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            double reserved = rs.getDouble(1);
            return rs.wasNull() ? 0.0 : reserved;
        }
        return 0.0;
    }
}

public double getReservedQuantityExcludingProposal(int materialId, int excludeProposalId) throws SQLException {
        String sql = """
            SELECT SUM(pd.quantity)
            FROM ProposalDetails pd
            JOIN EmployeeProposals ep ON pd.proposal_id = ep.proposal_id
            LEFT JOIN ExportReceipts er ON er.proposal_id = ep.proposal_id
            WHERE pd.material_id = ? 
              AND ep.proposal_id != ?
              AND ep.final_status IN ('approved_by_admin', 'approved_but_not_executed')
              AND er.proposal_id IS NULL
        """;
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, materialId);
            stmt.setInt(2, excludeProposalId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next() && !rs.wasNull()) {
                    return rs.getDouble(1);
                }
                return 0.0;
            }
        }
    }

    public double getCurrentStock(int materialId, String materialCondition) throws SQLException {
        String sql = "SELECT quantity_in_stock FROM Inventory WHERE material_id = ? AND material_condition = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, materialId);
            stmt.setString(2, materialCondition);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next() && !rs.wasNull()) {
                    return rs.getDouble(1);
                }
                return 0.0;
            }
        }
    }
    public List<Inventory> getAllInventory() throws SQLException {
        return searchInventory(null, null, null, null, null, 1, Integer.MAX_VALUE, null);
    }
}
