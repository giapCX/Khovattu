
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author ASUS
 */
public class Inventory {
     private int materialId;
    private String materialName; 
    private String materialCondition;
    private double quantityInStock;
    private String lastUpdated;

    public Inventory() {
    }

    public Inventory(int materialId, String materialName, String materialCondition, double quantityInStock, String lastUpdated) {
        this.materialId = materialId;
        this.materialName = materialName;
        this.materialCondition = materialCondition;
        this.quantityInStock = quantityInStock;
        this.lastUpdated = lastUpdated;
    }

    public int getMaterialId() {
        return materialId;
    }

    public void setMaterialId(int materialId) {
        this.materialId = materialId;
    }

    public String getMaterialName() {
        return materialName;
    }

    public void setMaterialName(String materialName) {
        this.materialName = materialName;
    }

    public String getMaterialCondition() {
        return materialCondition;
    }

    public void setMaterialCondition(String materialCondition) {
        this.materialCondition = materialCondition;
    }

    public double getQuantityInStock() {
        return quantityInStock;
    }

    public void setQuantityInStock(double quantityInStock) {
        this.quantityInStock = quantityInStock;
    }

    public String getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    
    
}
