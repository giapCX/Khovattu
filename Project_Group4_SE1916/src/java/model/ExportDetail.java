package model;

public class ExportDetail {

    private int exportDetailId;
    private int exportId;
    private int materialId;
    private double quantity;
    private String materialCondition;
    private String reason;

    private String materialCode;
    private String materialName;
    private String unit;
    private String materialCategory;

    public ExportDetail() {
    }

    public ExportDetail(int exportDetailId, int exportId, int materialId, double quantity,
            String materialCondition, String reason,
            String materialCode, String materialName, String unit, String materialCategory) {
        this.exportDetailId = exportDetailId;
        this.exportId = exportId;
        this.materialId = materialId;
        this.quantity = quantity;
        this.materialCondition = materialCondition;
        this.reason = reason;
        this.materialCode = materialCode;
        this.materialName = materialName;
        this.unit = unit;
        this.materialCategory = materialCategory;
    }

    public int getExportDetailId() {
        return exportDetailId;
    }

    public void setExportDetailId(int exportDetailId) {
        this.exportDetailId = exportDetailId;
    }

    public int getExportId() {
        return exportId;
    }

    public void setExportId(int exportId) {
        this.exportId = exportId;
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

    public String getMaterialCondition() {
        return materialCondition;
    }

    public void setMaterialCondition(String materialCondition) {
        this.materialCondition = materialCondition;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
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
