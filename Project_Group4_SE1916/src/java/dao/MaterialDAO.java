package dao;

import Dal.DBContext;
import model.Material;
import model.MaterialBrand;
import model.MaterialCategory;
import model.Supplier;
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
        String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.brand_id, mb.name AS brand_name, mc.category_id, mc.name AS category_name "
                + "FROM Materials m "
                + "JOIN MaterialBrands mb ON m.brand_id = mb.brand_id "
                + "JOIN MaterialCategories mc ON mb.category_id = mc.category_id";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Material material = new Material();
                material.setMaterialId(rs.getInt("material_id"));
                material.setCode(rs.getString("code"));
                material.setName(rs.getString("name"));
                material.setDescription(rs.getString("description"));
                material.setUnit(rs.getString("unit"));
                material.setImageUrl(rs.getString("image_url"));

                MaterialBrand brand = new MaterialBrand();
                brand.setBrandId(rs.getInt("brand_id"));
                brand.setName(rs.getString("brand_name"));

                MaterialCategory category = new MaterialCategory();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("category_name"));
                brand.setCategory(category);

                material.setBrand(brand);
                material.setSuppliers(getSuppliersByMaterialId(material.getMaterialId()));
                materials.add(material);
            }
        }
        return materials;
    }

    public Material getMaterialById(int materialId) throws SQLException {
        Material material = null;
        String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.brand_id, mb.name AS brand_name, mc.category_id, mc.name AS category_name "
                + "FROM Materials m "
                + "JOIN MaterialBrands mb ON m.brand_id = mb.brand_id "
                + "JOIN MaterialCategories mc ON mb.category_id = mc.category_id "
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

                    MaterialBrand brand = new MaterialBrand();
                    brand.setBrandId(rs.getInt("brand_id"));
                    brand.setName(rs.getString("brand_name"));

                    MaterialCategory category = new MaterialCategory();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setName(rs.getString("category_name"));
                    brand.setCategory(category);

                    material.setBrand(brand);
                    material.setSuppliers(getSuppliersByMaterialId(materialId));
                }
            }
        }
        return material;
    }

    public void addMaterial(Material material, List<Integer> supplierIds) throws SQLException {
        String sqlMaterial = "INSERT INTO Materials (code, brand_id, name, description, unit, image_url) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sqlMaterial, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, material.getCode());
            ps.setInt(2, material.getBrand().getBrandId());
            ps.setString(3, material.getName());
            ps.setString(4, material.getDescription());
            ps.setString(5, material.getUnit());
            ps.setString(6, material.getImageUrl());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int materialId = rs.getInt(1);
                    addSupplierMaterials(materialId, supplierIds);
                }
            }
        }
    }

    public void updateMaterial(Material material, List<Integer> supplierIds) throws SQLException {
        String sqlMaterial = "UPDATE Materials SET code = ?, brand_id = ?, name = ?, description = ?, unit = ?, image_url = ? WHERE material_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlMaterial)) {
            ps.setString(1, material.getCode());
            ps.setInt(2, material.getBrand().getBrandId());
            ps.setString(3, material.getName());
            ps.setString(4, material.getDescription());
            ps.setString(5, material.getUnit());
            ps.setString(6, material.getImageUrl());
            ps.setInt(7, material.getMaterialId());
            ps.executeUpdate();

            // Delete existing supplier mappings
            String deleteSuppliers = "DELETE FROM SupplierMaterials WHERE material_id = ?";
            try (PreparedStatement psDelete = conn.prepareStatement(deleteSuppliers)) {
                psDelete.setInt(1, material.getMaterialId());
                psDelete.executeUpdate();
            }

            // Add new supplier mappings
            addSupplierMaterials(material.getMaterialId(), supplierIds);
        }
    }

    public void deleteMaterial(int materialId) throws SQLException {
        String sql = "DELETE FROM Materials WHERE material_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            ps.executeUpdate();
        }
    }

    private List<Supplier> getSuppliersByMaterialId(int materialId) throws SQLException {
        List<Supplier> suppliers = new ArrayList<>();
        String sql = "SELECT s.supplier_id, s.name FROM Suppliers s "
                + "JOIN SupplierMaterials sm ON s.supplier_id = sm.supplier_id "
                + "WHERE sm.material_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Supplier supplier = new Supplier();
                    supplier.setSupplierId(rs.getInt("supplier_id"));
                    supplier.setSupplierName(rs.getString("name"));
                    suppliers.add(supplier);
                }
            }
        }
        return suppliers;
    }

    private void addSupplierMaterials(int materialId, List<Integer> supplierIds) throws SQLException {
        String sql = "INSERT INTO SupplierMaterials (supplier_id, material_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Integer supplierId : supplierIds) {
                ps.setInt(1, supplierId);
                ps.setInt(2, materialId);
                ps.addBatch();
            }
            ps.executeBatch();
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
        String sql = "SELECT material_id, name, unit FROM Materials WHERE name LIKE ? LIMIT 10";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + term + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Material material = new Material();
                    material.setMaterialId(rs.getInt("material_id"));
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
