package dao;

import model.ImportReceipt;
import model.ImportDetail;
import Dal.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public class ImportDAO {
    private Connection conn;
    private SupplierDAO supplierDAO;
    private MaterialDAO materialDAO;

    public ImportDAO() {
        this.conn = DBContext.getConnection();
        this.supplierDAO = new SupplierDAO(conn);
        this.materialDAO = new MaterialDAO();
    }

    public ImportDAO(Connection conn) {
        this.conn = conn;
        this.supplierDAO = new SupplierDAO(conn);
        this.materialDAO = new MaterialDAO();
    }

    public int saveImport(ImportReceipt importReceipt, List<ImportDetail> details) throws SQLException {
        // Validate import date (within ±7 days from today)
        LocalDate today = LocalDate.now();
        LocalDate importDate = importReceipt.getImportDate().toLocalDate();
        if (importDate.isBefore(today.minusDays(7)) || importDate.isAfter(today.plusDays(7))) {
            throw new SQLException("Ngày nhập kho phải nằm trong khoảng ±7 ngày từ hôm nay");
        }

        // Generate receipt_id
        String receiptId = generateReceiptId();
        importReceipt.setReceiptId(receiptId);

        // Validate supplier-material relationship for from_supplier imports
        if ("import_from_supplier".equals(importReceipt.getImportType())) {
            for (ImportDetail detail : details) {
                if (detail.getSupplierId() > 0 && detail.getMaterialId() > 0) {
                    if (!supplierDAO.isMaterialAlreadyExists(detail.getSupplierId(), detail.getMaterialId())) {
                        supplierDAO.addMaterialsToSupplier(detail.getSupplierId(), List.of(detail.getMaterialId()));
                    }
                }
            }
        }

        String sql = "INSERT INTO ImportReceipts (receipt_id, proposal_id, import_type, site_id, returned_site_id, user_id, executor_id, import_date, note, supplier_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String[] generatedColumns = {"import_id"};
        conn.setAutoCommit(false);
        try {
            try (PreparedStatement pstmt = conn.prepareStatement(sql, generatedColumns)) {
                pstmt.setString(1, importReceipt.getReceiptId());
                pstmt.setObject(2, importReceipt.getProposalId() > 0 ? importReceipt.getProposalId() : null);
                pstmt.setString(3, importReceipt.getImportType());
                pstmt.setObject(4, importReceipt.getSiteId());
                pstmt.setObject(5, importReceipt.getReturnedSiteId());
                pstmt.setInt(6, importReceipt.getUserId());
                pstmt.setObject(7, importReceipt.getExecutorId());
                pstmt.setDate(8, new java.sql.Date(importReceipt.getImportDate().getTime()));
                pstmt.setString(9, importReceipt.getNote());
                pstmt.setObject(10, importReceipt.getSupplierId());
                pstmt.executeUpdate();

                ResultSet rs = pstmt.getGeneratedKeys();
                int importId = 0;
                if (rs.next()) {
                    importId = rs.getInt(1);
                }

                if (importId > 0 && details != null && !details.isEmpty()) {
                    String detailSql = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition, supplier_id) VALUES (?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement detailPstmt = conn.prepareStatement(detailSql)) {
                        for (ImportDetail detail : details) {
                            detailPstmt.setInt(1, importId);
                            detailPstmt.setInt(2, detail.getMaterialId());
                            detailPstmt.setDouble(3, detail.getQuantity());
                            detailPstmt.setDouble(4, detail.getPricePerUnit());
                            detailPstmt.setString(5, detail.getMaterialCondition());
                            detailPstmt.setObject(6, "import_from_supplier".equals(importReceipt.getImportType()) ? detail.getSupplierId() : null);
                            detailPstmt.addBatch();
                        }
                        detailPstmt.executeBatch();
                    }
                    // Update inventory
                    materialDAO.updateInventoryFromImport(details);
                }

                conn.commit();
                return importId;
            }
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    public boolean receiptIdExists(String receiptId) throws SQLException {
        String sql = "SELECT 1 FROM ImportReceipts WHERE LOWER(receipt_id) = LOWER(?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String generateReceiptId() throws SQLException {
        String prefix = "IMP-" + LocalDate.now().toString().replace("-", "");
        int sequence = 1;
        String receiptId;

        do {
            receiptId = String.format("%s-%04d", prefix, sequence);
            sequence++;
        } while (receiptIdExists(receiptId));

        return receiptId;
    }
}