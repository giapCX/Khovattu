
package model;

/**
 *
 * @author ASUS
 */
import java.sql.Date;

public class Inventory {

    private int materialId;
    private String materialName;
    private String materialCondition;
    private double quantityInStock;
    private Date lastUpdated;

    public Inventory() {
    }

    public Inventory(int materialId, String materialName, String materialCondition, double quantityInStock, Date lastUpdated) {
        this.materialId = materialId;
        this.materialName = materialName;
        this.materialCondition = materialCondition;
        this.quantityInStock = quantityInStock;
        this.lastUpdated = lastUpdated;
    }

    public int getMaterialId() {
        return materialId;
    }

    public void setMaterialId(int materialId) {
        this.materialId = materialId;
    }

    public String getMaterialName() {
        return materialName;
    }

    public void setMaterialName(String materialName) {
        this.materialName = materialName;
    }

    public String getMaterialCondition() {
        return materialCondition;
    }

    public void setMaterialCondition(String materialCondition) {
        this.materialCondition = materialCondition;
    }

    public double getQuantityInStock() {
        return quantityInStock;
    }

    public void setQuantityInStock(double quantityInStock) {
        this.quantityInStock = quantityInStock;
    }

    public Date getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(Date lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
}
