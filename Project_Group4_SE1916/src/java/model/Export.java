//Export.java
package model;

import java.time.LocalDate;

public class Export {
    private int exportId;
    private String voucherId; 
    private int userId;       
    private LocalDate exportDate;
    private String note;
    private String exporterName;

    public String getExporterName() {
        return exporterName;
    }
 
    public void setExporterName(String exporterName) {
        this.exporterName = exporterName;
    }

    public Export(String exporterName) {
        this.exporterName = exporterName;
    }
    
    public Export() {
    }

    public Export(int exportId, String voucherId, int userId, LocalDate exportDate, String note) {
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

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
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
