package model;

import java.time.LocalDate;

public class Export {
    private int exportId;
    private String voucherId; 
    private String userId;       
    private LocalDate exportDate;
    private String note;

    public Export() {
    }

    public Export(int exportId, String voucherId, String userId, LocalDate exportDate, String note) {
        this.exportId = exportId;
        this.voucherId = voucherId;
        this.userId = userId;
        this.exportDate = exportDate;
        this.note = note;
    }

    public int getExportId() {
        return exportId;
    }

    public void setExportId(int exportId) {
        this.exportId = exportId;
    }

    public String getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(String voucherId) {
        this.voucherId = voucherId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
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
}
