/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Dal.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;;
import model.ImportDetailView;

public class ImportDetailDAO {

    public List<ImportDetailView> getDetailsByImportId(int importId, String keyword, String sort) throws SQLException {
        List<ImportDetailView> list = new ArrayList<>();
        Connection conn = DBContext.getConnection();
        StringBuilder sql = new StringBuilder(
            "SELECT id.import_detail_id, m.code AS material_code, m.name AS material_name, m.unit, " +
            "id.quantity, id.price_per_unit, " +
            "(id.quantity * id.price_per_unit) AS total_price, " +
            "id.material_condition, s.name AS supplier_name " +
            "FROM ImportDetails id " +
            "JOIN Materials m ON id.material_id = m.material_id " +
            "JOIN ImportReceipts ir ON id.import_id = ir.import_id " +
            "JOIN Suppliers s ON ir.supplier_id = s.supplier_id " +
            "WHERE id.import_id = ?"
        );

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND m.name LIKE ?");
        }

        if ("asc".equals(sort)) {
            sql.append(" ORDER BY id.price_per_unit ASC");
        } else if ("desc".equals(sort)) {
            sql.append(" ORDER BY id.price_per_unit DESC");
        }

        PreparedStatement ps = conn.prepareStatement(sql.toString());
        ps.setInt(1, importId);
        if (keyword != null && !keyword.trim().isEmpty()) {
            ps.setString(2, "%" + keyword + "%");
        }

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            ImportDetailView d = new ImportDetailView();
            d.setImportDetailId(rs.getInt("import_detail_id"));
            d.setMaterialCode(rs.getString("material_code"));
            d.setMaterialName(rs.getString("material_name"));
            d.setUnit(rs.getString("unit"));
            d.setQuantity(rs.getDouble("quantity"));
            d.setPricePerUnit(rs.getDouble("price_per_unit"));
            d.setTotalPrice(rs.getDouble("total_price"));
            d.setMaterialCondition(rs.getString("material_condition"));
            d.setSupplierName(rs.getString("supplier_name"));
            list.add(d);
        }

        return list;
    }

    public int countDetails(int importId, String keyword) throws SQLException {
        Connection conn = DBContext.getConnection();
        String sql = "SELECT COUNT(*) FROM ImportDetails id " +
                     "JOIN Materials m ON id.material_id = m.material_id " +
                     "WHERE id.import_id = ?";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND m.name LIKE ?";
        }

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, importId);
        if (keyword != null && !keyword.trim().isEmpty()) {
            ps.setString(2, "%" + keyword + "%");
        }

        ResultSet rs = ps.executeQuery();
        return rs.next() ? rs.getInt(1) : 0;
    }
}

