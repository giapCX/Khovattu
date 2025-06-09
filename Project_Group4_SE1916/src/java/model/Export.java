/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author ASUS
 */
import java.time.LocalDate;

public class Export {
    private int exportId;
    private int userId;
    private LocalDate exportDate;
    private String note;

    public Export() {
    }

    public Export(int exportId, int userId, LocalDate exportDate, String note) {
        this.exportId = exportId;
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

