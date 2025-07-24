package model;

import java.sql.Date;
import java.util.List;

public class ImportReceipt {
    private int importId;
    private int proposalId;
    private String importType;
    private int responsibleId;
    private String deliverySupplierName;
    private String deliverySupplierPhone;
    private int executorId;
    private Date importDate;
    private String note;
    private Integer supplierId;
    private Integer siteId;

    private String executorName;
    private String siteName;
    private String supplierName;

    private List<ImportDetail> details;

    public int getImportId() {
        return importId;
    }

    public void setImportId(int importId) {
        this.importId = importId;
    }

    public int getProposalId() {
        return proposalId;
    }

    public void setProposalId(int proposalId) {
        this.proposalId = proposalId;
    }

    public String getImportType() {
        return importType;
    }

    public void setImportType(String importType) {
        this.importType = importType;
    }

    public int getResponsibleId() {
        return responsibleId;
    }

    public void setResponsibleId(int responsibleId) {
        this.responsibleId = responsibleId;
    }

    public String getDeliverySupplierName() {
        return deliverySupplierName;
    }

    public void setDeliverySupplierName(String deliverySupplierName) {
        this.deliverySupplierName = deliverySupplierName;
    }

    public String getDeliverySupplierPhone() {
        return deliverySupplierPhone;
    }

    public void setDeliverySupplierPhone(String deliverySupplierPhone) {
        this.deliverySupplierPhone = deliverySupplierPhone;
    }

    public int getExecutorId() {
        return executorId;
    }

    public void setExecutorId(int executorId) {
        this.executorId = executorId;
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

    public Integer getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Integer supplierId) {
        this.supplierId = supplierId;
    }

    public Integer getSiteId() {
        return siteId;
    }

    public void setSiteId(Integer siteId) {
        this.siteId = siteId;
    }

    public String getExecutorName() {
        return executorName;
    }

    public void setExecutorName(String executorName) {
        this.executorName = executorName;
    }

    public String getSiteName() {
        return siteName;
    }

    public void setSiteName(String siteName) {
        this.siteName = siteName;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public List<ImportDetail> getDetails() {
        return details;
    }

    public void setDetails(List<ImportDetail> details) {
        this.details = details;
    }
    

   
}