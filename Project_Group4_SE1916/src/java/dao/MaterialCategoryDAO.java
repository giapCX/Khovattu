package dao;

import model.MaterialCategory;
import Dal.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MaterialCategoryDAO {

    private Connection conn;

    public MaterialCategoryDAO() {
        this.conn = DBContext.getConnection();
    }

    public List<MaterialCategory> getAllChildCategories() throws SQLException {
        List<MaterialCategory> categories = new ArrayList<>();
        String sql = "SELECT mc.category_id, mc.name, mc.parent_id, pc.name AS parent_category_name "
                + "FROM MaterialCategories mc "
                + "LEFT JOIN MaterialCategories pc ON mc.parent_id = pc.category_id "
                + "WHERE mc.parent_id IS NOT NULL";

        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MaterialCategory category = new MaterialCategory();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("name"));
                category.setParentCategoryName(rs.getString("parent_category_name"));
                category.setParentId(rs.getInt("parent_id"));
                categories.add(category);
            }
        }
        return categories;
    }

    public List<MaterialCategory> getAllParentCategories() throws SQLException {
        List<MaterialCategory> categories = new ArrayList<>();
        String sql = "SELECT category_id, name, status FROM MaterialCategories WHERE parent_id IS NULL";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MaterialCategory category = new MaterialCategory();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("name"));
                category.setStatus(rs.getString("status"));
                categories.add(category);
            }
        }
        return categories;
    }
    
    public List<MaterialCategory> getAllParentCategories2() throws SQLException {
        List<MaterialCategory> categories = new ArrayList<>();
        String sql = "SELECT category_id, name FROM MaterialCategories WHERE parent_id IS NULL";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MaterialCategory category = new MaterialCategory();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("name"));
                categories.add(category);
            }
        }
        return categories;
    }

    public List<MaterialCategory> getParentCategoriesWithFilters(String search, String status, int page, int itemsPerPage) throws SQLException {
        List<MaterialCategory> categories = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT category_id, name, status FROM MaterialCategories WHERE parent_id IS NULL");
        
        // Thêm điều kiện tìm kiếm và lọc trạng thái
        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        
        if (search != null && !search.isEmpty()) {
            conditions.add("name LIKE ?");
            params.add("%" + search + "%");
        }
        
        if (status != null && !status.isEmpty()) {
            conditions.add("status = ?");
            params.add(status);
        }
        
        if (!conditions.isEmpty()) {
            sql.append(" AND ").append(String.join(" AND ", conditions));
        }
        
        // Thêm phân trang
        sql.append(" ORDER BY category_id LIMIT ? OFFSET ?");
        params.add(itemsPerPage);
        params.add((page - 1) * itemsPerPage);

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            // Gán các tham số
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MaterialCategory category = new MaterialCategory();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setName(rs.getString("name"));
                    category.setStatus(rs.getString("status"));
                    categories.add(category);
                }
            }
        }
        return categories;
    }

    public int getTotalParentCategories(String search, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM MaterialCategories WHERE parent_id IS NULL");
        
        // Thêm điều kiện tìm kiếm và lọc trạng thái
        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        
        if (search != null && !search.isEmpty()) {
            conditions.add("name LIKE ?");
            params.add("%" + search + "%");
        }
        
        if (status != null && !status.isEmpty()) {
            conditions.add("status = ?");
            params.add(status);
        }
        
        if (!conditions.isEmpty()) {
            sql.append(" AND ").append(String.join(" AND ", conditions));
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            // Gán các tham số
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public MaterialCategory getParentCategoryById(int categoryId) throws SQLException {
        String sql = "SELECT category_id, name, status FROM MaterialCategories WHERE category_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MaterialCategory category = new MaterialCategory();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setName(rs.getString("name"));
                    category.setStatus(rs.getString("status"));
                    return category;
                }
            }
        }
        return null;
    }
    public MaterialCategory getChildCategoryById(int categoryId) throws SQLException {
    String sql = "SELECT category_id, name, parent_id FROM MaterialCategories WHERE category_id = ? AND parent_id IS NOT NULL";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setInt(1, categoryId);

        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                MaterialCategory category = new MaterialCategory();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("name"));
                category.setParentId(rs.getInt("parent_id"));
                return category;
            }
        }
    }
    return null;
}
    public void addChildCategory(String name, int parentId) throws SQLException {
        String sql = "INSERT INTO MaterialCategories (name, parent_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, parentId);
            ps.executeUpdate();
        }
    }

    public void addParentCategory(String name, String status) throws SQLException {
        String sql = "INSERT INTO MaterialCategories (name, parent_id, status) VALUES (?, NULL, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, status);
            ps.executeUpdate();
        }
    }

    public void updateParentCategory(int categoryId, String name, String status) throws SQLException {
        String sql = "CALL UpdateCategoryAndChildren(?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.setString(2, name);
            ps.setString(3, status);
            ps.executeUpdate();
        }
    }

    public boolean categoryExistsByName(String name, int parentId) throws SQLException {
        String sql;
        if (parentId == 0) {
            sql = "SELECT COUNT(*) FROM MaterialCategories WHERE name = ? AND parent_id IS NULL";
        } else {
            sql = "SELECT COUNT(*) FROM MaterialCategories WHERE name = ? AND parent_id = ?";
        }
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            if (parentId != 0) {
                ps.setInt(2, parentId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public List<MaterialCategory> getChildCategoriesByParentId(int parentId) throws SQLException {
        List<MaterialCategory> categories = new ArrayList<>();
        String sql = "SELECT category_id, name FROM MaterialCategories WHERE parent_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MaterialCategory category = new MaterialCategory();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setName(rs.getString("name"));
                    categories.add(category);
                }
            }
        }
        return categories;
    }

    public boolean updateChildCategory(int categoryId, String newName, int parentId) {
        String query = "UPDATE MaterialCategories SET name = ?, parent_id = ? WHERE category_id = ? AND status = 'active'";
        
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, newName);
            ps.setInt(2, parentId);
            ps.setInt(3, categoryId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public int getChildCategoryCount(int parentId) throws SQLException {
    String sql = "SELECT COUNT(*) FROM MaterialCategories WHERE parent_id = ?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, parentId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
    }
    return 0;
}
    public void addChildCategory(String name, int parentId, String status) throws SQLException {
    String sql = "INSERT INTO MaterialCategories (name, parent_id, status) VALUES (?, ?, ?)";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, name);
        ps.setInt(2, parentId);
        ps.setString(3, status);
        ps.executeUpdate();
    }
}
    public MaterialCategory getCategoryById(int categoryId) throws SQLException {
    String sql = "SELECT category_id, name, parent_id, status FROM MaterialCategories WHERE category_id = ?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, categoryId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                MaterialCategory category = new MaterialCategory();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("name"));
                
                // Xử lý parent_id (có thể null)
                int parentId = rs.getInt("parent_id");
                if (rs.wasNull()) {
                    category.setParentId(0); // 0 nghĩa là danh mục cha
                } else {
                    category.setParentId(parentId);
                }
                
                category.setStatus(rs.getString("status"));
                return category;
            }
        }
    }
    return null;
}

/**
 * Kiểm tra danh mục có tồn tại theo tên (loại trừ một ID cụ thể)
 */
public boolean categoryExistsByNameExcludingId(String name, int parentId, int excludeId) throws SQLException {
    String sql;
    if (parentId == 0) {
        sql = "SELECT COUNT(*) FROM MaterialCategories WHERE name = ? AND parent_id IS NULL AND category_id != ?";
    } else {
        sql = "SELECT COUNT(*) FROM MaterialCategories WHERE name = ? AND parent_id = ? AND category_id != ?";
    }
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, name.trim());
        if (parentId == 0) {
            ps.setInt(2, excludeId);
        } else {
            ps.setInt(2, parentId);
            ps.setInt(3, excludeId);
        }
        
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
    }
    return false;
}

/**
 * Kiểm tra danh mục có vật tư đi kèm không
 */
public boolean hasMaterials(int categoryId) throws SQLException {
    String sql = "SELECT COUNT(*) FROM Materials WHERE category_id = ?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, categoryId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
    }
    return false;
}

/**
 * Cập nhật danh mục thành danh mục cha
 */
public void updateToParentCategory(int categoryId, String name, String status) throws SQLException {
    String sql = "UPDATE MaterialCategories SET name = ?, parent_id = NULL, status = ? WHERE category_id = ?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, name);
        ps.setString(2, status);
        ps.setInt(3, categoryId);
        ps.executeUpdate();
    }
}

/**
 * Cập nhật danh mục thành danh mục con
 */
public void updateToChildCategory(int categoryId, String name, int parentId, String status) throws SQLException {
    String sql = "UPDATE MaterialCategories SET name = ?, parent_id = ?, status = ? WHERE category_id = ?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, name);
        ps.setInt(2, parentId);
        ps.setString(3, status);
        ps.setInt(4, categoryId);
        ps.executeUpdate();
    }
}
}