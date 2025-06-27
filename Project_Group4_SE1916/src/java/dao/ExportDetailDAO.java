//DetailDAO
package dao;

import model.ExportDetail;
import Dal.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ExportDetailDAO {

    private Connection conn;

    public ExportDetailDAO() {
        this.conn = DBContext.getConnection();
    }

    public ExportDetailDAO(Connection conn) {
        this.conn = conn;
    }

    // Get default by exportId
    public List<ExportDetail> getByExportId(int exportId, int page, int pageSize) throws SQLException {
        String sql = """
            SELECT 
                ed.export_detail_id,
                ed.export_id,
                m.material_id,
                m.name AS material_name,
                ed.quantity,
                m.unit,
                ed.material_condition,
                ed.reason,
                m.code AS material_code,
                mc.name AS material_category
            FROM ExportDetails ed
            JOIN Materials m ON ed.material_id = m.material_id
            JOIN ExportReceipts er ON ed.export_id = er.export_id
            JOIN MaterialCategories mc ON m.category_id = mc.category_id
            WHERE ed.export_id = ? LIMIT ?, ?
        """;
        return getData(sql, exportId, null, null, page, pageSize);
    }

    // Search by name
    public List<ExportDetail> searchByName(int exportId, String keyword, int page, int pageSize) throws SQLException {
        String sql = """
            SELECT 
                ed.export_detail_id,
                ed.export_id,
                m.material_id,
                m.name AS material_name,
                ed.quantity,
                m.unit,
                ed.material_condition,
                ed.reason,
                m.code AS material_code,
                mc.name AS material_category
            FROM ExportDetails ed
            JOIN Materials m ON ed.material_id = m.material_id
            JOIN ExportReceipts er ON ed.export_id = er.export_id
            JOIN MaterialCategories mc ON m.category_id = mc.category_id
            WHERE ed.export_id = ? AND m.name LIKE ? LIMIT ?, ?
        """;
        return getData(sql, exportId, keyword, null, page, pageSize);
    }

    // Sort by quantity only
    public List<ExportDetail> sortByQuantity(int exportId, String sort, int page, int pageSize) throws SQLException {
        String order = sort.equalsIgnoreCase("desc") ? "DESC" : "ASC";
        String sql = """
            SELECT 
                ed.export_detail_id,
                ed.export_id,
                m.material_id,
                m.name AS material_name,
                ed.quantity,
                m.unit,
                ed.material_condition,
                ed.reason,
                m.code AS material_code,
                mc.name AS material_category
            FROM ExportDetails ed
            JOIN Materials m ON ed.material_id = m.material_id
            JOIN ExportReceipts er ON ed.export_id = er.export_id
            JOIN MaterialCategories mc ON m.category_id = mc.category_id
            WHERE ed.export_id = ? ORDER BY ed.quantity """ + order + " LIMIT ?, ?";
        return getData(sql, exportId, null, order, page, pageSize);
    }

    // Search and sort
    public List<ExportDetail> searchAndSortByQuantity(int exportId, String keyword, String sort, int page, int pageSize) throws SQLException {
        String order = sort.equalsIgnoreCase("desc") ? "DESC" : "ASC";
        String sql = """
            SELECT 
                ed.export_detail_id,
                ed.export_id,
                m.material_id,
                m.name AS material_name,
                ed.quantity,
                m.unit,
                ed.material_condition,
                ed.reason,
                m.code AS material_code,
                mc.name AS material_category
            FROM ExportDetails ed
            JOIN Materials m ON ed.material_id = m.material_id
            JOIN ExportReceipts er ON ed.export_id = er.export_id
            JOIN MaterialCategories mc ON m.category_id = mc.category_id
            WHERE ed.export_id = ? AND m.name LIKE ? ORDER BY ed.quantity """ + order + " LIMIT ?, ?";
        return getData(sql, exportId, keyword, order, page, pageSize);
    }

    // Count
    public int countSearch(int exportId, String keyword) throws SQLException {
        String sql = """
            SELECT COUNT(*) FROM ExportDetails ed
            JOIN Materials m ON ed.material_id = m.material_id
            WHERE ed.export_id = ?
        """;
        if (keyword != null && !keyword.isEmpty()) {
            sql += " AND m.name LIKE ?";
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, exportId);
            if (keyword != null && !keyword.isEmpty()) {
                stmt.setString(2, "%" + keyword + "%");
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    // ==== Private reusable ====

    private List<ExportDetail> getData(String sql, int exportId, String keyword, String sort, int page, int pageSize) throws SQLException {
        List<ExportDetail> list = new ArrayList<>();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            int index = 1;
            stmt.setInt(index++, exportId);
            if (keyword != null && !keyword.isEmpty()) {
                stmt.setString(index++, "%" + keyword + "%");
            }
            stmt.setInt(index++, (page - 1) * pageSize);
            stmt.setInt(index++, pageSize);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                ExportDetail d = new ExportDetail();
                d.setExportDetailId(rs.getInt("export_detail_id"));
                d.setExportId(rs.getInt("export_id"));
                d.setMaterialId(rs.getInt("material_id"));
                d.setMaterialName(rs.getString("material_name"));
                d.setQuantity(rs.getDouble("quantity"));
                d.setUnit(rs.getString("unit"));
                d.setMaterialCondition(rs.getString("material_condition"));
                d.setReason(rs.getString("reason"));
                d.setMaterialCode(rs.getString("material_code"));
                d.setMaterialCategory(rs.getString("material_category"));
                list.add(d);
            }
        }
        return list;
    }
}