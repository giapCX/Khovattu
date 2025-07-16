package dao;

import Dal.DBContext;
import java.sql.*;
import java.util.*;
import java.math.BigDecimal;
import model.InventoryTrendDTO;

public class DashboardWarehouseDAO {

    public int countTotalMaterials() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Materials WHERE status = 'active'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int countLowStockMaterials(int threshold) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Inventory WHERE quantity_in_stock < ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countAwaitingExecutionRequests() throws SQLException {
        String sql = "SELECT COUNT(*) FROM EmployeeProposals WHERE final_status = 'approved_but_not_executed'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int countTodayTransactions() throws SQLException {
        String sql = """
            SELECT (
                (SELECT COUNT(*) FROM ImportReceipts WHERE import_date = CURDATE()) +
                (SELECT COUNT(*) FROM ExportReceipts WHERE export_date = CURDATE())
            ) AS total;
        """;
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        }
        return 0;
    }

    public List<InventoryTrendDTO> getInventoryTrendByMonth(int year) throws SQLException {
        List<InventoryTrendDTO> result = new ArrayList<>();

        String importSql = """
            SELECT MONTH(import_date) AS month, SUM(quantity) AS total
            FROM ImportReceipts r
            JOIN ImportDetails d ON r.import_id = d.import_id
            WHERE YEAR(import_date) = ?
            GROUP BY MONTH(import_date)
        """;

        String exportSql = """
            SELECT MONTH(export_date) AS month, SUM(quantity) AS total
            FROM ExportReceipts r
            JOIN ExportDetails d ON r.export_id = d.export_id
            WHERE YEAR(export_date) = ?
            GROUP BY MONTH(export_date)
        """;

      

        Map<Integer, BigDecimal> importMap = new HashMap<>();
        Map<Integer, BigDecimal> exportMap = new HashMap<>();

        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        importMap.put(rs.getInt("month"), rs.getBigDecimal("total"));
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(exportSql)) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        exportMap.put(rs.getInt("month"), rs.getBigDecimal("total"));
                    }
                }
            }

            for (int month = 1; month <= 12; month++) {
                BigDecimal imported = importMap.getOrDefault(month, BigDecimal.ZERO);
                BigDecimal exported = exportMap.getOrDefault(month, BigDecimal.ZERO);
                BigDecimal remaining = imported.subtract(exported); // hoặc để null nếu cần dữ liệu thật

                result.add(new InventoryTrendDTO(month, imported, exported, remaining));
            }
        }

        return result;
    }

    public Map<String, Integer> getMaterialDistributionByParentCategory() throws SQLException {
        Map<String, Integer> result = new LinkedHashMap<>();
        String sql = """
            SELECT parent.name AS category_name, COUNT(*) AS total
            FROM Materials m
            JOIN MaterialCategories child ON m.category_id = child.category_id
            JOIN MaterialCategories parent ON child.parent_id = parent.category_id
            GROUP BY parent.category_id, parent.name
            ORDER BY total DESC
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.put(rs.getString("category_name"), rs.getInt("total"));
            }
        }
        return result;
    }
}
