package model;

import java.time.LocalDate;

public class Import {
    private int importId;
    private String voucherId;
    private int userId;
    private LocalDate importDate;
    private String note;

    public Import() {
    }

    public Import(int importId, String voucherId, int userId, LocalDate importDate, String note) {
        this.importId = importId;
        this.voucherId = voucherId;
        this.userId = userId;
        this.importDate = importDate;
        this.note = note;
    }

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

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public LocalDate getImportDate() {
        return importDate;
    }

    public void setImportDate(LocalDate importDate) {
        this.importDate = importDate;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}