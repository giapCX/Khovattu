//invenDAO

package dao;

import model.Inventory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

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
            sql.append("AND DATE(i.last_updated) >= ? ");
        }
        if (toDate != null) {
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
            sql.append("AND DATE(i.last_updated) >= ? ");
        }
        if (toDate != null) {
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

    public List<Inventory> getAllInventory() throws SQLException {
        return searchInventory(null, null, null, null, null, 1, Integer.MAX_VALUE, null);
    }
}
