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
        String sql = "SELECT category_id, name FROM MaterialCategories WHERE parent_id IS NOT NULL";
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

    public List<MaterialCategory> getAllParentCategories() throws SQLException {
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

    public void addChildCategory(String name, int parentId) throws SQLException {
        String sql = "INSERT INTO MaterialCategories (name, parent_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, parentId);
            ps.executeUpdate();
        }
    }

    public void addParentCategory(String name) throws SQLException {
        String sql = "INSERT INTO MaterialCategories (name, parent_id) VALUES (?, NULL)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
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
}