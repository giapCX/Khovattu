/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nfs://.netbeans.org/.nbi/platform/16.0.2/nbi/studio/nb10/nbi_setsdk.xml to edit this template
 */
package model;

/**
 *
 * @author Giap
 */
public class ImportDetail {
    private String materialName;
    private String unit;
    private int importDetailId;
    private int importId;
    private int materialId;
    private double quantity;
    private double pricePerUnit;
    private double totalPrice;
    private String materialCondition;
    private String materialCode; // Thêm thuộc tính materialCode

    // Getters and Setters
    public int getImportDetailId() {
        return importDetailId;
    }

    public void setImportDetailId(int importDetailId) {
        this.importDetailId = importDetailId;
    }

    public int getImportId() {
        return importId;
    }

    public void setImportId(int importId) {
        this.importId = importId;
    }

    public int getMaterialId() {
        return materialId;
    }

    public void setMaterialId(int materialId) {
        this.materialId = materialId;
    }

    public double getQuantity() {
        return quantity;
    }

    public void setQuantity(double quantity) {
        this.quantity = quantity;
    }

    public double getPricePerUnit() {
        return pricePerUnit;
    }

    public void setPricePerUnit(double pricePerUnit) {
        this.pricePerUnit = pricePerUnit;
    }

    public String getMaterialCondition() {
        return materialCondition;
    }

    public void setMaterialCondition(String materialCondition) {
        this.materialCondition = materialCondition;
    }

    // Thêm getter và setter cho materialCode
    public String getMaterialCode() {
        return materialCode;
    }

    public void setMaterialCode(String materialCode) {
        this.materialCode = materialCode;
    }
}