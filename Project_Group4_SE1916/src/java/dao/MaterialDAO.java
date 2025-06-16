package dao;

import Dal.DBContext;
import model.Material;
import model.MaterialCategory;
import model.ImportDetail;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MaterialDAO {

    private Connection conn;

    public MaterialDAO() {
        this.conn = DBContext.getConnection();
    }

    public List<Material> getAllMaterials() throws SQLException {
        List<Material> materials = new ArrayList<>();
        String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.category_id, mc.name AS category_name "
                + "FROM Materials m "
                + "JOIN MaterialCategories mc ON m.category_id = mc.category_id";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Material material = new Material();
                material.setMaterialId(rs.getInt("material_id"));
                material.setCode(rs.getString("code"));
                material.setName(rs.getString("name"));
                material.setDescription(rs.getString("description"));
                material.setUnit(rs.getString("unit"));
                material.setImageUrl(rs.getString("image_url"));

                MaterialCategory category = new MaterialCategory();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("category_name"));

                material.setCategory(category);
                materials.add(material);
            }
        }
        return materials;
    }

    public Material getMaterialById(int materialId) throws SQLException {
        Material material = null;
        String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.category_id, mc.name AS category_name "
                + "FROM Materials m "
                + "JOIN MaterialCategories mc ON m.category_id = mc.category_id "
                + "WHERE m.material_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    material = new Material();
                    material.setMaterialId(rs.getInt("material_id"));
                    material.setCode(rs.getString("code"));
                    material.setName(rs.getString("name"));
                    material.setDescription(rs.getString("description"));
                    material.setUnit(rs.getString("unit"));
                    material.setImageUrl(rs.getString("image_url"));

                    MaterialCategory category = new MaterialCategory();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setName(rs.getString("category_name"));

                    material.setCategory(category);
                }
            }
        }
        return material;
    }

    public void addMaterial(Material material, List<Integer> supplierIdList) throws SQLException {
        String sqlMaterial = "INSERT INTO Materials (code, category_id, name, description, unit, image_url) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sqlMaterial, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, material.getCode());
            ps.setInt(2, material.getCategory().getCategoryId());
            ps.setString(3, material.getName());
            ps.setString(4, material.getDescription());
            ps.setString(5, material.getUnit());
            ps.setString(6, material.getImageUrl());
            ps.executeUpdate();

            // Lấy material_id vừa tạo
            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int materialId = generatedKeys.getInt(1);

                    // Thêm vào SupplierMaterials
                    if (supplierIdList != null && !supplierIdList.isEmpty()) {
                        String sqlSupplier = "INSERT INTO SupplierMaterials (supplier_id, material_id) VALUES (?, ?)";
                        try (PreparedStatement psSupplier = conn.prepareStatement(sqlSupplier)) {
                            for (Integer supplierId : supplierIdList) {
                                psSupplier.setInt(1, supplierId);
                                psSupplier.setInt(2, materialId);
                                psSupplier.addBatch();
                            }
                            psSupplier.executeBatch();
                        }
                    }
                }
            }
        }
    }

    public void updateMaterial(Material material, List<Integer> supplierIdList) throws SQLException {
        String sqlMaterial = "UPDATE Materials SET code = ?, category_id = ?, name = ?, description = ?, unit = ?, image_url = ? WHERE material_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlMaterial)) {
            ps.setString(1, material.getCode());
            ps.setInt(2, material.getCategory().getCategoryId());
            ps.setString(3, material.getName());
            ps.setString(4, material.getDescription());
            ps.setString(5, material.getUnit());
            ps.setString(6, material.getImageUrl());
            ps.setInt(7, material.getMaterialId());
            ps.executeUpdate();

            // Xóa các mối quan hệ cũ trong SupplierMaterials
            String deleteSql = "DELETE FROM SupplierMaterials WHERE material_id = ?";
            try (PreparedStatement psDelete = conn.prepareStatement(deleteSql)) {
                psDelete.setInt(1, material.getMaterialId());
                psDelete.executeUpdate();
            }

            // Thêm các mối quan hệ mới
            if (supplierIdList != null && !supplierIdList.isEmpty()) {
                String sqlSupplier = "INSERT INTO SupplierMaterials (supplier_id, material_id) VALUES (?, ?)";
                try (PreparedStatement psSupplier = conn.prepareStatement(sqlSupplier)) {
                    for (Integer supplierId : supplierIdList) {
                        psSupplier.setInt(1, supplierId);
                        psSupplier.setInt(2, material.getMaterialId());
                        psSupplier.addBatch();
                    }
                    psSupplier.executeBatch();
                }
            }
        }
    }

    public void deleteMaterial(int materialId) throws SQLException {
        String sql = "DELETE FROM Materials WHERE material_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            ps.executeUpdate();
        }
    }

    public double getInventoryQuantity(int materialId, String condition) throws SQLException {
        String sql = "SELECT quantity_in_stock FROM Inventory WHERE material_id = ? AND material_condition = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            ps.setString(2, condition);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("quantity_in_stock");
                }
            }
        }
        return 0.0;
    }

    public List<Material> searchMaterialsByName(String term) throws SQLException {
        List<Material> materials = new ArrayList<>();
        String sql = "SELECT material_id, code, name, unit FROM Materials WHERE name LIKE ? OR code LIKE ? LIMIT 10";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + term + "%");
            ps.setString(2, "%" + term + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Material material = new Material();
                    material.setMaterialId(rs.getInt("material_id"));
                    material.setCode(rs.getString("code"));
                    material.setName(rs.getString("name"));
                    material.setUnit(rs.getString("unit"));
                    materials.add(material);
                }
            }
        }
        return materials;
    }

    public boolean materialExists(int materialId) throws SQLException {
        String sql = "SELECT 1 FROM Materials WHERE material_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void updateInventoryFromImport(List<ImportDetail> details) throws SQLException {
        String sql = "INSERT INTO Inventory (material_id, material_condition, quantity_in_stock) VALUES (?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE quantity_in_stock = quantity_in_stock + ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (ImportDetail detail : details) {
                ps.setInt(1, detail.getMaterialId());
                ps.setString(2, detail.getMaterialCondition());
                ps.setDouble(3, detail.getQuantity());
                ps.setDouble(4, detail.getQuantity());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
}
