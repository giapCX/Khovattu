package model;

public class ImportDetail {
    private int importDetailId;
    private int importId;
    private int materialId;
    private double quantity;
    private double pricePerUnit;
    private String materialCondition;
    private int supplierId;

    private String materialCode;
    private String materialName;
    private String unit;
    private String materialCategory;

    public ImportDetail() {
    }

    public ImportDetail(int importDetailId, int importId, int materialId, double quantity,
                       double pricePerUnit, String materialCondition, int supplierId,
                       String materialCode, String materialName, String unit, String materialCategory) {
        this.importDetailId = importDetailId;
        this.importId = importId;
        this.materialId = materialId;
        this.quantity = quantity;
        this.pricePerUnit = pricePerUnit;
        this.materialCondition = materialCondition;
        this.supplierId = supplierId;
        this.materialCode = materialCode;
        this.materialName = materialName;
        this.unit = unit;
        this.materialCategory = materialCategory;
    }

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

    public int getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(int supplierId) {
        this.supplierId = supplierId;
    }

    public String getMaterialCode() {
        return materialCode;
    }

    public void setMaterialCode(String materialCode) {
        this.materialCode = materialCode;
    }

    public String getMaterialName() {
        return materialName;
    }

    public void setMaterialName(String materialName) {
        this.materialName = materialName;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getMaterialCategory() {
        return materialCategory;
    }

    public void setMaterialCategory(String materialCategory) {
        this.materialCategory = materialCategory;
    }
}