package dao;

import model.ImportDetailView;
import Dal.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ImportDetailDAO {

    private Connection conn;

    public ImportDetailDAO() {
        conn = DBContext.getConnection();
    }

    // Get default by importId
    public List<ImportDetailView> getByImportId(int importId, int page, int pageSize) {
        String sql = baseSql() + " WHERE id.import_id = ? LIMIT ?, ?";
        return getData(sql, importId, null, null, page, pageSize);
    }

    // Search by name
    public List<ImportDetailView> searchByName(int importId, String keyword, int page, int pageSize) {
        String sql = baseSql() + " WHERE id.import_id = ? AND m.name LIKE ? LIMIT ?, ?";
        return getData(sql, importId, keyword, null, page, pageSize);
    }

    // Sort by price only
    public List<ImportDetailView> sortByPrice(int importId, String sort, int page, int pageSize) {
        String order = sort.equalsIgnoreCase("desc") ? "DESC" : "ASC";
        String sql = baseSql() + " WHERE id.import_id = ? ORDER BY id.price_per_unit " + order + " LIMIT ?, ?";
        return getData(sql, importId, null, order, page, pageSize);
    }

    // Search and sort
    public List<ImportDetailView> searchAndSortByPrice(int importId, String keyword, String sort, int page, int pageSize) {
        String order = sort.equalsIgnoreCase("desc") ? "DESC" : "ASC";
        String sql = baseSql() + " WHERE id.import_id = ? AND m.name LIKE ? ORDER BY id.price_per_unit " + order + " LIMIT ?, ?";
        return getData(sql, importId, keyword, order, page, pageSize);
    }

    // Count
    public int countSearch(int importId, String keyword) {
        String sql = """
            SELECT COUNT(*) FROM ImportDetails id
            JOIN Materials m ON id.material_id = m.material_id
            WHERE id.import_id = ?
        """;
        if (keyword != null && !keyword.isEmpty()) {
            sql += " AND m.name LIKE ?";
        }

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, importId);
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(2, "%" + keyword + "%");
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==== Private reusable ====

    private List<ImportDetailView> getData(String sql, int importId, String keyword, String sort, int page, int pageSize) {
        List<ImportDetailView> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            ps.setInt(index++, importId);
            if (keyword != null) {
                ps.setString(index++, "%" + keyword + "%");
            }
            ps.setInt(index++, (page - 1) * pageSize);
            ps.setInt(index++, pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ImportDetailView d = new ImportDetailView();
                d.setMaterialId(rs.getInt("material_id"));
                d.setMaterialName(rs.getString("material_name"));
                d.setSupplierName(rs.getString("supplier_name"));
                d.setQuantity(rs.getDouble("quantity"));
                d.setPricePerUnit(rs.getDouble("price_per_unit"));
                d.setTotalPrice(rs.getDouble("quantity") * rs.getDouble("price_per_unit"));
                list.add(d);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private String baseSql() {
        return """
            SELECT 
                m.material_id,
                m.name AS material_name,
                s.name AS supplier_name,
                id.quantity,
                id.price_per_unit
            FROM ImportDetails id
            JOIN Materials m ON id.material_id = m.material_id
            JOIN ImportReceipts ir ON id.import_id = ir.import_id
            JOIN Suppliers s ON ir.supplier_id = s.supplier_id
        """;
    }
}
