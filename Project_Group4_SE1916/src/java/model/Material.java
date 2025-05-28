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
public class Material {

    private int materialId;
    private String name;
    private String description;
    private String unit;
    private String imageUrl;
    private MaterialBrand brand;
    private List<Supplier> suppliers;

    public Material() {
    }

    public Material(int materialId, String name, String description, String unit, String imageUrl, MaterialBrand brand, List<Supplier> suppliers) {
        this.materialId = materialId;
        this.name = name;
        this.description = description;
        this.unit = unit;
        this.imageUrl = imageUrl;
        this.brand = brand;
        this.suppliers = suppliers;
    }

    public int getMaterialId() {
        return materialId;
    }

    public void setMaterialId(int materialId) {
        this.materialId = materialId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public MaterialBrand getBrand() {
        return brand;
    }

    public void setBrand(MaterialBrand brand) {
        this.brand = brand;
    }

    public List<Supplier> getSuppliers() {
        return suppliers;
    }

    public void setSuppliers(List<Supplier> suppliers) {
        this.suppliers = suppliers;
    }
    
}
