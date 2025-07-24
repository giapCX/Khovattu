/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Dal.DBContext;
import static Dal.DBContext.getConnection;
import java.sql.*;
import java.util.ArrayList;
import java.sql.Date;
import java.util.List;
import model.ImportDetail;
import model.ImportReceipt;

public class ImportReceiptDAO {
    private Connection connection;

    public ImportReceiptDAO() {
        this.connection = getConnection();
    }

//    public List<ImportReceipt> searchImportReceipts(Date fromDate, Date toDate, String importer, int page, int pageSize) {
//    List<ImportReceipt> list = new ArrayList<>();
//    StringBuilder sql = new StringBuilder(
//            "SELECT ir.import_id, ir.receipt_id, ir.import_date, ir.note, u.full_name AS importer_name, " +
//                    "SUM(id.quantity * id.price_per_unit) AS total " +
//                    "FROM ImportReceipts ir " +
//                    "JOIN Users u ON ir.user_id = u.user_id " +
//                    "JOIN ImportDetails id ON ir.import_id = id.import_id " +
//                    "WHERE 1=1 "
//    );
//
//    if (fromDate != null) sql.append("AND ir.import_date >= ? ");
//    if (toDate != null) sql.append("AND ir.import_date <= ? ");
//    if (importer != null && !importer.isEmpty()) sql.append("AND u.full_name LIKE ? ");
//
//    sql.append("GROUP BY ir.import_id, ir.receipt_id, ir.import_date, ir.note, u.full_name ");
//    sql.append("ORDER BY ir.import_date DESC ");
//    sql.append("LIMIT ? OFFSET ?");
//
//    try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
//        int index = 1;
//        if (fromDate != null) ps.setDate(index++, fromDate);
//        if (toDate != null) ps.setDate(index++, toDate);
//        if (importer != null && !importer.isEmpty()) ps.setString(index++, "%" + importer + "%");
//        ps.setInt(index++, pageSize);
//        ps.setInt(index, (page - 1) * pageSize);
//
//        ResultSet rs = ps.executeQuery();
//        while (rs.next()) {
//            ImportReceipt receipt = new ImportReceipt();
//            receipt.setImportId(rs.getInt("import_id"));
//            receipt.setReceiptId(rs.getString("receipt_id"));
//            receipt.setImportDate(rs.getDate("import_date"));
//            receipt.setNote(rs.getString("note"));
//            receipt.setImporterName(rs.getString("importer_name"));
//            receipt.setTotal(rs.getDouble("total"));
//            list.add(receipt);
//        }
//    } catch (SQLException e) {
//        e.printStackTrace();
//    }
//
//    return list;
//}


    public int countImportReceipts(Date fromDate, Date toDate, String importer) {
    StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT ir.import_id) " +
                    "FROM ImportReceipts ir " +
                    "JOIN Users u ON ir.user_id = u.user_id " +
                    "WHERE 1=1 "
    );

    if (fromDate != null) sql.append("AND ir.import_date >= ? ");
    if (toDate != null) sql.append("AND ir.import_date <= ? ");
    if (importer != null && !importer.isEmpty()) sql.append("AND u.full_name LIKE ? ");

    try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
        int index = 1;
        if (fromDate != null) ps.setDate(index++, fromDate);
        if (toDate != null) ps.setDate(index++, toDate);
        if (importer != null && !importer.isEmpty()) ps.setString(index++, "%" + importer + "%");

        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    return 0;
}
public ImportReceipt getImportReceiptById(int importId) {
        ImportReceipt receipt = null;
        String sql = """
            SELECT ir.*, 
                   u.full_name AS executor_name,
                   s.site_name,
                   sp.name AS supplier_name
            FROM ImportReceipts ir
            LEFT JOIN Users u ON ir.executor_id = u.user_id
            LEFT JOIN ConstructionSites s ON ir.site_id = s.site_id
            LEFT JOIN Suppliers sp ON ir.supplier_id = sp.supplier_id
            WHERE ir.import_id = ?
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, importId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    receipt = new ImportReceipt();
                    receipt.setImportId(rs.getInt("import_id"));
                    receipt.setProposalId(rs.getInt("proposal_id"));
                    receipt.setImportType(rs.getString("import_type"));
                    receipt.setResponsibleId(rs.getInt("responsible_id"));
                    receipt.setDeliverySupplierName(rs.getString("delivery_supplier_name"));
                    receipt.setDeliverySupplierPhone(rs.getString("delivery_supplier_phone"));
                    receipt.setExecutorId(rs.getInt("executor_id"));
                    receipt.setImportDate(rs.getDate("import_date"));
                    receipt.setNote(rs.getString("note"));
                    receipt.setSiteId(rs.getInt("site_id"));
                    receipt.setSupplierId(rs.getInt("supplier_id"));

                    // Extra info
                    receipt.setExecutorName(rs.getString("executor_name"));
                    receipt.setSiteName(rs.getString("site_name"));
                    receipt.setSupplierName(rs.getString("supplier_name"));

                    // Load import details
                    receipt.setDetails(getImportDetails(importId));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return receipt;
    }

    public List<ImportDetail> getImportDetails(int importId) {
        List<ImportDetail> details = new ArrayList<>();
        String sql = "SELECT id.import_id, id.material_id, id.quantity, id.price_per_unit, " +
                     "id.material_condition, id.supplier_id, id.site_id, " +
                     "m.name AS material_name, m.unit " +
                     "FROM ImportDetails id " +
                     "JOIN Materials m ON id.material_id = m.material_id " +
                     "WHERE id.import_id = ?";
        try (
            PreparedStatement ps = connection.prepareStatement(sql)
        ) {
            ps.setInt(1, importId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ImportDetail detail = new ImportDetail();
                detail.setImportId(rs.getInt("import_id"));
                detail.setMaterialId(rs.getInt("material_id"));
                detail.setQuantity(rs.getDouble("quantity"));
                detail.setPrice(rs.getDouble("price_per_unit"));
                detail.setMaterialCondition(rs.getString("material_condition"));
                detail.setSupplierId(rs.getInt("supplier_id"));
                
                int siteId = rs.getInt("site_id");
                if (!rs.wasNull()) {
                    detail.setSiteId(siteId);
                }

                detail.setMaterialName(rs.getString("material_name"));
                detail.setUnit(rs.getString("unit"));

                details.add(detail);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return details;
    }

}

