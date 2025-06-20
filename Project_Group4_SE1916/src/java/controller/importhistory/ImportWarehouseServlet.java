package controller.importhistory;

import Dal.DBContext;
import dao.ImportDAO;
import dao.MaterialCategoryDAO;
import dao.MaterialDAO;
import dao.SupplierDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.ImportDetail;
import model.ImportReceipt;
import model.Material;
import model.MaterialCategory;
import model.Supplier;

/**
 *
 * @author Admin
 */
public class ImportWarehouseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try (Connection conn = DBContext.getConnection()) {
            MaterialCategoryDAO categoryDAO = new MaterialCategoryDAO(conn);
            MaterialDAO materialDAO = new MaterialDAO(conn);
            SupplierDAO supplierDAO = new SupplierDAO(conn);

            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();
            List<MaterialCategory> childCategories = categoryDAO.getAllChildCategories();
            List<Material> materials = materialDAO.getAllMaterials();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();

            request.setAttribute("parentCategories", parentCategories);
            request.setAttribute("childCategories", childCategories);
            request.setAttribute("material", materials);
            request.setAttribute("suppliers", suppliers);
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Error fetching data: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String voucherId = request.getParameter("voucher_id");
        String importDateStr = request.getParameter("import_date");
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        Integer supplierId = request.getParameter("supplier_id") != null && !request.getParameter("supplier_id").equals("new")
                ? Integer.parseInt(request.getParameter("supplier_id")) : null;
        String newSupplierName = request.getParameter("new_supplier_name");
        String newSupplierPhone = request.getParameter("new_supplier_phone");
        String newSupplierAddress = request.getParameter("new_supplier_address");
        String newSupplierEmail = request.getParameter("new_supplier_email");
        String note = request.getParameter("note");
        String[] materialIds = request.getParameterValues("materialId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] prices = request.getParameterValues("price_per_unit[]");
        String[] materialConditions = request.getParameterValues("materialCondition[]");

        ImportReceipt receipt = new ImportReceipt();
        receipt.setVoucherId(voucherId);
        receipt.setUserId(userId);
        try {
            receipt.setImportDate(new java.sql.Date(new SimpleDateFormat("yyyy-MM-dd").parse(importDateStr).getTime()));
        } catch (ParseException ex) {
            Logger.getLogger(ImportWarehouseServlet.class.getName()).log(Level.SEVERE, null, ex);
            request.setAttribute("error", "Invalid date format.");
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            return;
        }
        receipt.setNote(note);

        if (supplierId == null && newSupplierName != null && !newSupplierName.isEmpty()) {
            Supplier newSupplier = new Supplier();
            newSupplier.setSupplierName(newSupplierName);
            newSupplier.setSupplierPhone(newSupplierPhone);
            newSupplier.setSupplierAddress(newSupplierAddress);
            newSupplier.setSupplierEmail(newSupplierEmail);
            newSupplier.setSupplierStatus("active");
            try (Connection conn = DBContext.getConnection()) {
                SupplierDAO supplierDAO = new SupplierDAO(conn);
                supplierId = supplierDAO.addSupplierWithId(newSupplier);
                if (supplierId <= 0) {
                    request.setAttribute("error", "Failed to add new supplier.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
            } catch (SQLException e) {
                request.setAttribute("error", "Error adding new supplier: " + e.getMessage());
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                return;
            }
            receipt.setSupplierId(supplierId);
        } else if (supplierId != null) {
            receipt.setSupplierId(supplierId);
        } else {
            request.setAttribute("error", "Supplier information is required.");
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            return;
        }

        List<ImportDetail> details = new ArrayList<>();
        if (materialIds == null || quantities == null || prices == null || materialConditions == null ||
                materialIds.length == 0 || quantities.length == 0 || prices.length == 0 || materialConditions.length == 0 ||
                materialIds.length != quantities.length || materialIds.length != prices.length || materialIds.length != materialConditions.length) {
            request.setAttribute("error", "Material details are inconsistent or empty.");
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            return;
        }

        for (int i = 0; i < materialIds.length; i++) {
            try {
                ImportDetail detail = new ImportDetail();
                detail.setMaterialId(Integer.parseInt(materialIds[i]));
                detail.setQuantity(Double.parseDouble(quantities[i]));
                detail.setPricePerUnit(Double.parseDouble(prices[i]));
                detail.setMaterialCondition(materialConditions[i]);
                if (detail.getQuantity() <= 0 || detail.getPricePerUnit() <= 0) {
                    request.setAttribute("error", "Quantity and price must be greater than 0 at row " + (i + 1));
                    request.setAttribute("errorRow", i);
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
                details.add(detail);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid number format at row " + (i + 1));
                request.setAttribute("errorRow", i);
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                return;
            }
        }

        try (Connection conn = DBContext.getConnection()) {
            ImportDAO importDAO = new ImportDAO(conn);
            if (importDAO.voucherIdExists(voucherId)) {
                request.setAttribute("error", "Voucher ID already exists");
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                return;
            }

            int importId = importDAO.saveImportReceipt(receipt, details);
            if (importId > 0) {
                request.setAttribute("message", "Import receipt saved successfully");
                request.setAttribute("success", "true");
                request.setAttribute("voucher_id", voucherId);
            } else {
                request.setAttribute("error", "Failed to save import receipt.");
            }
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Error saving import receipt: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles warehouse import operations";
    }
}