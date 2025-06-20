package model;

import java.sql.Date;

public class ImportReceipt {

    private int importId;
    private String voucherId;
    private int supplierId;
    private int userId;
    private Date importDate;
    private String note;
    private String importerName; // Thêm trường này
    private String supplierName; // Thêm trường này
    private double total; // Đã có từ trước

    // Getters and Setters
    public int getImportId() {
        return importId;
    }

    public void setImportId(int importId) {
        this.importId = importId;
    }

    public String getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(String voucherId) {
        this.voucherId = voucherId;
    }

    public int getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(int supplierId) {
        this.supplierId = supplierId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Date getImportDate() {
        return importDate;
    }

    public void setImportDate(Date importDate) {
        this.importDate = importDate;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getImporterName() {
        return importerName;
    } // Thêm getter

    public void setImporterName(String importerName) {
        this.importerName = importerName;
    } // Thêm setter

    public String getSupplierName() {
        return supplierName;
    } // Thêm getter

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    } // Thêm setter

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }
}
