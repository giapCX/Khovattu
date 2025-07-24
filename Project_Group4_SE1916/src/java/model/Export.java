//export
package model;

import java.sql.Timestamp;

import java.util.List;

public class Export {

    private int exportId;
    private String receiptId;
    private int exporterId;
    private int receiverId;
    private Timestamp exportDate;
    private String note;
    private String exporterName;
    private String receiverName;
    private int proposalId;
    private String siteName;
    private int siteId;
    private User executor;
    private List<ExportDetail> exportDetail;

    public Export() {
    }

    public Export(int exportId, String receiptId, int exporterId, int receiverId, Timestamp exportDate, String note, String exporterName, String receiverName, int proposalId, String siteName, int siteId, User executor, List<ExportDetail> exportDetail) {
        this.exportId = exportId;
        this.receiptId = receiptId;
        this.exporterId = exporterId;
        this.receiverId = receiverId;
        this.exportDate = exportDate;
        this.note = note;
        this.exporterName = exporterName;
        this.receiverName = receiverName;
        this.proposalId = proposalId;
        this.siteName = siteName;
        this.siteId = siteId;
        this.executor = executor;
        this.exportDetail = exportDetail;
    }

    public int getExportId() {
        return exportId;
    }

    public void setExportId(int exportId) {
        this.exportId = exportId;
    }

    public String getReceiptId() {
        return receiptId;
    }

    public void setReceiptId(String receiptId) {
        this.receiptId = receiptId;
    }

    public int getExporterId() {
        return exporterId;
    }

    public void setExporterId(int exporterId) {
        this.exporterId = exporterId;
    }

    public int getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(int receiverId) {
        this.receiverId = receiverId;
    }

    public Timestamp getExportDate() {
        return exportDate;
    }

    public void setExportDate(Timestamp exportDate) {
        this.exportDate = exportDate;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getExporterName() {
        return exporterName;
    }

    public void setExporterName(String exporterName) {
        this.exporterName = exporterName;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public int getProposalId() {
        return proposalId;
    }

    public void setProposalId(int proposalId) {
        this.proposalId = proposalId;
    }

    public String getSiteName() {
        return siteName;
    }

    public void setSiteName(String siteName) {
        this.siteName = siteName;
    }

    public int getSiteId() {
        return siteId;
    }

    public void setSiteId(int siteId) {
        this.siteId = siteId;
    }

    public User getExecutor() {
        return executor;
    }

    public void setExecutor(User executor) {
        this.executor = executor;
    }

    public List<ExportDetail> getExportDetail() {
        return exportDetail;
    }

    public void setExportDetail(List<ExportDetail> exportDetail) {
        this.exportDetail = exportDetail;
    }

    
   

}
