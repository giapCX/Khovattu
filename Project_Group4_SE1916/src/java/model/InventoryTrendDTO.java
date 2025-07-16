package model;

import java.math.BigDecimal;

public class InventoryTrendDTO {
    private int month;
    private BigDecimal imported;
    private BigDecimal exported;
    private BigDecimal remaining;

    public InventoryTrendDTO(int month, BigDecimal imported, BigDecimal exported, BigDecimal remaining) {
        this.month = month;
        this.imported = imported;
        this.exported = exported;
        this.remaining = remaining;
    }

    public int getMonth() {
        return month;
    }

    public BigDecimal getImported() {
        return imported;
    }

    public BigDecimal getExported() {
        return exported;
    }

    public BigDecimal getRemaining() {
        return remaining;
    }
}
