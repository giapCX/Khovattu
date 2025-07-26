package model;

import java.sql.Timestamp;
import java.util.List;

public class Import {

    private int importId;
    private String receiptId;
    private int proposalId;
    private String importType;
    private Integer responsibleId;
    private Integer executorId;
    private String note;
    private Timestamp importDate;
    private List<ImportDetail> importDetail;
    private User executor;
    private Proposal proposal;
    private String deliverySupplierName;
    private String deliverySupplierPhone;
    private Integer supplierId; // Thêm trường supplierId

    public Import() {
    }

    public Import(int importId, String receiptId, int proposalId, String importType, Integer responsibleId, Integer executorId, 
                  String note, Timestamp importDate, List<ImportDetail> importDetail, String deliverySupplierName, 
                  String deliverySupplierPhone, Integer supplierId) {
        this.importId = importId;
        this.receiptId = receiptId;
        this.proposalId = proposalId;
        this.importType = importType;
        this.responsibleId = responsibleId;
        this.executorId = executorId;
        this.note = note;
        this.importDate = importDate;
        this.importDetail = importDetail;
        this.deliverySupplierName = deliverySupplierName;
        this.deliverySupplierPhone = deliverySupplierPhone;
        this.supplierId = supplierId;
    }

    // Getters and Setters
    public User getExecutor() {
        return executor;
    }

    public void setExecutor(User executor) {
        this.executor = executor;
    }

    public Proposal getProposal() {
        return proposal;
    }

    public void setProposal(Proposal proposal) {
        this.proposal = proposal;
    }

    public int getImportId() {
        return importId;
    }

    public void setImportId(int importId) {
        this.importId = importId;
    }

    public String getReceiptId() {
        return receiptId;
    }

    public void setReceiptId(String receiptId) {
        this.receiptId = receiptId;
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

    public Integer getResponsibleId() {
        return responsibleId;
    }

    public void setResponsibleId(Integer responsibleId) {
        this.responsibleId = responsibleId;
    }

    public Integer getExecutorId() {
        return executorId;
    }

    public void setExecutorId(Integer executorId) {
        this.executorId = executorId;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Timestamp getImportDate() {
        return importDate;
    }

    public void setImportDate(Timestamp importDate) {
        this.importDate = importDate;
    }

    public List<ImportDetail> getImportDetail() {
        return importDetail;
    }

    public void setImportDetail(List<ImportDetail> importDetail) {
        this.importDetail = importDetail;
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

    public Integer getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Integer supplierId) {
        this.supplierId = supplierId;
    }
}