package controller.importhistory;

import Dal.DBContext;
import com.google.gson.Gson;
import dao.ImportDAO;
import dao.MaterialDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpSession;
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

public class ImportWarehouseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            MaterialDAO materialDAO = new MaterialDAO();
            List<Material> materials = materialDAO.getAllMaterials();
            for (Material m : materials) {
                System.out.println("Material ID: " + m.getMaterialId() + ", Suppliers: " + m.getSuppliers());
            }
            Gson gson = new Gson();
            String json = gson.toJson(materials);
            out.print(json);
            out.flush();
        } catch (SQLException e) {
            System.err.println("ImportWarehouseServlet: SQL error in doGet: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String errorMessage = null;
        Integer errorRow = null;

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String voucherId = request.getParameter("voucher_id");
        String importDateStr = request.getParameter("import_date");
        String[] materialIds = request.getParameterValues("materialId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] prices = request.getParameterValues("price_per_unit[]");
        String[] materialConditions = request.getParameterValues("materialCondition[]");
        String[] supplierIds = request.getParameterValues("supplierId[]");
        String note = request.getParameter("note");

        System.out.println("ImportWarehouseServlet: Received data - voucherId: " + voucherId + ", userId: " + userId +
                ", supplierIds: " + (supplierIds != null ? String.join(",", supplierIds) : "null"));

        if (voucherId == null || voucherId.trim().isEmpty()) {
            errorMessage = "Voucher ID is missing or empty.";
            System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (importDateStr == null || importDateStr.trim().isEmpty()) {
            errorMessage = "Import date cannot be empty.";
            System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (materialIds == null || materialIds.length == 0 || isArrayEmpty(materialIds)) {
            errorMessage = "Material ID list cannot be empty.";
            System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (quantities == null || quantities.length == 0 || isArrayEmpty(quantities)) {
            errorMessage = "Quantity list cannot be empty.";
            System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (prices == null || prices.length == 0 || isArrayEmpty(prices)) {
            errorMessage = "Price list cannot be empty.";
            System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (materialConditions == null || materialConditions.length == 0 || isArrayEmpty(materialConditions)) {
            errorMessage = "Condition list cannot be empty.";
            System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (supplierIds == null || supplierIds.length == 0 || isArrayEmpty(supplierIds)) {
            errorMessage = "Supplier list cannot be empty.";
            System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
            sendErrorResponse(response, errorMessage);
            return;
        }
        if (userId == null) {
            errorMessage = "User ID cannot be empty. Please log in again.";
            System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
            sendErrorResponse(response, errorMessage);
            return;
        }

        if (materialIds.length != quantities.length || materialIds.length != prices.length
                || materialIds.length != materialConditions.length || materialIds.length != supplierIds.length) {
            errorMessage = "Material IDs, quantities, prices, conditions, and suppliers are not synchronized.";
            System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
            sendErrorResponse(response, errorMessage);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false); // Start transaction
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE); // Prevent race conditions
            ImportDAO importDAO = new ImportDAO(conn);

            if (importDAO.voucherIdExists(voucherId)) {
                conn.rollback();
                errorMessage = "Voucher ID '" + voucherId + "' already exists in the system. Please use a different ID.";
                System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
                sendErrorResponse(response, errorMessage);
                return;
            }

            ImportReceipt receipt = new ImportReceipt();
            receipt.setVoucherId(voucherId);
            receipt.setUserId(userId);
            try {
                receipt.setImportDate(new java.sql.Date(new SimpleDateFormat("yyyy-MM-dd").parse(importDateStr).getTime()));
            } catch (ParseException e) {
                conn.rollback();
                errorMessage = "Invalid date format.";
                System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
                sendErrorResponse(response, errorMessage);
                return;
            }
            receipt.setNote(note);
            if (supplierIds != null && supplierIds.length > 0 && supplierIds[0] != null && !supplierIds[0].trim().isEmpty()) {
                receipt.setSupplierId(Integer.parseInt(supplierIds[0]));
            } else {
                conn.rollback();
                errorMessage = "Supplier ID cannot be empty for receipt.";
                System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
                sendErrorResponse(response, errorMessage);
                return;
            }

            List<ImportDetail> detailList = new ArrayList<>();
            for (int i = 0; i < materialIds.length; i++) {
                if (materialIds[i] == null || materialIds[i].trim().isEmpty()) {
                    conn.rollback();
                    errorMessage = "Material ID cannot be empty at row " + (i + 1);
                    System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
                    sendErrorResponse(response, errorMessage, i);
                    return;
                }
                if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                    conn.rollback();
                    errorMessage = "Quantity cannot be empty at row " + (i + 1);
                    System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
                    sendErrorResponse(response, errorMessage, i);
                    return;
                }
                if (prices[i] == null || prices[i].trim().isEmpty()) {
                    conn.rollback();
                    errorMessage = "Price cannot be empty at row " + (i + 1);
                    System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
                    sendErrorResponse(response, errorMessage, i);
                    return;
                }
                try {
                    int materialId = Integer.parseInt(materialIds[i]);
                    double quantity = Double.parseDouble(quantities[i]);
                    double price = Double.parseDouble(prices[i]);
                    int supplierId = Integer.parseInt(supplierIds[i]);
                    if (quantity <= 0 || price <= 0) {
                        conn.rollback();
                        errorMessage = "Quantity and price must be greater than 0 at row " + (i + 1);
                        System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
                        sendErrorResponse(response, errorMessage, i);
                        return;
                    }
                    ImportDetail detail = new ImportDetail();
                    detail.setMaterialId(materialId);
                    detail.setQuantity(quantity);
                    detail.setPricePerUnit(price);
                    detail.setMaterialCondition(materialConditions[i]);
                    detail.setSupplierId(supplierId);
                    detailList.add(detail);
                } catch (NumberFormatException e) {
                    conn.rollback();
                    errorMessage = "Invalid material ID, quantity, price, or supplier at row " + (i + 1);
                    System.out.println("ImportWarehouseServlet: Validation failed - " + errorMessage);
                    sendErrorResponse(response, errorMessage, i);
                    return;
                }
            }

            try {
                int importId = importDAO.saveImportReceipt(receipt, detailList);
                if (importId > 0) {
                    conn.commit(); // Commit transaction
                    System.out.println("ImportWarehouseServlet: Import receipt saved successfully, importId: " + importId);
                    Gson gson = new Gson();
                    String jsonResponse = gson.toJson(new ImportResponse("success", "Import receipt saved successfully!", importId, voucherId));
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    try (PrintWriter out = response.getWriter()) {
                        out.print(jsonResponse);
                        out.flush();
                    }
                } else {
                    conn.rollback();
                    errorMessage = "Unable to save import receipt. Please check database or contact administrator.";
                    System.out.println("ImportWarehouseServlet: Failed to save import receipt");
                    sendErrorResponse(response, errorMessage);
                }
            } catch (SQLException e) {
                conn.rollback();
                errorMessage = "Error saving import details: " + e.getMessage();
                System.err.println("ImportWarehouseServlet: SQL error in doPost: " + e.getMessage());
                sendErrorResponse(response, errorMessage);
            }
        } catch (SQLException e) {
            errorMessage = "System error while processing import: " + e.getMessage();
            System.err.println("ImportWarehouseServlet: SQL error in doPost: " + e.getMessage());
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