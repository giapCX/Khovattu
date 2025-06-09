/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author ASUS
 */
public class ExportDetail {
    private int exportDetailId;
    private int exportId;
    private int materialId;
    private int quantity;
    private String materialCondition;
    private String reason;

    public ExportDetail() {
    }

    public ExportDetail(int exportDetailId, int exportId, int materialId, int quantity, String materialCondition, String reason) {
        this.exportDetailId = exportDetailId;
        this.exportId = exportId;
        this.materialId = materialId;
        this.quantity = quantity;
        this.materialCondition = materialCondition;
        this.reason = reason;
    }
    
    

    public int getExportDetailId() {
        return exportDetailId;
    }

    public void setExportDetailId(int exportDetailId) {
        this.exportDetailId = exportDetailId;
    }

    public int getExportId() {
        return exportId;
    }

    public void setExportId(int exportId) {
        this.exportId = exportId;
    }

    public int getMaterialId() {
        return materialId;
    }

    public void setMaterialId(int materialId) {
        this.materialId = materialId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getMaterialCondition() {
        return materialCondition;
    }

    public void setMaterialCondition(String materialCondition) {
        this.materialCondition = materialCondition;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    
}

