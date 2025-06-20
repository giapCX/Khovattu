package dao;

import Dal.DBContext;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import model.Material;
import model.MaterialCategory;
import model.Supplier;
import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;



public class SupplierDAO {

    private Connection conn;

    public SupplierDAO(Connection conn) {
        this.conn = conn;
    }

    public Supplier getSupplierById(int supplierId) {
        Supplier supplier = null;

        String sql = "SELECT s.supplier_id, s.name AS supplier_name, s.phone AS supplier_phone, "
                + "s.address AS supplier_address, s.email AS supplier_email, s.status AS supplier_status, "
                + "m.material_id, m.code AS material_code, m.name AS material_name, m.description AS material_description, "
                + "m.unit AS material_unit, m.image_url AS material_image_url, "
                + "mc.category_id, mc.name AS category_name "
                + "FROM Suppliers s "
                + "LEFT JOIN SupplierMaterials sm ON s.supplier_id = sm.supplier_id "
                + "LEFT JOIN Materials m ON sm.material_id = m.material_id "
                + "LEFT JOIN MaterialCategories mc ON m.category_id = mc.category_id "
                + "WHERE s.supplier_id = ? "
                + "ORDER BY m.material_id";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, supplierId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    if (supplier == null) {
                        supplier = new Supplier();
                        supplier.setSupplierId(rs.getInt("supplier_id"));
                        supplier.setSupplierName(rs.getString("supplier_name"));
                        supplier.setSupplierPhone(rs.getString("supplier_phone"));
                        supplier.setSupplierAddress(rs.getString("supplier_address"));
                        supplier.setSupplierEmail(rs.getString("supplier_email"));
                        supplier.setSupplierStatus(rs.getString("supplier_status"));
                        supplier.setMaterials(new ArrayList<>());
                    }

                    int materialId = rs.getInt("material_id");
                    if (materialId > 0) {
                        Material material = new Material();
                        material.setMaterialId(materialId);
                        material.setCode(rs.getString("material_code"));
                        material.setName(rs.getString("material_name"));
                        material.setDescription(rs.getString("material_description"));
                        material.setUnit(rs.getString("material_unit"));
                        material.setImageUrl(rs.getString("material_image_url"));
                        MaterialCategory category = new MaterialCategory();
                        category.setCategoryId(rs.getInt("category_id"));
                        category.setName(rs.getString("category_name"));
                        material.setCategory(category);
                        supplier.getMaterials().add(material);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return supplier;
    }

    public boolean updateSupplier(Supplier supplier) {
        String sql = "UPDATE Suppliers SET name = ?, phone = ?, address = ?, email = ?, status = ? WHERE supplier_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, supplier.getSupplierName());
            stmt.setString(2, supplier.getSupplierPhone());
            stmt.setString(3, supplier.getSupplierAddress());
            stmt.setString(4, supplier.getSupplierEmail());
            stmt.setString(5, supplier.getSupplierStatus());
            stmt.setInt(6, supplier.getSupplierId());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addSupplier(Supplier supplier) {
        String sql = "INSERT INTO Suppliers (name, phone, address, email, status) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, supplier.getSupplierName());
            stmt.setString(2, supplier.getSupplierPhone());
            stmt.setString(3, supplier.getSupplierAddress());
            stmt.setString(4, supplier.getSupplierEmail());
            stmt.setString(5, supplier.getSupplierStatus());

            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int countSuppliersByNamePhoneAddressStatus(String name, String phone, String address, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Suppliers WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (name != null && !name.trim().isEmpty()) {
            sql.append(" AND name LIKE ? ");
            params.add("%" + name.trim() + "%");
        }
        if (phone != null && !phone.trim().isEmpty()) {
            sql.append(" AND phone LIKE ? ");
            params.add("%" + phone.trim() + "%");
        }
        if (address != null && !address.trim().isEmpty()) {
            sql.append(" AND address LIKE ? ");
            params.add("%" + address.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ? ");
            params.add(status.trim());
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<Supplier> searchSuppliersByNamePhoneAddressStatusWithPaging(
            String name, String phone, String address, String status,
            int offset, int limit) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT * FROM Suppliers WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (name != null && !name.trim().isEmpty()) {
            sql.append(" AND name  LIKE ? ");
            params.add("%" + name.trim() + "%");
        }
        if (phone != null && !phone.trim().isEmpty()) {
            sql.append(" AND phone  LIKE ? ");
            params.add("%" + phone.trim() + "%");
        }
        if (address != null && !address.trim().isEmpty()) {
            sql.append(" AND address  LIKE ? ");
            params.add("%" + address.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status LIKE ? ");
            params.add("%" + status.trim() + "%");
        }

        sql.append(" ORDER BY supplier_id LIMIT ? OFFSET ? ");
        params.add(limit);
        params.add(offset);

        List<Supplier> list = new ArrayList<>();

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Supplier supplier = new Supplier();
                    supplier.setSupplierId(rs.getInt("supplier_id"));
                    supplier.setSupplierName(rs.getString("name"));
                    supplier.setSupplierPhone(rs.getString("phone"));
                    supplier.setSupplierAddress(rs.getString("address"));
                    supplier.setSupplierEmail(rs.getString("email"));
                    supplier.setSupplierStatus(rs.getString("status"));

                    list.add(supplier);
                }
            }
        }

        return list;
    }

    // Thêm phương thức thêm nhà cung cấp và trả về supplierId
    public int addSupplierWithId(Supplier supplier) throws SQLException {
        String sql = "INSERT INTO Suppliers (name, phone, address, email, status) VALUES (?, ?, ?, ?, ?) "
                + "RETURNING supplier_id";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, supplier.getSupplierName());
            stmt.setString(2, supplier.getSupplierPhone());
            stmt.setString(3, supplier.getSupplierAddress());
            stmt.setString(4, supplier.getSupplierEmail());
            stmt.setString(5, supplier.getSupplierStatus());

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("supplier_id");
                }
            }
        }
        throw new SQLException("Không thể lấy supplier_id sau khi thêm.");
    }

    public List<Supplier> getAllSuppliers() throws SQLException {
        List<Supplier> suppliers = new ArrayList<>();
        String sql = "SELECT supplier_id, name, phone, address, email, status FROM Suppliers";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Supplier supplier = new Supplier();
                supplier.setSupplierId(rs.getInt("supplier_id"));
                supplier.setSupplierName(rs.getString("name"));
                supplier.setSupplierPhone(rs.getString("phone"));
                supplier.setSupplierAddress(rs.getString("address"));
                supplier.setSupplierEmail(rs.getString("email"));
                supplier.setSupplierStatus(rs.getString("status"));
                suppliers.add(supplier);
            }
        }
        return suppliers;
    }

    public List<Supplier> getSuppliers() {
        List<Supplier> suppliers = new ArrayList<>();

        String sql = "SELECT s.supplier_id, s.name AS supplier_name, s.phone AS supplier_phone, "
                + "s.address AS supplier_address, s.email AS supplier_email, s.status AS supplier_status, "
                + "m.material_id, m.code AS material_code, m.name AS material_name, m.description AS material_description, "
                + "m.unit AS material_unit, m.image_url AS material_image_url, "
                + "mc.category_id, mc.name AS category_name "
                + "FROM Suppliers s "
                + "LEFT JOIN SupplierMaterials sm ON s.supplier_id = sm.supplier_id "
                + "LEFT JOIN Materials m ON sm.material_id = m.material_id "
                + "LEFT JOIN MaterialCategories mc ON m.category_id = mc.category_id "
                + "ORDER BY s.supplier_id";

        try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            Map<Integer, Supplier> supplierMap = new LinkedHashMap<>();

            while (rs.next()) {
                int supplierId = rs.getInt("supplier_id");
                Supplier supplier = supplierMap.get(supplierId);

                if (supplier == null) {
                    supplier = new Supplier();
                    supplier.setSupplierId(supplierId);
                    supplier.setSupplierName(rs.getString("supplier_name"));
                    supplier.setSupplierPhone(rs.getString("supplier_phone"));
                    supplier.setSupplierAddress(rs.getString("supplier_address"));
                    supplier.setSupplierEmail(rs.getString("supplier_email"));
                    supplier.setSupplierStatus(rs.getString("supplier_status"));
                    supplier.setMaterials(new ArrayList<>());
                    supplierMap.put(supplierId, supplier);
                }

                int materialId = rs.getInt("material_id");
                if (materialId > 0) {
                    Material material = new Material();
                    material.setMaterialId(materialId);
                    material.setCode(rs.getString("material_code"));
                    material.setName(rs.getString("material_name"));
                    material.setDescription(rs.getString("material_description"));
                    material.setUnit(rs.getString("material_unit"));
                    material.setImageUrl(rs.getString("material_image_url"));

                    MaterialCategory category = new MaterialCategory();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setName(rs.getString("category_name"));

                    material.setCategory(category);

                    supplier.getMaterials().add(material);
                }
            }
            suppliers.addAll(supplierMap.values());
            rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return suppliers;
    }

    public int countMaterialOfSupplierBySupplierIdCategoryNameMaterialName(int supplierId, String categoryName, String materialName) throws SQLException {
        // Xây dựng câu truy vấn SQL
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT m.material_id) FROM Materials m "
                + "JOIN SupplierMaterials sm ON m.material_id = sm.material_id "
                + "JOIN MaterialCategories mc ON m.category_id = mc.category_id "
                + "WHERE sm.supplier_id = ? "
        );

        // Danh sách các tham số để truyền vào PreparedStatement
        List<Object> params = new ArrayList<>();
        params.add(supplierId);

        // Thêm điều kiện lọc theo categoryName nếu có
        if (categoryName != null && !categoryName.trim().isEmpty()) {
            sql.append(" AND mc.name LIKE ? ");
            params.add("%" + categoryName.trim() + "%");
        }

        // Thêm điều kiện lọc theo materialName nếu có
        if (materialName != null && !materialName.trim().isEmpty()) {
            sql.append(" AND m.name LIKE ? ");
            params.add("%" + materialName.trim() + "%");
        }

        // Khởi tạo PreparedStatement và thiết lập các tham số
        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            // Thiết lập các tham số vào PreparedStatement
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            // Thực thi truy vấn và lấy kết quả
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1); // Trả về số lượng vật tư thỏa mãn điều kiện
                }
            }
        }

        return 0; // Nếu không có vật tư nào thỏa mãn điều kiện
    }

    public List<Material> searchMaterialOfSuppliersBySupplierIdCategoryNameMaterialNameWithPaging( 
        int supplierId, String categoryName, String materialName,
        int offset, int recordsPerPage) throws SQLException {

    StringBuilder sql = new StringBuilder(
        "SELECT DISTINCT m.material_id, m.code, m.name, m.description, m.unit, m.image_url, "
      + "mc.category_id, mc.name AS category_name, "
      + "mc.parent_id, mc2.name AS parent_category_name "
      + "FROM Materials m "
      + "JOIN SupplierMaterials sm ON m.material_id = sm.material_id "
      + "JOIN MaterialCategories mc ON m.category_id = mc.category_id "
      + "LEFT JOIN MaterialCategories mc2 ON mc.parent_id = mc2.category_id "
      + "WHERE sm.supplier_id = ? "
    );

    List<Object> params = new ArrayList<>();
    params.add(supplierId);

    if (categoryName != null && !categoryName.trim().isEmpty()) {
        sql.append(" AND mc.name LIKE ? ");
        params.add("%" + categoryName.trim() + "%");
    }

    if (materialName != null && !materialName.trim().isEmpty()) {
        sql.append(" AND m.name LIKE ? ");
        params.add("%" + materialName.trim() + "%");
    }

    sql.append(" ORDER BY m.material_id LIMIT ? OFFSET ? ");
    params.add(recordsPerPage);
    params.add(offset);

    List<Material> materials = new ArrayList<>();

    try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
        for (int i = 0; i < params.size(); i++) {
            stmt.setObject(i + 1, params.get(i));
        }

        try (ResultSet rs = stmt.executeQuery()) {
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
                category.setParentId(rs.getInt("parent_id"));
                category.setParentCategoryName(rs.getString("parent_category_name"));

                material.setCategory(category);

                materials.add(material);
            }
        }
    }

    return materials;
}


    // Thêm phương thức kiểm tra nhà cung cấp tồn tại theo ID
    public boolean supplierExists(int supplierId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Suppliers WHERE supplier_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, supplierId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    
    // Thêm phương thức kiểm tra nhà cung cấp tồn tại theo tên

    public boolean supplierExistsByName(String name) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Suppliers WHERE name = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    public void addMaterialsToSupplier(int supplierId, List<Integer> materialIds) throws SQLException {
    String sql = "INSERT INTO SupplierMaterials (supplier_id, material_id) VALUES (?, ?)";

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        for (int materialId : materialIds) {
            ps.setInt(1, supplierId);
            ps.setInt(2, materialId);
            ps.addBatch();
        }

        ps.executeBatch();
    }
}
    public boolean isMaterialAlreadyExists(int supplierId, int materialId) throws SQLException {
    String sql = "SELECT COUNT(*) FROM SupplierMaterials WHERE supplier_id = ? AND material_id = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, supplierId);
        stmt.setInt(2, materialId);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
    }
    return false;
}
}
