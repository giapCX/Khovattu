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
    

    public Import() {
    }

    public Import(int importId, String receiptId, int proposalId, String importType, int responsible_id, int executor_id, String note, Timestamp importDate, List<ImportDetail> importDetail) {
        this.importId = importId;
        this.receiptId = receiptId;
        this.proposalId = proposalId;
        this.importType = importType;
        this.responsibleId = responsible_id;
        this.executorId = executor_id;
        this.note = note;
        this.importDate = importDate;
        this.importDetail = importDetail;
    }

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

    

    
}
