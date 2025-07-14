package model;

import java.time.LocalDate;

public class Import {

    private int importId;
    private String receiptId;
    private int userId;
    private LocalDate importDate;
    private String note;

    public Import() {
    }

    public Import(int importId, String receiptId, int userId, LocalDate importDate, String note) {
        this.importId = importId;
        this.receiptId = receiptId;
        this.userId = userId;
        this.importDate = importDate;
        this.note = note;
    }

    // Getters and Setters (update receiptId)
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