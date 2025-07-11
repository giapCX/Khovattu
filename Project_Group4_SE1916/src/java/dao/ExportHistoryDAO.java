//exHisDAO
/**
 * ExportHistoryDAO.java
 * Data Access Object for handling export history operations
 */
package dao;

import Dal.DBContext;
import model.Export;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;

public class ExportHistoryDAO {

    private Connection conn;

    public ExportHistoryDAO(Connection conn) {
        this.conn = conn;
    }

    public ExportHistoryDAO() {
        this.conn = DBContext.getConnection();
    }

    public List<Export> searchExportReceipts(Date fromDate, Date toDate, String exporter, int page, int pageSize) {
        List<Export> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT er.export_id, er.receipt_id, er.export_date, er.note, "
                + "u1.full_name AS exporter_name, u2.full_name AS receiver_name, "
                + "er.exporter_id, er.receiver_id "
                + "FROM ExportReceipts er "
                + "JOIN Users u1 ON er.exporter_id = u1.user_id "
                + "JOIN Users u2 ON er.receiver_id = u2.user_id "
                + "LEFT JOIN ExportDetails ed ON er.export_id = ed.export_id "
                + "WHERE 1=1 "
        );

        if (fromDate != null) {
            sql.append("AND er.export_date >= ? ");
        }
        if (toDate != null) {
            sql.append("AND er.export_date <= ? ");
        }
        if (exporter != null && !exporter.trim().isEmpty()) {
            sql.append("AND u1.full_name LIKE ? ");
        }

        sql.append("ORDER BY er.export_date DESC ");

        // Only apply LIMIT and OFFSET if pageSize > 0
        if (pageSize > 0) {
            sql.append("LIMIT ? OFFSET ?");
        }

        // Debug SQL
        System.out.println("SQL Query: " + sql);
        System.out.println("Parameters: fromDate=" + fromDate + ", toDate=" + toDate + ", exporter=" + exporter + ", page=" + page + ", pageSize=" + pageSize);

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (fromDate != null) {
                ps.setDate(index++, fromDate);
            }
            if (toDate != null) {
                ps.setDate(index++, toDate);
            }
            if (exporter != null && !exporter.trim().isEmpty()) {
                ps.setString(index++, "%" + exporter + "%");
            }
            if (pageSize > 0) {
                ps.setInt(index++, pageSize);
                ps.setInt(index++, (page - 1) * pageSize);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Export receipt = new Export();
                receipt.setExportId(rs.getInt("export_id"));
                receipt.setReceiptId(rs.getString("receipt_id"));
                receipt.setExportDate(rs.getDate("export_date").toLocalDate());
                receipt.setNote(rs.getString("note"));
                receipt.setExporterId(rs.getInt("exporter_id"));
                receipt.setReceiverId(rs.getInt("receiver_id"));
                receipt.setExporterName(rs.getString("exporter_name"));
                receipt.setReceiverName(rs.getString("receiver_name"));
                list.add(receipt);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countExportReceipts(Date fromDate, Date toDate, String exporter) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT er.export_id) "
                + "FROM ExportReceipts er "
                + "JOIN Users u1 ON er.exporter_id = u1.user_id "
                + "WHERE 1=1"
        );

        if (fromDate != null) {
            sql.append(" AND er.export_date >= ? ");
        }
        if (toDate != null) {
            sql.append(" AND er.export_date <= ? ");
        }
        if (exporter != null && !exporter.trim().isEmpty()) {
            sql.append(" AND u1.full_name LIKE ? ");
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (fromDate != null) {
                ps.setDate(index++, fromDate);
            }
            if (toDate != null) {
                ps.setDate(index++, toDate);
            }
            if (exporter != null && !exporter.trim().isEmpty()) {
                ps.setString(index++, "%" + exporter.trim() + "%");
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<Export> searchByExporterName(String exporter) {
        List<Export> list = new ArrayList<>();
        String sql = "SELECT er.export_id, er.receipt_id, er.export_date, er.note, "
                + "u1.full_name AS exporter_name, u2.full_name AS receiver_name, "
                + "er.exporter_id, er.receiver_id "
                + "FROM ExportReceipts er "
                + "JOIN Users u1 ON er.exporter_id = u1.user_id "
                + "JOIN Users u2 ON er.receiver_id = u2.user_id "
                + "JOIN ExportDetails ed ON er.export_id = ed.export_id "
                + "WHERE u1.full_name LIKE ? "
                + "GROUP BY er.export_id, er.receipt_id, er.export_date, er.note, u1.full_name, u2.full_name, er.exporter_id, er.receiver_id "
                + "ORDER BY er.export_date DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + exporter + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Export receipt = new Export();
                receipt.setExportId(rs.getInt("export_id"));
                receipt.setReceiptId(rs.getString("receipt_id"));
                receipt.setExportDate(rs.getDate("export_date").toLocalDate());
                receipt.setNote(rs.getString("note"));
                receipt.setExporterId(rs.getInt("exporter_id"));
                receipt.setReceiverId(rs.getInt("receiver_id"));
                receipt.setExporterName(rs.getString("exporter_name"));
                receipt.setReceiverName(rs.getString("receiver_name"));
                list.add(receipt);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Export getReceiptById(int exportId) {
        Export receipt = null;
        String sql = """
            SELECT 
                er.export_id, 
                er.receipt_id, 
                er.export_date, 
                er.note, 
                u1.full_name AS exporter_name,
                u2.full_name AS receiver_name,
                er.exporter_id,
                er.receiver_id
            FROM ExportReceipts er
            JOIN Users u1 ON er.exporter_id = u1.user_id
            JOIN Users u2 ON er.receiver_id = u2.user_id
            WHERE er.export_id = ?
        """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, exportId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                receipt = new Export();
                receipt.setExportId(rs.getInt("export_id"));
                receipt.setReceiptId(rs.getString("receipt_id"));
                receipt.setExportDate(rs.getDate("export_date").toLocalDate());
                receipt.setNote(rs.getString("note"));
                receipt.setExporterId(rs.getInt("exporter_id"));
                receipt.setReceiverId(rs.getInt("receiver_id"));
                receipt.setExporterName(rs.getString("exporter_name"));
                receipt.setReceiverName(rs.getString("receiver_name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return receipt;
    }
}
