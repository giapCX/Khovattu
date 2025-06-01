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

    public List<MaterialCategory> getAllCategories() throws SQLException {
        List<MaterialCategory> categories = new ArrayList<>();
        String sql = "SELECT category_id, name FROM MaterialCategories";
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
}