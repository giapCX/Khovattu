
/**
 *
 * @author ASUS
 */
package dao;

import Dal.DBContext;
import model.Export;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;

import java.util.List;

import model.Export;
public class ExportHistoryDAO {
    private Connection conn;

    public ExportHistoryDAO() {
        this.conn = DBContext.getConnection();
    }

    public List<Export> searchExportReceipts(Date fromDate, Date toDate, String exporter, int page, int pageSize) {
        List<Export> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT er.export_id, er.voucher_id, er.export_date, er.note, u.full_name AS exporter_name, " +
            "SUM(ed.quantity * ed.price_per_unit) AS total " +
            "FROM ExportReceipts er " +
            "JOIN Users u ON er.user_id = u.user_id " +
            "JOIN ExportDetails ed ON er.export_id = ed.export_id " +
            "WHERE 1=1 "
        );

        if (fromDate != null) sql.append("AND er.export_date >= ? ");
        if (toDate != null) sql.append("AND er.export_date <= ? ");
        if (exporter != null && !exporter.isEmpty()) sql.append("AND u.full_name LIKE ? ");

        sql.append("GROUP BY er.export_id, er.voucher_id, er.export_date, er.note, u.full_name ");
        sql.append("ORDER BY er.export_date DESC ");
        sql.append("LIMIT ? OFFSET ?");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (fromDate != null) ps.setDate(index++, fromDate);
            if (toDate != null) ps.setDate(index++, toDate);
            if (exporter != null && !exporter.isEmpty()) ps.setString(index++, "%" + exporter + "%");
            ps.setInt(index++, pageSize);
            ps.setInt(index, (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Export receipt = new Export();
                receipt.setExportId(rs.getInt("export_id"));
                receipt.setVoucherId(rs.getString("voucher_id"));
                receipt.setExportDate(LocalDate.now());
                receipt.setNote(rs.getString("note"));
                receipt.setExporterName(rs.getString("exporter_name"));
                list.add(receipt);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countExportReceipts(Date fromDate, Date toDate, String exporter) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT er.export_id) " +
            "FROM ExportReceipts er " +
            "JOIN Users u ON er.user_id = u.user_id " +
            "WHERE 1=1 "
        );

        if (fromDate != null) sql.append("AND er.export_date >= ? ");
        if (toDate != null) sql.append("AND er.export_date <= ? ");
        if (exporter != null && !exporter.isEmpty()) sql.append("AND u.full_name LIKE ? ");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (fromDate != null) ps.setDate(index++, fromDate);
            if (toDate != null) ps.setDate(index++, toDate);
            if (exporter != null && !exporter.isEmpty()) ps.setString(index++, "%" + exporter + "%");

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    
}
