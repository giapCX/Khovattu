package dao;

import Dal.DBContext;
import static Dal.DBContext.getConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.ImportDetail;

public class ImportDetailDAO {
    private Connection connection;

    public ImportDetailDAO() {
        this.connection = getConnection();
    }

    public List<ImportDetail> getImportDetailsByImportId(int importId) {
        List<ImportDetail> details = new ArrayList<>();
        String sql = "SELECT id.import_id, id.material_id, id.quantity, id.price_per_unit, " +
                     "id.material_condition, id.supplier_id, id.site_id, " +
                     "m.name AS material_name, m.unit " +
                     "FROM ImportDetails id " +
                     "JOIN Materials m ON id.material_id = m.material_id " +
                     "WHERE id.import_id = ?";
        try (
            PreparedStatement ps = connection.prepareStatement(sql)
        ) {
            ps.setInt(1, importId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ImportDetail detail = new ImportDetail();
                detail.setImportId(rs.getInt("import_id"));
                detail.setMaterialId(rs.getInt("material_id"));
                detail.setQuantity(rs.getDouble("quantity"));
                detail.setPrice(rs.getDouble("price_per_unit"));
                detail.setMaterialCondition(rs.getString("material_condition"));
                detail.setSupplierId(rs.getInt("supplier_id"));
                
                int siteId = rs.getInt("site_id");
                if (!rs.wasNull()) {
                    detail.setSiteId(siteId);
                }

                detail.setMaterialName(rs.getString("material_name"));
                detail.setUnit(rs.getString("unit"));

                details.add(detail);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return details;
    }
    public List<ImportDetail> getDetailsByImportIdWithFilter(int importId, String materialName, String condition) {
    List<ImportDetail> list = new ArrayList<>();

    StringBuilder sql = new StringBuilder(
        "SELECT id.import_id, id.material_id, id.quantity, id.price_per_unit, id.material_condition, " +
        "       i.supplier_id, i.site_id, " +
        "       m.code AS material_code, m.name AS material_name, m.unit " +
        "FROM ImportDetails id " +
        "JOIN Materials m ON id.material_id = m.material_id " +
        "JOIN ImportReceipts i ON id.import_id = i.import_id " +
        "WHERE id.import_id = ? "
    );

    if (materialName != null && !materialName.trim().isEmpty()) {
        sql.append(" AND m.name LIKE ? ");
    }

    if (condition != null && !condition.trim().isEmpty()) {
        sql.append(" AND id.condition = ? ");
    }

    try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
        int paramIndex = 1;
        stm.setInt(paramIndex++, importId);

        if (materialName != null && !materialName.trim().isEmpty()) {
            stm.setString(paramIndex++, "%" + materialName.trim() + "%");
        }

        if (condition != null && !condition.trim().isEmpty()) {
            stm.setString(paramIndex++, condition.trim());
        }

        ResultSet rs = stm.executeQuery();
        while (rs.next()) {
            ImportDetail detail = new ImportDetail();
            detail.setImportId(rs.getInt("import_id"));
            detail.setMaterialId(rs.getInt("material_id"));
            detail.setQuantity(rs.getDouble("quantity"));
            detail.setPrice(rs.getDouble("price_per_unit"));
            detail.setMaterialCondition(rs.getString("material_condition"));
            detail.setSupplierId(rs.getObject("supplier_id") != null ? rs.getInt("supplier_id") : null);
            detail.setSiteId(rs.getObject("site_id") != null ? rs.getInt("site_id") : null);
            detail.setMaterialCode(rs.getString("material_code"));
            detail.setMaterialName(rs.getString("material_name"));
            detail.setUnit(rs.getString("unit"));

            list.add(detail);
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return list;
}

}
