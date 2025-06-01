package dao;

import Dal.DBContext;
import model.MaterialBrand;
import model.MaterialCategory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MaterialBrandDAO {
    private Connection conn;

    public MaterialBrandDAO() {
        this.conn = DBContext.getConnection();
    }

    public List<MaterialBrand> getAllBrands() throws SQLException {
        List<MaterialBrand> brands = new ArrayList<>();
        String sql = "SELECT mb.brand_id, mb.name, mb.category_id, mc.name AS category_name " +
                     "FROM MaterialBrands mb " +
                     "JOIN MaterialCategories mc ON mb.category_id = mc.category_id";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MaterialBrand brand = new MaterialBrand();
                brand.setBrandId(rs.getInt("brand_id"));
                brand.setName(rs.getString("name"));
                
                MaterialCategory category = new MaterialCategory();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("category_name"));
                brand.setCategory(category);
                
                brands.add(brand);
            }
        }
        return brands;
    }
}