package dao;

import Dal.DBContext;
import model.Material;
import model.MaterialCategory;
import model.ImportDetail;
import model.Supplier;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;

public class MaterialDAO {
    private static final Logger LOGGER = Logger.getLogger(MaterialDAO.class.getName());
    private Connection conn;

    public MaterialDAO() {
        try {
            this.conn = DBContext.getConnection();
            LOGGER.info("Database connection established successfully");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to establish database connection: ", e);
            throw new RuntimeException("Database connection failed", e);
        }
    }

    public List<Material> getAllMaterials() throws SQLException {
        List<Material> materials = new ArrayList<>();
        String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.category_id, mc.name AS category_name, "
                + "mc.parent_id, mc2.name AS parent_category_name, GROUP_CONCAT(s.name SEPARATOR ', ') AS supplier_names "
                + "FROM Materials m "
                + "JOIN MaterialCategories mc ON m.category_id = mc.category_id "
                + "LEFT JOIN MaterialCategories mc2 ON mc.parent_id = mc2.category_id "
                + "LEFT JOIN SupplierMaterials sm ON m.material_id = sm.material_id "
                + "LEFT JOIN Suppliers s ON sm.supplier_id = s.supplier_id "
                + "GROUP BY m.material_id";
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
                category.setParentCategoryName(rs.getString("parent_category_name"));
                category.setParentId(rs.getInt("parent_id"));
                material.setCategory(category);

                String supplierNames = rs.getString("supplier_names");
                List<Supplier> suppliers = new ArrayList<>();
                if (supplierNames != null && !supplierNames.isEmpty()) {
                    String[] supplierArray = supplierNames.split(",\\s*");
                    for (String supplierName : supplierArray) {
                        Supplier supplier = new Supplier();
                        supplier.setSupplierName(supplierName.trim());
                        suppliers.add(supplier);
                    }
                }
                material.setSuppliers(suppliers);

                materials.add(material);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAllMaterials: ", e);
            throw e;
        }
        return materials;
    }

    public List<Material> getMaterialsByParentCategory(int parentCategoryId) throws SQLException {
        List<Material> materials = new ArrayList<>();
        String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.category_id, mc.name AS category_name, "
                + "mc.parent_id, mc2.name AS parent_category_name, GROUP_CONCAT(s.name SEPARATOR ', ') AS supplier_names "
                + "FROM Materials m "
                + "JOIN MaterialCategories mc ON m.category_id = mc.category_id "
                + "LEFT JOIN MaterialCategories mc2 ON mc.parent_id = mc2.category_id "
                + "LEFT JOIN SupplierMaterials sm ON m.material_id = sm.material_id "
                + "LEFT JOIN Suppliers s ON sm.supplier_id = s.supplier_id "
                + "WHERE mc.parent_id = ? "
                + "GROUP BY m.material_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentCategoryId);
            try (ResultSet rs = ps.executeQuery()) {
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
                    category.setParentCategoryName(rs.getString("parent_category_name"));
                    material.setCategory(category);

                    String supplierNames = rs.getString("supplier_names");
                    List<Supplier> suppliers = new ArrayList<>();
                    if (supplierNames != null && !supplierNames.isEmpty()) {
                        String[] supplierArray = supplierNames.split(",\\s*");
                        for (String supplierName : supplierArray) {
                            Supplier supplier = new Supplier();
                            supplier.setSupplierName(supplierName.trim());
                            suppliers.add(supplier);
                        }
                    }
                    material.setSuppliers(suppliers);

                    materials.add(material);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getMaterialsByParentCategory: ", e);
            throw e;
        }
        return materials;
    }

    public Material getMaterialById(int materialId) throws SQLException {
        Material material = null;
        String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.category_id, mc.name AS category_name "
                + "FROM Materials m "
                + "JOIN MaterialCategories mc ON m.category_id = mc.category_id "
                + "WHERE m.material_id = ? AND m.status = 'active'";
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

    public int getMaterialIdByCode(String code) throws SQLException {
        String sql = "SELECT material_id FROM Materials WHERE code = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, code);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("material_id");
                }
            }
        }
        return -1;
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

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int materialId = generatedKeys.getInt(1);

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

    public void updateMaterial(Material material) throws SQLException {
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

    public List<Material> searchMaterials(String term) throws SQLException {
        List<Material> materials = new ArrayList<>();
        String sql = "SELECT m.material_id, m.name, m.material_code, m.unit, " +
                     "s.supplier_id, s.name AS supplier_name " +
                     "FROM Materials m " +
                     "LEFT JOIN MaterialSuppliers ms ON m.material_id = ms.material_id " +
                     "LEFT JOIN Suppliers s ON ms.supplier_id = s.supplier_id " +
                     "WHERE (LOWER(m.name) LIKE ? OR LOWER(m.material_code) LIKE ?) AND m.status = 'active'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + term.toLowerCase() + "%");
            ps.setString(2, "%" + term.toLowerCase() + "%");
            LOGGER.info("Executing searchMaterials SQL: " + sql + " with term: " + term);
            try (ResultSet rs = ps.executeQuery()) {
                Material currentMaterial = null;
                int materialCount = 0;
                while (rs.next()) {
                    int materialId = rs.getInt("material_id");
                    if (currentMaterial == null || currentMaterial.getMaterialId() != materialId) {
                        currentMaterial = new Material();
                        currentMaterial.setMaterialId(materialId);
                        currentMaterial.setName(rs.getString("name"));
                        currentMaterial.setCode(rs.getString("material_code"));
                        currentMaterial.setUnit(rs.getString("unit"));
                        List<Supplier> suppliers = new ArrayList<>();
                        currentMaterial.setSuppliers(suppliers);
                        materials.add(currentMaterial);
                        materialCount++;
                        LOGGER.fine("Found material: " + currentMaterial.getName() + " (ID: " + materialId + ")");
                    }
                    int supplierId = rs.getInt("supplier_id");
                    if (!rs.wasNull()) {
                        Supplier supplier = new Supplier();
                        supplier.setSupplierId(supplierId);
                        supplier.setSupplierName(rs.getString("supplier_name"));
                        currentMaterial.getSuppliers().add(supplier);
                    }
                }
                LOGGER.info("searchMaterials found " + materialCount + " materials for term: " + term);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in searchMaterials: ", e);
            throw e;
        }
        return materials;
    }

    public List<Material> getMaterialsBySite(int siteId) throws SQLException {
        List<Material> materials = new ArrayList<>();
        String sql = "SELECT m.material_id, m.name, m.material_code, m.unit, sm.quantity, sm.material_condition " +
                     "FROM SiteMaterials sm " +
                     "JOIN Materials m ON sm.material_id = m.material_id " +
                     "WHERE sm.site_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, siteId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Material material = new Material();
                material.setMaterialId(rs.getInt("material_id"));
                material.setName(rs.getString("name"));
                material.setCode(rs.getString("material_code"));
                material.setUnit(rs.getString("unit"));
                material.setQuantity(rs.getDouble("quantity"));
                material.setCondition(rs.getString("material_condition"));
                materials.add(material);
            }
        }
        return materials;
    }

    public List<Material> getAllMaterials(int page, int itemsPerPage) throws SQLException {
        List<Material> materials = new ArrayList<>();
        String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.category_id, mc.name AS category_name, " +
                     "mc.parent_id, mc2.name AS parent_category_name, mc.status AS child_category_status, mc2.status AS parent_category_status, " +
                     "GROUP_CONCAT(s.name SEPARATOR ', ') AS supplier_names " +
                     "FROM Materials m " +
                     "JOIN MaterialCategories mc ON m.category_id = mc.category_id " +
                     "LEFT JOIN MaterialCategories mc2 ON mc.parent_id = mc2.category_id " +
                     "LEFT JOIN SupplierMaterials sm ON m.material_id = sm.material_id " +
                     "LEFT JOIN Suppliers s ON sm.supplier_id = s.supplier_id " +
                     "WHERE m.status = 'active' " +
                     "GROUP BY m.material_id " +
                     "LIMIT ? OFFSET ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemsPerPage);
            ps.setInt(2, (page - 1) * itemsPerPage);
            try (ResultSet rs = ps.executeQuery()) {
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
                    category.setParentCategoryName(rs.getString("parent_category_name"));
                    category.setParentId(rs.getInt("parent_id"));
                    category.setStatus(rs.getString("parent_category_status"));
                    category.setChildCategoryStatus(rs.getString("child_category_status"));
                    material.setCategory(category);

                    String supplierNames = rs.getString("supplier_names");
                    List<Supplier> suppliers = new ArrayList<>();
                    if (supplierNames != null && !supplierNames.isEmpty()) {
                        String[] supplierArray = supplierNames.split(",\\s*");
                        for (String supplierName : supplierArray) {
                            Supplier supplier = new Supplier();
                            supplier.setSupplierName(supplierName.trim());
                            suppliers.add(supplier);
                        }
                    }
                    material.setSuppliers(suppliers);

                    materials.add(material);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAllMaterials: ", e);
            throw e;
        }
        return materials;
    }

   public List<Material> getMaterialsByParentCategory(int parentCategoryId, int page, int itemsPerPage) throws SQLException {
    List<Material> materials = new ArrayList<>();
    String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.category_id, mc.name AS category_name, " +
                 "mc.parent_id, mc2.name AS parent_category_name, mc.status AS child_category_status, mc2.status AS parent_category_status, " +
                 "GROUP_CONCAT(s.name SEPARATOR ', ') AS supplier_names " +
                 "FROM Materials m " +
                 "JOIN MaterialCategories mc ON m.category_id = mc.category_id " +
                 "LEFT JOIN MaterialCategories mc2 ON mc.parent_id = mc2.category_id " +
                 "LEFT JOIN SupplierMaterials sm ON m.material_id = sm.material_id " +
                 "LEFT JOIN Suppliers s ON sm.supplier_id = s.supplier_id " +
                 "WHERE mc.parent_id = ? AND m.status = 'active' " +  // Thêm điều kiện này
                 "GROUP BY m.material_id " +
                 "LIMIT ? OFFSET ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentCategoryId);
            ps.setInt(2, itemsPerPage);
            ps.setInt(3, (page - 1) * itemsPerPage);
            try (ResultSet rs = ps.executeQuery()) {
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
                    category.setParentCategoryName(rs.getString("parent_category_name"));
                    category.setParentId(rs.getInt("parent_id"));
                    category.setStatus(rs.getString("parent_category_status"));
                    category.setChildCategoryStatus(rs.getString("child_category_status"));
                    material.setCategory(category);

                    String supplierNames = rs.getString("supplier_names");
                    List<Supplier> suppliers = new ArrayList<>();
                    if (supplierNames != null && !supplierNames.isEmpty()) {
                        String[] supplierArray = supplierNames.split(",\\s*");
                        for (String supplierName : supplierArray) {
                            Supplier supplier = new Supplier();
                            supplier.setSupplierName(supplierName.trim());
                            suppliers.add(supplier);
                        }
                    }
                    material.setSuppliers(suppliers);

                    materials.add(material);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getMaterialsByParentCategory: ", e);
            throw e;
        }
        return materials;
    }

    public int getTotalMaterials() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Materials WHERE status = 'active'";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getTotalMaterialsByParentCategory(int parentCategoryId) throws SQLException {
String sql = "SELECT COUNT(*) FROM Materials m JOIN MaterialCategories mc ON m.category_id = mc.category_id WHERE mc.parent_id = ? AND m.status = 'active'";        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentCategoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

  public List<Material> getMaterialsByChildCategory(int childCategoryId, int page, int itemsPerPage) throws SQLException {
    List<Material> materials = new ArrayList<>();
    String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.category_id, mc.name AS category_name, " +
                 "mc.parent_id, mc2.name AS parent_category_name, mc.status AS child_category_status, mc2.status AS parent_category_status, " +
                 "GROUP_CONCAT(s.name SEPARATOR ', ') AS supplier_names " +
                 "FROM Materials m " +
                 "JOIN MaterialCategories mc ON m.category_id = mc.category_id " +
                 "LEFT JOIN MaterialCategories mc2 ON mc.parent_id = mc2.category_id " +
                 "LEFT JOIN SupplierMaterials sm ON m.material_id = sm.material_id " +
                 "LEFT JOIN Suppliers s ON sm.supplier_id = s.supplier_id " +
                 "WHERE m.category_id = ? AND m.status = 'active' " +  // Thêm điều kiện này
                 "GROUP BY m.material_id " +
                 "LIMIT ? OFFSET ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, childCategoryId);
            ps.setInt(2, itemsPerPage);
            ps.setInt(3, (page - 1) * itemsPerPage);
            try (ResultSet rs = ps.executeQuery()) {
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
                    category.setParentCategoryName(rs.getString("parent_category_name"));
                    category.setParentId(rs.getInt("parent_id"));
                    category.setStatus(rs.getString("parent_category_status"));
                    category.setChildCategoryStatus(rs.getString("child_category_status"));
                    material.setCategory(category);

                    String supplierNames = rs.getString("supplier_names");
                    List<Supplier> suppliers = new ArrayList<>();
                    if (supplierNames != null && !supplierNames.isEmpty()) {
                        String[] supplierArray = supplierNames.split(",\\s*");
                        for (String supplierName : supplierArray) {
                            Supplier supplier = new Supplier();
                            supplier.setSupplierName(supplierName.trim());
                            suppliers.add(supplier);
                        }
                    }
                    material.setSuppliers(suppliers);

                    materials.add(material);
                }
            }
        }
        return materials;
    }

    public int getTotalMaterialsByChildCategory(int childCategoryId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Materials WHERE category_id = ? AND status = 'active'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, childCategoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<Material> searchMaterialsByCode(String code, int page, int itemsPerPage) throws SQLException {
        List<Material> materials = new ArrayList<>();
        String sql = "SELECT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, m.category_id, mc.name AS category_name, " +
                     "mc.parent_id, mc2.name AS parent_category_name, mc.status AS child_category_status, mc2.status AS parent_category_status, " +
                     "GROUP_CONCAT(s.name SEPARATOR ', ') AS supplier_names " +
                     "FROM Materials m " +
                     "JOIN MaterialCategories mc ON m.category_id = mc.category_id " +
                     "LEFT JOIN MaterialCategories mc2 ON mc.parent_id = mc2.category_id " +
                     "LEFT JOIN SupplierMaterials sm ON m.material_id = sm.material_id " +
                     "LEFT JOIN Suppliers s ON sm.supplier_id = s.supplier_id " +
                     "WHERE m.code LIKE ? AND m.status = 'active' " +
                     "GROUP BY m.material_id " +
                     "LIMIT ? OFFSET ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + code + "%");
            ps.setInt(2, itemsPerPage);
            ps.setInt(3, (page - 1) * itemsPerPage);
            try (ResultSet rs = ps.executeQuery()) {
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
                    category.setParentCategoryName(rs.getString("parent_category_name"));
                    category.setParentId(rs.getInt("parent_id"));
                    category.setStatus(rs.getString("parent_category_status"));
                    category.setChildCategoryStatus(rs.getString("child_category_status"));
                    material.setCategory(category);

                    String supplierNames = rs.getString("supplier_names");
                    List<Supplier> suppliers = new ArrayList<>();
                    if (supplierNames != null && !supplierNames.isEmpty()) {
                        String[] supplierArray = supplierNames.split(",\\s*");
                        for (String supplierName : supplierArray) {
                            Supplier supplier = new Supplier();
                            supplier.setSupplierName(supplierName.trim());
                            suppliers.add(supplier);
                        }
                    }
                    material.setSuppliers(suppliers);

                    materials.add(material);
                }
            }
        }
        return materials;
    }

    public int getTotalMaterialsByCode(String code) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Materials WHERE code LIKE ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + code + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public void deleteMaterial(int materialId) throws SQLException {
        String sql = "UPDATE Materials SET status = 'inactive' WHERE material_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            ps.executeUpdate();
        }
    }

    public List<Map<String, Object>> getMaterialsByConstructionSite(int siteId, int page, int itemsPerPage) throws SQLException {
        List<Map<String, Object>> materials = new ArrayList<>();
        String sql = "SELECT m.material_id, m.name, m.code AS material_code, m.unit, ed.quantity, ed.material_condition "
                + "FROM ExportDetails ed "
                + "JOIN ExportReceipts er ON ed.export_id = er.export_id "
                + "JOIN Materials m ON ed.material_id = m.material_id "
                + "WHERE er.site_id = ? AND m.status = 'active' "
                + "LIMIT ? OFFSET ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, siteId);
            ps.setInt(2, itemsPerPage);
            ps.setInt(3, (page - 1) * itemsPerPage);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> material = new HashMap<>();
                    material.put("material_id", rs.getInt("material_id"));
                    material.put("name", rs.getString("name"));
                    material.put("material_code", rs.getString("material_code"));
                    material.put("unit", rs.getString("unit"));
                    material.put("quantity", rs.getDouble("quantity"));
                    material.put("material_condition", rs.getString("material_condition"));
                    materials.add(material);
                }
            }
        }
        return materials;
    }
    public void addMaterial(Material material) throws SQLException {
    String sqlMaterial = "INSERT INTO Materials (code, category_id, name, description, unit, image_url) VALUES (?, ?, ?, ?, ?, ?)";
    try (PreparedStatement ps = conn.prepareStatement(sqlMaterial, PreparedStatement.RETURN_GENERATED_KEYS)) {
        ps.setString(1, material.getCode());
        ps.setInt(2, material.getCategory().getCategoryId());
        ps.setString(3, material.getName());
        ps.setString(4, material.getDescription());
        ps.setString(5, material.getUnit());
        ps.setString(6, material.getImageUrl());
        ps.executeUpdate();
    }
}
}