
package controller;

import dao.ImportDAO;
import dao.MaterialDAO;
import dao.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.ImportReceipt;
import model.ImportDetail;
import model.Supplier;
import Dal.DBContext;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.Date;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet(name = "ImportDataController", urlPatterns = {"/ImportDataController"})
@MultipartConfig
public class ImportDataController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ImportDataController.class.getName());
    private SupplierDAO supplierDAO;
    private MaterialDAO materialDAO;
    private ImportDAO importDAO;

    @Override
    public void init() throws ServletException {
        supplierDAO = new SupplierDAO();
        materialDAO = new MaterialDAO();
        importDAO = new ImportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Supplier> suppliers = supplierDAO.getSuppliers();
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("today", new Date(System.currentTimeMillis()).toString());
        request.getRequestDispatcher("/view/import/importData.jsp").forward(request, response);
    }

 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        List<ImportDetail> details = new ArrayList<>();
        ImportReceipt receipt = new ImportReceipt();
        Connection conn = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // Handle new supplier
            String supplierIdStr = request.getParameter("supplier_id");
            int supplierId;
            if ("new".equals(supplierIdStr)) {
                Supplier newSupplier = new Supplier();
                newSupplier.setSupplierName(request.getParameter("new_supplier_name"));
                newSupplier.setSupplierPhone(request.getParameter("new_supplier_phone"));
                newSupplier.setSupplierAddress(request.getParameter("new_supplier_address"));
                newSupplier.setSupplierEmail(request.getParameter("new_supplier_email"));
                newSupplier.setSupplierStatus("active");

                if (newSupplier.getSupplierName() == null || newSupplier.getSupplierName().trim().isEmpty()) {
                    throw new IllegalArgumentException("Tên nhà cung cấp mới không được để trống.");
                }

                // Kiểm tra trùng lặp tên
                if (new SupplierDAO(conn).supplierExistsByName(newSupplier.getSupplierName())) {
                    throw new IllegalArgumentException("Nhà cung cấp với tên này đã tồn tại. Vui lòng chọn nhà cung cấp khác hoặc nhập tên khác.");
                }

                // Thêm nhà cung cấp mới và lấy supplierId
                supplierId = new SupplierDAO(conn).addSupplierWithId(newSupplier); // Sử dụng addSupplierWithId
            } else {
                supplierId = Integer.parseInt(supplierIdStr);
                if (!new SupplierDAO(conn).supplierExists(supplierId)) {
                    throw new IllegalArgumentException("Nhà cung cấp không tồn tại.");
                }
            }

            // ... (Phần còn lại giữ nguyên)
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ: " + e.getMessage());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error", e);
            request.setAttribute("error", "Lỗi khi lưu dữ liệu: " + e.getMessage());
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Rollback error", ex);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error", e);
            request.setAttribute("error", "Lỗi không xác định: " + e.getMessage());
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error resetting auto-commit", e);
            }
        }

        request.setAttribute("suppliers", new SupplierDAO(conn).getSuppliers());
        request.setAttribute("today", new Date(System.currentTimeMillis()).toString());

        request.getRequestDispatcher("importData.jsp").forward(request, response);
    }
}
