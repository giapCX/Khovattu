package model;

import java.util.List;

public class MaterialCategory {
    private int categoryId;
    private String name;
    private String parentCategoryName;
    private int parentId;// Thêm thuộc tính mới
    private String status; 
    private List<Material> materials;
    private String ChildCategoryStatus;

    public MaterialCategory() {
    }

    public MaterialCategory(int categoryId, String name, String parentCategoryName, int parentId, String status, List<Material> materials, String ChildCategoryStatus) {
        this.categoryId = categoryId;
        this.name = name;
        this.parentCategoryName = parentCategoryName;
        this.parentId = parentId;
        this.status = status;
        this.materials = materials;
        this.ChildCategoryStatus = ChildCategoryStatus;
    }

    public String getChildCategoryStatus() {
        return ChildCategoryStatus;
    }

    public void setChildCategoryStatus(String ChildCategoryStatus) {
        this.ChildCategoryStatus = ChildCategoryStatus;
    }



    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public int getParentId() {
        return parentId;
    }

    public void setParentId(int parentId) {
        this.parentId = parentId;
    }
    
}