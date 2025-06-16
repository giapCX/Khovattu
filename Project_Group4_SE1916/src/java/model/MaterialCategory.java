package model;

import java.util.List;

public class MaterialCategory {
    private int categoryId;
    private String name;
    private String parentCategoryName; // Thêm thuộc tính mới
    private List<Material> materials;

    public MaterialCategory() {
    }

    public MaterialCategory(int categoryId, String name, String parentCategoryName, List<Material> materials) {
        this.categoryId = categoryId;
        this.name = name;
        this.parentCategoryName = parentCategoryName;
        this.materials = materials;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getParentCategoryName() {
        return parentCategoryName;
    }

    public void setParentCategoryName(String parentCategoryName) {
        this.parentCategoryName = parentCategoryName;
    }

    public List<Material> getMaterials() {
        return materials;
    }

    public void setMaterials(List<Material> materials) {
        this.materials = materials;
    }
}