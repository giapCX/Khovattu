package controller.importhistory;

import Dal.DBContext;
import com.google.gson.Gson;
import dao.ImportDAO;
import dao.MaterialCategoryDAO;
import dao.MaterialDAO;
import dao.SupplierDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
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
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            
            MaterialDAO materialDAO = new MaterialDAO();
            List<Material> materials = materialDAO.getAllMaterials();
            Gson gson = new Gson();
            String json = gson.toJson(materials);
            out.print(json);
            out.flush();
        } catch (SQLException e) {
            
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error: " + e.getMessage() + "\"}");
        }
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String errorMessage = null;
        Integer errorRow = null; // To store the index of the invalid row

        // Get input parameters
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String voucherId = request.getParameter("voucher_id");
        String importDateStr = request.getParameter("import_date");
        String[] materialIds = request.getParameterValues("materialId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] prices = request.getParameterValues("price_per_unit[]");
        String[] materialConditions = request.getParameterValues("materialCondition[]");
        Integer supplierId = request.getParameter("supplier_id") != null && !request.getParameter("supplier_id").equals("new")
                ? Integer.parseInt(request.getParameter("supplier_id")) : null;
        String newSupplierName = request.getParameter("new_supplier_name");
        String newSupplierPhone = request.getParameter("new_supplier_phone");
        String newSupplierAddress = request.getParameter("new_supplier_address");
        String newSupplierEmail = request.getParameter("new_supplier_email");
        String note = request.getParameter("note");

        // Validate inputs for null or empty
        if (voucherId == null || voucherId.trim().isEmpty()) {
            errorMessage = "Voucher ID cannot be empty.";
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (importDateStr == null || importDateStr.trim().isEmpty()) {
            errorMessage = "Import date cannot be empty.";
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (materialIds == null || materialIds.length == 0 || isArrayEmpty(materialIds)) {
            errorMessage = "Material ID list cannot be empty.";
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (quantities == null || quantities.length == 0 || isArrayEmpty(quantities)) {
            errorMessage = "Quantity list cannot be empty.";
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (prices == null || prices.length == 0 || isArrayEmpty(prices)) {
            errorMessage = "Price list cannot be empty.";
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (materialConditions == null || materialConditions.length == 0 || isArrayEmpty(materialConditions)) {
            errorMessage = "Condition list cannot be empty.";
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (supplierId == null && (newSupplierName == null || newSupplierName.trim().isEmpty())) {
            errorMessage = "Supplier information is required.";
            sendErrorResponse(response, errorMessage);
            return;
        }

        // Validate array lengths
        if (materialIds.length != quantities.length || materialIds.length != prices.length || materialIds.length != materialConditions.length) {
            errorMessage = "Material IDs, quantities, prices, and conditions are not synchronized.";
            sendErrorResponse(response, errorMessage);
            return;
        }

        // Validate userId
        if (userId == null) {
            errorMessage = "User ID cannot be empty.";
            sendErrorResponse(response, errorMessage);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ImportDAO importDAO = new ImportDAO(conn);

            // Check if voucherId exists
            if (importDAO.voucherIdExists(voucherId)) {
                errorMessage = "Voucher ID already exists.";
                sendErrorResponse(response, errorMessage);
                return;
            }

            // Create ImportReceipt object
            ImportReceipt receipt = new ImportReceipt();
            receipt.setVoucherId(voucherId);
            receipt.setUserId(userId);
            try {
                receipt.setImportDate(new java.sql.Date(new SimpleDateFormat("yyyy-MM-dd").parse(importDateStr).getTime()));
            } catch (ParseException e) {
                errorMessage = "Invalid date format.";
                sendErrorResponse(response, errorMessage);
                return;
            }
            receipt.setNote(note);

            // Handle new supplier if selected
            if (supplierId == null && newSupplierName != null && !newSupplierName.isEmpty()) {
                Supplier newSupplier = new Supplier();
                newSupplier.setSupplierName(newSupplierName);
                newSupplier.setSupplierPhone(newSupplierPhone);
                newSupplier.setSupplierAddress(newSupplierAddress);
                newSupplier.setSupplierEmail(newSupplierEmail);
                newSupplier.setSupplierStatus("active");
                SupplierDAO supplierDAO = new SupplierDAO(conn);
                supplierId = supplierDAO.addSupplierWithId(newSupplier);
                if (supplierId <= 0) {
                    errorMessage = "Failed to add new supplier.";
                    sendErrorResponse(response, errorMessage);
                    return;
                }
            }
            receipt.setSupplierId(supplierId);

            // Process import details
            List<ImportDetail> detailList = new ArrayList<>();
            for (int i = 0; i < materialIds.length; i++) {
                if (materialIds[i] == null || materialIds[i].trim().isEmpty()) {
                    errorMessage = "Material ID cannot be empty at row " + (i + 1);
                    sendErrorResponse(response, errorMessage, i);
                    return;
                }
                if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                    errorMessage = "Quantity cannot be empty at row " + (i + 1);
                    sendErrorResponse(response, errorMessage, i);
                    return;
                }
                if (prices[i] == null || prices[i].trim().isEmpty()) {
                    errorMessage = "Price cannot be empty at row " + (i + 1);
                    sendErrorResponse(response, errorMessage, i);
                    return;
                }
                try {
                    int materialId = Integer.parseInt(materialIds[i]);
                    double quantity = Double.parseDouble(quantities[i]);
                    double price = Double.parseDouble(prices[i]);
                    if (quantity <= 0 || price <= 0) {
                        errorMessage = "Quantity and price must be greater than 0 at row " + (i + 1);
                        sendErrorResponse(response, errorMessage, i);
                        return;
                    }
                    ImportDetail detail = new ImportDetail();
                    detail.setMaterialId(materialId);
                    detail.setQuantity(quantity);
                    detail.setPricePerUnit(price);
                    detail.setMaterialCondition(materialConditions[i]);
                    detailList.add(detail);
                } catch (NumberFormatException e) {
                    errorMessage = "Invalid material ID, quantity, or price at row " + (i + 1);
                    sendErrorResponse(response, errorMessage, i);
                    return;
                }
            }

            // Save import receipt and details
            try {
                int importId = importDAO.saveImportReceipt(receipt, detailList);
                if (importId > 0) {
                    Gson gson = new Gson();
                    String jsonResponse = gson.toJson(new ImportResponse("success", "Import receipt saved successfully!", importId, voucherId));
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    try (PrintWriter out = response.getWriter()) {
                        out.print(jsonResponse);
                        out.flush();
                    }
                } else {
                    errorMessage = "Unable to save import receipt. Please try again.";
                    sendErrorResponse(response, errorMessage);
                }
            } catch (SQLException e) {
                errorMessage = "Error saving import details. Please try again.";
                sendErrorResponse(response, errorMessage);
            }
        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "System error while processing import. Please try again or contact the administrator.";
            sendErrorResponse(response, errorMessage);
        }
    }

    private void sendErrorResponse(HttpServletResponse response, String errorMessage) throws IOException {
        sendErrorResponse(response, errorMessage, null);
    }

    private void sendErrorResponse(HttpServletResponse response, String errorMessage, Integer errorRow) throws IOException {
        Gson gson = new Gson();
        ImportResponse errorResponse = new ImportResponse("error", errorMessage, null, null);
        if (errorRow != null) {
            errorResponse.setErrorRow(errorRow);
        }
        String jsonResponse = gson.toJson(errorResponse);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(jsonResponse);
            out.flush();
        }
    }

    private boolean isArrayEmpty(String[] array) {
        for (String item : array) {
            if (item != null && !item.trim().isEmpty()) {
                return false;
            }
        }
        return true;
    }
}

// Class để đóng gói phản hồi cho JSON
class ImportResponse {

    private String status;
    private String message;
    private Integer importId;
    private String voucherId;
    private Integer errorRow;

    public ImportResponse(String status, String message, Integer importId, String voucherId) {
        this.status = status;
        this.message = message;
        this.importId = importId;
        this.voucherId = voucherId;
    }

    // Getters and setters
    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Integer getImportId() {
        return importId;
    }

    public void setImportId(Integer importId) {
        this.importId = importId;
    }

    public String getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(String voucherId) {
        this.voucherId = voucherId;
    }

    public Integer getErrorRow() {
        return errorRow;
    }

    public void setErrorRow(Integer errorRow) {
        this.errorRow = errorRow;
    }
}
