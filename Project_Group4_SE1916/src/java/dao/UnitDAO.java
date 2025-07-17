package dao;

import model.Unit;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UnitDAO {

    private Connection conn;

    public UnitDAO(Connection conn) {
        this.conn = conn;
    }

    public List<Unit> searchUnits(String name, int page, int pageSize) throws SQLException {
        List<Unit> unitList = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT unit_id, name "
                + "FROM Units "
                + "WHERE 1=1 "
        );

        // Add search condition
        if (name != null && !name.trim().isEmpty()) {
            sql.append("AND name LIKE ? ");
        }

        // Add pagination
        sql.append("ORDER BY unit_id ASC ");
        if (pageSize > 0) {
            sql.append("LIMIT ? OFFSET ?");
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;

            // Set parameters
            if (name != null && !name.trim().isEmpty()) {
                ps.setString(index++, "%" + name + "%");
            }
            if (pageSize > 0) {
                ps.setInt(index++, pageSize);
                ps.setInt(index++, (page - 1) * pageSize);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Unit unit = new Unit();
                unit.setUnitId(rs.getInt("unit_id"));
                unit.setName(rs.getString("name"));
                unitList.add(unit);
            }
            System.out.println("Unit records found: " + unitList.size()); // Debugging
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return unitList;
    }

    public int countUnits(String name) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) "
                + "FROM Units "
                + "WHERE 1=1 "
        );

        if (name != null && !name.trim().isEmpty()) {
            sql.append("AND name LIKE ? ");
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;

            if (name != null && !name.trim().isEmpty()) {
                ps.setString(index++, "%" + name + "%");
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("Total unit records: " + count); // Debugging
                return count;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public boolean addUnit(String name) throws SQLException {
        String sql = "INSERT INTO Units (name) VALUES (?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean checkUnitExistsByName(String name) throws SQLException {
        String sql = "SELECT 1 FROM Units WHERE name = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }

    public List<Unit> getAllUnits() throws SQLException {
        return searchUnits(null, 1, Integer.MAX_VALUE);
    }
}
