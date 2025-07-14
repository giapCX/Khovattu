package model;

public class ImportDetail {
    private int importDetailId;
    private Import importOb;
    private int materialId;
    private String materialName;
    private Double quantity;
    private String unit;
    private Double price;
    private String materialCondition;
    private Integer supplierId;
    private String supplierName;
    private Integer  siteId;
    private String siteName;
   

    public ImportDetail() {
    }

    public ImportDetail(int importDetailId, Import importOb, int materialId, String materialName, double quantity, String unit, double price, String materialCondition, Integer supplierId, String supplierName, Integer siteId, String siteName) {
        this.importDetailId = importDetailId;
        this.importOb = importOb;
        this.materialId = materialId;
        this.materialName = materialName;
        this.quantity = quantity;
        this.unit = unit;
        this.price = price;
        this.materialCondition = materialCondition;
        this.supplierId = supplierId;
        this.supplierName = supplierName;
        this.siteId = siteId;
        this.siteName = siteName;
    }

    public int getImportDetailId() {
        return importDetailId;
    }

    public void setImportDetailId(int importDetailId) {
        this.importDetailId = importDetailId;
    }

    public Import getImportOb() {
        return importOb;
    }

    public void setImportOb(Import importOb) {
        this.importOb = importOb;
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

    public Double getQuantity() {
        return quantity;
    }

    public void setQuantity(Double quantity) {
        this.quantity = quantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public Double getPrice() {
        return price;
    }

    public void setPrice(Double price) {
        this.price = price;
    }

    public String getMaterialCondition() {
        return materialCondition;
    }

    public void setMaterialCondition(String materialCondition) {
        this.materialCondition = materialCondition;
    }

    public Integer getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Integer supplierId) {
        this.supplierId = supplierId;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public Integer getSiteId() {
        return siteId;
    }

    public void setSiteId(Integer siteId) {
        this.siteId = siteId;
    }

    public String getSiteName() {
        return siteName;
    }

    public void setSiteName(String siteName) {
        this.siteName = siteName;
    }

    

    
}