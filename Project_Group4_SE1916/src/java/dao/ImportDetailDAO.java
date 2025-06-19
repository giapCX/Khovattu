package dao;

import Dal.DBContext;
import model.ImportDetailView;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ImportDetailDAO {

    // Tìm kiếm theo importId và tên vật tư
    public List<ImportDetailView> getImportDetailsBySearch(int importId, String keyword) {
        List<ImportDetailView> list = new ArrayList<>();
        String sql = "SELECT d.material_id, m.material_code, m.material_name, m.unit, " +
                "d.quantity, d.price_per_unit, d.material_condition " +
                "FROM import_details d JOIN materials m ON d.material_id = m.material_id " +
                "WHERE d.import_id = ? AND m.material_name LIKE ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, importId);
            ps.setString(2, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ImportDetailView d = extractFromResultSet(rs);
                list.add(d);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // Sắp xếp theo tiêu chí
    public List<ImportDetailView> getImportDetailsBySort(int importId, String sortField, int page, int pageSize) {
        List<ImportDetailView> list = new ArrayList<>();
        String orderBy;

        switch (sortField) {
            case "name_asc":
                orderBy = "m.material_name ASC";
                break;
            case "name_desc":
                orderBy = "m.material_name DESC";
                break;
            case "price_asc":
                orderBy = "d.price_per_unit ASC";
                break;
            case "price_desc":
                orderBy = "d.price_per_unit DESC";
                break;
            default:
                orderBy = "m.material_name ASC";
        }

        String sql = "SELECT d.material_id, m.material_code, m.material_name, m.unit, " +
                "d.quantity, d.price_per_unit, d.material_condition " +
                "FROM import_details d JOIN materials m ON d.material_id = m.material_id " +
                "WHERE d.import_id = ? ORDER BY " + orderBy + " LIMIT ? OFFSET ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, importId);
            ps.setInt(2, pageSize);
            ps.setInt(3, (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ImportDetailView d = extractFromResultSet(rs);
                list.add(d);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // Kết hợp tìm kiếm + sắp xếp + phân trang
    public List<ImportDetailView> getImportDetails(int importId, String keyword, String sortField, int page, int pageSize) {
        List<ImportDetailView> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT d.material_id, m.material_code, m.material_name, m.unit, " +
                        "d.quantity, d.price_per_unit, d.material_condition " +
                        "FROM import_details d JOIN materials m ON d.material_id = m.material_id " +
                        "WHERE d.import_id = ? "
        );

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND m.material_name LIKE ? ");
        }

        switch (sortField) {
            case "name_asc":
                sql.append("ORDER BY m.material_name ASC ");
                break;
            case "name_desc":
                sql.append("ORDER BY m.material_name DESC ");
                break;
            case "price_asc":
                sql.append("ORDER BY d.price_per_unit ASC ");
                break;
            case "price_desc":
                sql.append("ORDER BY d.price_per_unit DESC ");
                break;
            default:
                sql.append("ORDER BY m.material_name ASC ");
        }

        sql.append("LIMIT ? OFFSET ?");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            ps.setInt(idx++, importId);

            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword + "%");
            }

            ps.setInt(idx++, pageSize);
            ps.setInt(idx, (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ImportDetailView d = extractFromResultSet(rs);
                list.add(d);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // Đếm số dòng để phân trang
    public int countImportDetails(int importId, String keyword) {
        int count = 0;
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM import_details d JOIN materials m ON d.material_id = m.material_id " +
                        "WHERE d.import_id = ? "
        );

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND m.material_name LIKE ?");
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setInt(1, importId);
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(2, "%" + keyword + "%");
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }
    public List<ImportDetailView> getDetailsByImportId(int importId, String search, String sort, int page, int pageSize) {
    return getImportDetails(importId, search, sort, page, pageSize);
}
    public int countSearchByImportId(int importId, String search) {
    return countImportDetails(importId, search);
}
    private ImportDetailView extractFromResultSet(ResultSet rs) throws SQLException {
        ImportDetailView d = new ImportDetailView();
        d.setMaterialId(rs.getInt("material_id"));
        d.setMaterialCode(rs.getString("material_code"));
        d.setMaterialName(rs.getString("material_name"));
        d.setUnit(rs.getString("unit"));
        d.setQuantity(rs.getInt("quantity"));
        d.setPricePerUnit(rs.getDouble("price_per_unit"));
        d.setMaterialCondition(rs.getString("material_condition"));
        return d;
    }
}
