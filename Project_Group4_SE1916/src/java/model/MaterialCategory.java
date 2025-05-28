/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.List;

/**
 *
 * @author Admin
 */
public class MaterialCategory {
    private int categoryId;
    private String name;
    private List<MaterialBrand> brands;

    public MaterialCategory() {
    }

    public MaterialCategory(int categoryId, String name, List<MaterialBrand> brands) {
        this.categoryId = categoryId;
        this.name = name;
        this.brands = brands;
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

    public List<MaterialBrand> getBrands() {
        return brands;
    }

    public void setBrands(List<MaterialBrand> brands) {
        this.brands = brands;
    }
    
}
