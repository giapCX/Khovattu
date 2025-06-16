/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Dal.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.sql.Date;
import java.util.List;
import model.ImportReceipt;

public class ImportReceiptDAO {
    private Connection conn;

    public ImportReceiptDAO() {
        this.conn = DBContext.getConnection();
    }

    public List<ImportReceipt> searchImportReceipts(Date fromDate, Date toDate, String importer, int page, int pageSize) {
    List<ImportReceipt> list = new ArrayList<>();
    StringBuilder sql = new StringBuilder(
            "SELECT ir.import_id, ir.voucher_id, ir.import_date, ir.note, u.full_name AS importer_name, " +
                    "SUM(id.quantity * id.price_per_unit) AS total " +
                    "FROM ImportReceipts ir " +
                    "JOIN Users u ON ir.user_id = u.user_id " +
                    "JOIN ImportDetails id ON ir.import_id = id.import_id " +
                    "WHERE 1=1 "
    );

    if (fromDate != null) sql.append("AND ir.import_date >= ? ");
    if (toDate != null) sql.append("AND ir.import_date <= ? ");
    if (importer != null && !importer.isEmpty()) sql.append("AND u.full_name LIKE ? ");

    sql.append("GROUP BY ir.import_id, ir.voucher_id, ir.import_date, ir.note, u.full_name ");
    sql.append("ORDER BY ir.import_date DESC ");
    sql.append("LIMIT ? OFFSET ?");

    try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
        int index = 1;
        if (fromDate != null) ps.setDate(index++, fromDate);
        if (toDate != null) ps.setDate(index++, toDate);
        if (importer != null && !importer.isEmpty()) ps.setString(index++, "%" + importer + "%");
        ps.setInt(index++, pageSize);
        ps.setInt(index, (page - 1) * pageSize);

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            ImportReceipt receipt = new ImportReceipt();
            receipt.setImportId(rs.getInt("import_id"));
            receipt.setVoucherId(rs.getString("voucher_id"));
            receipt.setImportDate(rs.getDate("import_date"));
            receipt.setNote(rs.getString("note"));
            receipt.setImporterName(rs.getString("importer_name"));
            receipt.setTotal(rs.getDouble("total"));
            list.add(receipt);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    return list;
}


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

    try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
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
public ImportReceipt getReceiptById(int importId) {
    ImportReceipt receipt = null;
    String sql = """
        SELECT ir.import_id, ir.voucher_id, ir.import_date, ir.note,
               ir.user_id, u.full_name AS importer_name,
               ir.supplier_id, s.name AS supplier_name,
               SUM(idt.quantity * idt.price_per_unit) AS total
        FROM ImportReceipts ir
        LEFT JOIN Users u ON ir.user_id = u.user_id
        LEFT JOIN Suppliers s ON ir.supplier_id = s.supplier_id
        LEFT JOIN ImportDetails idt ON ir.import_id = idt.import_id
        WHERE ir.import_id = ?
        GROUP BY ir.import_id, ir.voucher_id, ir.import_date, ir.note,
                 ir.user_id, u.full_name, ir.supplier_id, s.name
    """;

    try (Connection con = DBContext.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, importId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                receipt = new ImportReceipt();
                receipt.setImportId(rs.getInt("import_id"));
                receipt.setVoucherId(rs.getString("voucher_id"));
                receipt.setImportDate(rs.getDate("import_date"));
                receipt.setNote(rs.getString("note"));
                receipt.setUserId(rs.getInt("user_id"));
                receipt.setImporterName(rs.getString("importer_name"));
                receipt.setSupplierId(rs.getInt("supplier_id"));
                receipt.setSupplierName(rs.getString("supplier_name"));
                receipt.setTotal(rs.getDouble("total"));
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }
    return receipt;
}
}

