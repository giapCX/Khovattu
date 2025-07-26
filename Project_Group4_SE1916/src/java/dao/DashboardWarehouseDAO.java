package dao;

import Dal.DBContext;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
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

        // SQL để lấy tồn kho thực tế hiện tại
        String currentStockSql = "SELECT SUM(quantity_in_stock) FROM Inventory";
        
        // SQL để lấy nhập kho theo tháng
        String importSql = """
            SELECT MONTH(import_date) AS month, SUM(quantity) AS total
            FROM ImportReceipts r
            JOIN ImportDetails d ON r.import_id = d.import_id
            WHERE YEAR(import_date) = ?
            GROUP BY MONTH(import_date)
        """;

        // SQL để lấy xuất kho theo tháng
        String exportSql = """
            SELECT MONTH(export_date) AS month, SUM(quantity) AS total
            FROM ExportReceipts r
            JOIN ExportDetails d ON r.export_id = d.export_id
            WHERE YEAR(export_date) = ?
            GROUP BY MONTH(export_date)
        """;

        // SQL để lấy tồn kho đầu năm (tồn kho thực tế hiện tại - tổng nhập + tổng xuất từ đầu năm)
        String stockAtYearStartSql = """
            SELECT 
                (SELECT COALESCE(SUM(quantity_in_stock), 0) FROM Inventory) -
                (SELECT COALESCE(SUM(quantity), 0) FROM ImportReceipts r 
                 JOIN ImportDetails d ON r.import_id = d.import_id 
                 WHERE YEAR(import_date) = ?) +
                (SELECT COALESCE(SUM(quantity), 0) FROM ExportReceipts r 
                 JOIN ExportDetails d ON r.export_id = d.export_id 
                 WHERE YEAR(export_date) = ?)
        """;

        Map<Integer, BigDecimal> importMap = new HashMap<>();
        Map<Integer, BigDecimal> exportMap = new HashMap<>();
        BigDecimal stockAtYearStart = BigDecimal.ZERO;

        try (Connection conn = DBContext.getConnection()) {
            // Lấy tồn kho đầu năm
            try (PreparedStatement ps = conn.prepareStatement(stockAtYearStartSql)) {
                ps.setInt(1, year);
                ps.setInt(2, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stockAtYearStart = rs.getBigDecimal(1);
                    }
                }
            }

            // Lấy dữ liệu nhập kho theo tháng
            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        importMap.put(rs.getInt("month"), rs.getBigDecimal("total"));
                    }
                }
            }

            // Lấy dữ liệu xuất kho theo tháng
            try (PreparedStatement ps = conn.prepareStatement(exportSql)) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        exportMap.put(rs.getInt("month"), rs.getBigDecimal("total"));
                    }
                }
            }

            // Tính toán tồn kho cho từng tháng
            BigDecimal runningStock = stockAtYearStart;
            for (int month = 1; month <= 12; month++) {
                BigDecimal imported = importMap.getOrDefault(month, BigDecimal.ZERO);
                BigDecimal exported = exportMap.getOrDefault(month, BigDecimal.ZERO);
                
                // Tồn kho cuối tháng = Tồn đầu tháng + Nhập - Xuất
                BigDecimal remaining = runningStock.add(imported).subtract(exported);
                
                result.add(new InventoryTrendDTO(month, imported, exported, remaining));
                
                // Cập nhật tồn kho cho tháng tiếp theo
                runningStock = remaining;
            }
        }

        return result;
    }

    // Thêm method để lấy tồn kho thực tế hiện tại
    public BigDecimal getCurrentTotalStock() throws SQLException {
        String sql = "SELECT SUM(quantity_in_stock) FROM Inventory";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        }
        return BigDecimal.ZERO;
    }

    // Thêm method để lấy tổng nhập xuất trong năm
    public Map<String, BigDecimal> getYearlyImportExport(int year) throws SQLException {
        Map<String, BigDecimal> result = new HashMap<>();
        
        String importSql = """
            SELECT COALESCE(SUM(quantity), 0) AS total
            FROM ImportReceipts r
            JOIN ImportDetails d ON r.import_id = d.import_id
            WHERE YEAR(import_date) = ?
        """;
        
        String exportSql = """
            SELECT COALESCE(SUM(quantity), 0) AS total
            FROM ExportReceipts r
            JOIN ExportDetails d ON r.export_id = d.export_id
            WHERE YEAR(export_date) = ?
        """;

        try (Connection conn = DBContext.getConnection()) {
            // Lấy tổng nhập
            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        result.put("totalImport", rs.getBigDecimal("total"));
                    }
                }
            }

            // Lấy tổng xuất
            try (PreparedStatement ps = conn.prepareStatement(exportSql)) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        result.put("totalExport", rs.getBigDecimal("total"));
                    }
                }
            }
        }

        return result;
    }

    // Thêm method để lấy tổng nhập xuất theo tháng hiện tại
    public Map<String, BigDecimal> getCurrentMonthImportExport() throws SQLException {
        Map<String, BigDecimal> result = new HashMap<>();
        
        String importSql = """
            SELECT COALESCE(SUM(quantity), 0) AS total
            FROM ImportReceipts r
            JOIN ImportDetails d ON r.import_id = d.import_id
            WHERE YEAR(import_date) = YEAR(CURDATE()) 
            AND MONTH(import_date) = MONTH(CURDATE())
        """;
        
        String exportSql = """
            SELECT COALESCE(SUM(quantity), 0) AS total
            FROM ExportReceipts r
            JOIN ExportDetails d ON r.export_id = d.export_id
            WHERE YEAR(export_date) = YEAR(CURDATE()) 
            AND MONTH(export_date) = MONTH(CURDATE())
        """;

        try (Connection conn = DBContext.getConnection()) {
            // Lấy tổng nhập tháng hiện tại
            try (PreparedStatement ps = conn.prepareStatement(importSql)) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        result.put("totalImport", rs.getBigDecimal("total"));
                    }
                }
            }

            // Lấy tổng xuất tháng hiện tại
            try (PreparedStatement ps = conn.prepareStatement(exportSql)) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        result.put("totalExport", rs.getBigDecimal("total"));
                    }
                }
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
