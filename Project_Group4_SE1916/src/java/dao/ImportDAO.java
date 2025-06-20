package dao;

import model.Import;
import model.ImportDetail;
import Dal.DBContext;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import model.ImportReceipt;

public class ImportDAO {
    private Connection conn;

    public ImportDAO() {
        this.conn = DBContext.getConnection();
    }

    public ImportDAO(Connection conn) {
        this.conn = conn;
    }

    public int saveImport(ImportReceipt importReceipt, List<ImportDetail> details) throws SQLException {
    String sql = "INSERT INTO ImportReceipts (voucher_id, user_id, import_date, note, supplier_id) VALUES (?, ?, ?, ?, ?)"; 
    String generatedColumns[] = {"import_id"};
    try (Connection conn = DBContext.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql, generatedColumns)) {
        pstmt.setString(1, importReceipt.getVoucherId());
        pstmt.setInt(2, importReceipt.getUserId());
        pstmt.setDate(3, importReceipt.getImportDate());
        pstmt.setString(4, importReceipt.getNote());
        pstmt.setInt(5, importReceipt.getSupplierId());
        pstmt.executeUpdate();

        // Lấy ID vừa tạo
        ResultSet rs = pstmt.getGeneratedKeys();
        int importId = 0;
        if (rs.next()) {
            importId = rs.getInt(1);
        }

        // Lưu chi tiết
        if (importId > 0 && details != null) {
            String detailSql = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition, material_code, material_name, unit, supplier_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement detailPstmt = conn.prepareStatement(detailSql)) {
                for (ImportDetail detail : details) {
                    detailPstmt.setInt(1, importId);
                    detailPstmt.setInt(2, detail.getMaterialId());
                    detailPstmt.setDouble(3, detail.getQuantity());
                    detailPstmt.setDouble(4, detail.getPricePerUnit());
                    detailPstmt.setString(5, detail.getMaterialCondition());
                    detailPstmt.setString(6, detail.getMaterialCode());
                    detailPstmt.setString(7, detail.getMaterialName());
                    detailPstmt.setString(8, detail.getUnit());
                    detailPstmt.setInt(9, detail.getSupplierId());
                    detailPstmt.addBatch();
                }
                detailPstmt.executeBatch();
            }
        }
        return importId;
    }
}

    public boolean voucherIdExists(String voucherId) throws SQLException {
        String sql = "SELECT 1 FROM ImportReceipts WHERE LOWER(voucher_id) = LOWER(?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, voucherId);
            try (ResultSet rs = ps.executeQuery()) {
                boolean exists = rs.next();
                System.out.println("ImportDAO: Checking voucherId " + voucherId + " exists: " + exists);
                return exists;
            }
        } catch (SQLException e) {
            System.err.println("ImportDAO: SQLException in voucherIdExists: " + e.getMessage());
            throw e;
        }
    }
}