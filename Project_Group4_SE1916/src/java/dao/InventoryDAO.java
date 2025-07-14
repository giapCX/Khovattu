package dao;

import model.Inventory;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventoryDAO {
    private Connection conn;

    public InventoryDAO(Connection conn) {
        this.conn = conn;
    }

    public InventoryDAO() {
    }
    
    

    public List<Inventory> getAllInventory() throws SQLException {
        List<Inventory> list = new ArrayList<>();
        String sql = "SELECT * FROM Inventory";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Inventory inv = new Inventory();
                inv.setMaterialId(rs.getInt("material_id"));
                inv.setMaterialCondition(rs.getString("material_condition"));
                inv.setQuantityInStock(rs.getDouble("quantity_in_stock"));
                inv.setLastUpdated(rs.getString("last_updated"));
                list.add(inv);
            }
        }
        return list;
    }


}
