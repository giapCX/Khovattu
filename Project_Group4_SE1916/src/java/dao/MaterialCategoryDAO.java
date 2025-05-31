package dao;

import java.sql.*;
import java.util.*;
import model.MaterialCategory;

public class MaterialCategoryDAO {
    private Connection conn;

    public MaterialCategoryDAO(Connection conn) {
        this.conn = conn;
    }

    public List<MaterialCategory> getAllCategories() throws SQLException {
        List<MaterialCategory> list = new ArrayList<>();
        String sql = "SELECT categoryId, name, description FROM MaterialCategory";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MaterialCategory cat = new MaterialCategory();
                cat.setCategoryId(rs.getInt("categoryId"));
                cat.setName(rs.getString("name"));
                cat.setDescription(rs.getString("description"));
                list.add(cat);
            }
        }
        return list;
    }

    public MaterialCategory getCategoryById(int id) throws SQLException {
        String sql = "SELECT categoryId, name FROM MaterialCategory WHERE categoryId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MaterialCategory cat = new MaterialCategory();
                    cat.setCategoryId(rs.getInt("categoryId"));
                    cat.setName(rs.getString("name"));
                    return cat;
                }
            }
        }
        return null;
    }

    public void addCategory(MaterialCategory cat) throws SQLException {
        String sql = "INSERT INTO MaterialCategory (name) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cat.getName());
            ps.executeUpdate();
        }
    }

    public void updateCategory(MaterialCategory cat) throws SQLException {
        String sql = "UPDATE MaterialCategory SET name = ? WHERE categoryId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cat.getName());
            ps.setInt(2, cat.getCategoryId());
            ps.executeUpdate();
        }
    }

    public void deleteCategory(int id) throws SQLException {
        String sql = "DELETE FROM MaterialCategory WHERE categoryId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
} 