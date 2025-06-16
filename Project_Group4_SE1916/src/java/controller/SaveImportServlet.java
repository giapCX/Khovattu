package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import Dal.DBContext;


public class SaveImportServlet extends HttpServlet {
    private static final String INSERT_RECEIPT_SQL = "INSERT INTO ImportReceipts (voucher_id, supplier_id, user_id, import_date, note) VALUES (?, ?, ?, ?, ?)";
    private static final String INSERT_SUPPLIER_SQL = "INSERT INTO Suppliers (name, phone, address, email, status) VALUES (?, ?, ?, ?, 'active') ON DUPLICATE KEY UPDATE phone = VALUES(phone), address = VALUES(address), email = VALUES(email), status = VALUES(status)";
    private static final String SELECT_SUPPLIER_ID = "SELECT supplier_id FROM Suppliers WHERE name = ? AND phone = ? AND address = ? AND email = ? LIMIT 1";
    private static final String INSERT_MATERIAL_SQL = "INSERT INTO Materials (code, category_id, name, unit) VALUES (?, 1, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name), unit = VALUES(unit)"; // Giả định category_id = 1
    private static final String SELECT_MATERIAL_ID = "SELECT material_id FROM Materials WHERE code = ? LIMIT 1";
    private static final String INSERT_DETAIL_SQL = "INSERT INTO ImportDetails (import_id, material_id, quantity, price_per_unit, material_condition) VALUES (?, ?, ?, ?, ?)";
    private static final String UPDATE_INVENTORY_SQL = "INSERT INTO Inventory (material_id, material_condition, quantity_in_stock, last_updated) VALUES (?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE quantity_in_stock = quantity_in_stock + VALUES(quantity_in_stock), last_updated = NOW()";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            String voucherId = request.getParameter("voucher_id");
            String importDate = request.getParameter("import_date");
            String userId = request.getParameter("user_id");
            String supplierName = request.getParameter("supplier_name");
            String supplierPhone = request.getParameter("supplier_phone");
            String supplierAddress = request.getParameter("supplier_address");
            String supplierEmail = request.getParameter("supplier_email");
            String note = request.getParameter("note");

            // Lấy hoặc thêm nhà cung cấp
            Integer supplierId = getOrInsertSupplier(conn, supplierName, supplierPhone, supplierAddress, supplierEmail);

            // Thêm phiếu nhập
            PreparedStatement pstmtReceipt = conn.prepareStatement(INSERT_RECEIPT_SQL, PreparedStatement.RETURN_GENERATED_KEYS);
            pstmtReceipt.setString(1, voucherId);
            pstmtReceipt.setInt(2, supplierId != null ? supplierId : 0);
            pstmtReceipt.setString(3, userId.isEmpty() ? null : userId);
            pstmtReceipt.setString(4, importDate);
            pstmtReceipt.setString(5, note);
            pstmtReceipt.executeUpdate();

            ResultSet rs = pstmtReceipt.getGeneratedKeys();
            int importId = 0;
            if (rs.next()) {
                importId = rs.getInt(1);
            }

            // Xử lý chi tiết hàng nhập
            String[] materialNames = request.getParameterValues("material_name[]");
            String[] materialCodes = request.getParameterValues("material_code[]");
            String[] units = request.getParameterValues("unit[]");
            String[] quantities = request.getParameterValues("quantity[]");
            String[] prices = request.getParameterValues("price_per_unit[]");
            String[] conditions = request.getParameterValues("material_condition[]");

            PreparedStatement pstmtDetail = conn.prepareStatement(INSERT_DETAIL_SQL);
            PreparedStatement pstmtInventory = conn.prepareStatement(UPDATE_INVENTORY_SQL);

            for (int i = 0; i < materialNames.length; i++) {
                Integer materialId = getOrInsertMaterial(conn, materialCodes[i], materialNames[i], units[i]);
                double quantity = Double.parseDouble(quantities[i]);
                double price = Double.parseDouble(prices[i]);
                String condition = conditions[i];

                // Thêm chi tiết nhập kho
                pstmtDetail.setInt(1, importId);
                pstmtDetail.setInt(2, materialId);
                pstmtDetail.setDouble(3, quantity);
                pstmtDetail.setDouble(4, price);
                pstmtDetail.setString(5, condition);
                pstmtDetail.addBatch();

                // Cập nhật tồn kho
                pstmtInventory.setInt(1, materialId);
                pstmtInventory.setString(2, condition);
                pstmtInventory.setDouble(3, quantity);
                pstmtInventory.addBatch();
            }

            pstmtDetail.executeBatch();
            pstmtInventory.executeBatch();

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/view/warehouse/importData.jsp?success=true&voucher_id=" + voucherId);
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            request.setAttribute("error", "Lỗi khi lưu dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private Integer getOrInsertSupplier(Connection conn, String name, String phone, String address, String email) throws SQLException {
        PreparedStatement pstmt = conn.prepareStatement(SELECT_SUPPLIER_ID);
        pstmt.setString(1, name);
        pstmt.setString(2, phone);
        pstmt.setString(3, address);
        pstmt.setString(4, email);
        ResultSet rs = pstmt.executeQuery();
        if (rs.next()) {
            return rs.getInt("supplier_id");
        }

        PreparedStatement pstmtInsert = conn.prepareStatement(INSERT_SUPPLIER_SQL, PreparedStatement.RETURN_GENERATED_KEYS);
        pstmtInsert.setString(1, name);
        pstmtInsert.setString(2, phone);
        pstmtInsert.setString(3, address);
        pstmtInsert.setString(4, email);
        pstmtInsert.executeUpdate();
        rs = pstmtInsert.getGeneratedKeys();
        if (rs.next()) {
            return rs.getInt(1);
        }
        return null;
    }

    private Integer getOrInsertMaterial(Connection conn, String code, String name, String unit) throws SQLException {
        PreparedStatement pstmtSelect = conn.prepareStatement(SELECT_MATERIAL_ID);
        pstmtSelect.setString(1, code);
        ResultSet rs = pstmtSelect.executeQuery();
        if (rs.next()) {
            return rs.getInt("material_id");
        }

        PreparedStatement pstmtInsert = conn.prepareStatement(INSERT_MATERIAL_SQL, PreparedStatement.RETURN_GENERATED_KEYS);
        pstmtInsert.setString(1, code);
        pstmtInsert.setString(2, name);
        pstmtInsert.setString(3, unit);
        pstmtInsert.executeUpdate();
        rs = pstmtInsert.getGeneratedKeys();
        if (rs.next()) {
            return rs.getInt(1);
        }
        return null;
    }
}