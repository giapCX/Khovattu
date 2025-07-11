//export
package model;

import java.time.LocalDate;

public class Export {
    private int exportId;
    private String receiptId;
    private int exporterId;
    private int receiverId;
    private LocalDate exportDate;
    private String note;
    private String exporterName;
    private String receiverName;

    public Export() {
    }
    
    public Export(int exportId, String receiptId, int exporterId, int receiverId, LocalDate exportDate, String note, String exporterName, String receiverName) {
        this.exportId = exportId;
        this.receiptId = receiptId;
        this.exporterId = exporterId;
        this.receiverId = receiverId;
        this.exportDate = exportDate;
        this.note = note;
        this.exporterName = exporterName;
        this.receiverName = receiverName;
    }  

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
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

    public LocalDate getExportDate() {
        return exportDate;
    }

    public void setExportDate(LocalDate exportDate) {
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
}