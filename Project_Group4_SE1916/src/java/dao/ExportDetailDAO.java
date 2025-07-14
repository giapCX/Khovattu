//exDetailDAO

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
                ed.site_id,
                cs.site_name, 
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
            LEFT JOIN ConstructionSites cs ON ed.site_id = cs.site_id
            WHERE ed.export_id = ? LIMIT ?, ?
        """;
        return getData(sql, exportId, null, null, page, pageSize);
    }

    // Search by name
    public List<ExportDetail> searchByName(int exportId, String keyword, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT 
                ed.export_detail_id,
                ed.export_id,
                ed.site_id,
                cs.site_name, 
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
            LEFT JOIN ConstructionSites cs ON ed.site_id = cs.site_id
            WHERE ed.export_id = ? 
        """);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND m.name LIKE ? ");
        }
        sql.append("LIMIT ? OFFSET ?");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            ps.setInt(index++, exportId);
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(index++, "%" + keyword.trim() + "%");
            }
            ps.setInt(index++, (page - 1) * pageSize);
            ps.setInt(index++, pageSize);

            ResultSet rs = ps.executeQuery();
            List<ExportDetail> list = new ArrayList<>();
            while (rs.next()) {
                ExportDetail d = new ExportDetail();
                d.setExportDetailId(rs.getInt("export_detail_id"));
                d.setExportId(rs.getInt("export_id"));
                d.setSiteId(rs.getInt("site_id"));
                d.setMaterialId(rs.getInt("material_id"));
                d.setMaterialName(rs.getString("material_name"));
                d.setQuantity(rs.getDouble("quantity"));
                d.setUnit(rs.getString("unit"));
                d.setMaterialCondition(rs.getString("material_condition"));
                d.setReason(rs.getString("reason"));
                d.setMaterialCode(rs.getString("material_code"));
                d.setMaterialCategory(rs.getString("material_category"));
                d.setSiteName(rs.getString("site_name"));
                list.add(d);
            }
            return list;
        }
    }

    // Search by multiple criteria
    public List<ExportDetail> searchByCriteria(int exportId, String materialName, String constructionSite, String reason, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT 
                ed.export_detail_id,
                ed.export_id,
                ed.site_id,
                cs.site_name, 
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
            LEFT JOIN ConstructionSites cs ON ed.site_id = cs.site_id
            WHERE ed.export_id = ? 
        """);

        if (materialName != null && !materialName.trim().isEmpty()) {
            sql.append("AND m.name LIKE ? ");
        }
        if (constructionSite != null && !constructionSite.trim().isEmpty()) {
            sql.append("AND cs.site_name LIKE ? ");
        }
        if (reason != null && !reason.trim().isEmpty()) {
            sql.append("AND ed.reason LIKE ? ");
        }
        sql.append("LIMIT ? OFFSET ?");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            ps.setInt(index++, exportId);
            if (materialName != null && !materialName.trim().isEmpty()) {
                ps.setString(index++, "%" + materialName.trim() + "%");
            }
            if (constructionSite != null && !constructionSite.trim().isEmpty()) {
                ps.setString(index++, "%" + constructionSite.trim() + "%");
            }
            if (reason != null && !reason.trim().isEmpty()) {
                ps.setString(index++, "%" + reason.trim() + "%");
            }
            ps.setInt(index++, pageSize);
            ps.setInt(index++, (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();
            List<ExportDetail> list = new ArrayList<>();
            while (rs.next()) {
                ExportDetail d = new ExportDetail();
                d.setExportDetailId(rs.getInt("export_detail_id"));
                d.setExportId(rs.getInt("export_id"));
                d.setSiteId(rs.getInt("site_id"));
                d.setMaterialId(rs.getInt("material_id"));
                d.setMaterialName(rs.getString("material_name"));
                d.setQuantity(rs.getDouble("quantity"));
                d.setUnit(rs.getString("unit"));
                d.setMaterialCondition(rs.getString("material_condition"));
                d.setReason(rs.getString("reason"));
                d.setMaterialCode(rs.getString("material_code"));
                d.setMaterialCategory(rs.getString("material_category"));
                d.setSiteName(rs.getString("site_name"));
                list.add(d);
            }
            return list;
        }
    }

    // Count search by multiple criteria
    public int countSearchByCriteria(int exportId, String materialName, String constructionSite, String reason) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) 
            FROM ExportDetails ed
            JOIN Materials m ON ed.material_id = m.material_id
            JOIN ExportReceipts er ON ed.export_id = er.export_id
            JOIN MaterialCategories mc ON m.category_id = mc.category_id
            LEFT JOIN ConstructionSites cs ON ed.site_id = cs.site_id
            WHERE ed.export_id = ? 
        """);

        if (materialName != null && !materialName.trim().isEmpty()) {
            sql.append("AND m.name LIKE ? ");
        }
        if (constructionSite != null && !constructionSite.trim().isEmpty()) {
            sql.append("AND cs.site_name LIKE ? ");
        }
        if (reason != null && !reason.trim().isEmpty()) {
            sql.append("AND ed.reason LIKE ? ");
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            ps.setInt(index++, exportId);
            if (materialName != null && !materialName.trim().isEmpty()) {
                ps.setString(index++, "%" + materialName.trim() + "%");
            }
            if (constructionSite != null && !constructionSite.trim().isEmpty()) {
                ps.setString(index++, "%" + constructionSite.trim() + "%");
            }
            if (reason != null && !reason.trim().isEmpty()) {
                ps.setString(index++, "%" + reason.trim() + "%");
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    // Search and sort (if needed, can be extended later)
    public int countSearch(int exportId, String keyword) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) 
            FROM ExportDetails ed
            JOIN Materials m ON ed.material_id = m.material_id
            WHERE ed.export_id = ?
        """);
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND m.name LIKE ? ");
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            stmt.setInt(1, exportId);
            if (keyword != null && !keyword.trim().isEmpty()) {
                stmt.setString(2, "%" + keyword.trim() + "%");
            }
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    // Private reusable method (not used here but kept for consistency)
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
                d.setSiteId(rs.getInt("site_id"));
                d.setMaterialId(rs.getInt("material_id"));
                d.setMaterialName(rs.getString("material_name"));
                d.setQuantity(rs.getDouble("quantity"));
                d.setUnit(rs.getString("unit"));
                d.setMaterialCondition(rs.getString("material_condition"));
                d.setReason(rs.getString("reason"));
                d.setMaterialCode(rs.getString("material_code"));
                d.setMaterialCategory(rs.getString("material_category"));
                d.setSiteName(rs.getString("site_name"));
                list.add(d);
            }
        }
        return list;
    }
}