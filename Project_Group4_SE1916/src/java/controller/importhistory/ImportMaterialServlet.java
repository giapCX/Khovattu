package controller.importhistory;

import Dal.DBContext;
import com.google.gson.Gson;
import dao.ImportDAO;
import dao.UserDAO;
import dao.MaterialDAO;
import dao.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.ImportReceipt;
import model.ImportDetail;
import model.Material;
import model.User;
import model.Supplier;

public class ImportMaterialServlet extends HttpServlet {

    private static final Gson GSON = new Gson();
    private static final String ID_REGEX = "^[A-Za-z0-9-_]+$";
    private static final int RECEIPT_ID_MAX_LENGTH = 50; // Changed from VOUCHER_ID_MAX_LENGTH
    private static final int NOTE_MAX_LENGTH = 1000;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            MaterialDAO materialDAO = new MaterialDAO();
            List<Material> materials = materialDAO.getAllMaterials();
            for (Material material : materials) {
                List<Supplier> suppliers = new ArrayList<>();
                String sql = "SELECT s.supplier_id, s.name AS supplier_name FROM Suppliers s "
                        + "JOIN SupplierMaterials sm ON s.supplier_id = sm.supplier_id "
                        + "WHERE sm.material_id = ?";
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, material.getMaterialId());
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        Supplier supplier = new Supplier();
                        supplier.setSupplierId(rs.getInt("supplier_id"));
                        supplier.setSupplierName(rs.getString("supplier_name"));
                        suppliers.add(supplier);
                    }
                    material.setSuppliers(suppliers);
                } catch (SQLException e) {
                    throw new SQLException("Error fetching suppliers for material ID " + material.getMaterialId(), e);
                }
            }
            out.print(GSON.toJson(materials));
            out.flush();
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(GSON.toJson(new ResponseMessage("error", "Database error: " + e.getMessage(), 0, null)));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(GSON.toJson(new ResponseMessage("error", "Server error: " + e.getMessage(), 0, null)));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            String errorMessage = null;
            Integer errorRow = null;

            HttpSession session = request.getSession();
            String username = (String) session.getAttribute("username");
            if (username == null || username.trim().isEmpty()) {
                errorMessage = "User not logged in. Please log in again.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }

            String receiptId = request.getParameter("receipt_id"); // Changed from voucher_id
            if (receiptId == null || receiptId.trim().isEmpty()) {
                errorMessage = "The import receipt code was not submitted.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            String trimmedReceiptId = receiptId.trim();
            if (trimmedReceiptId.length() > RECEIPT_ID_MAX_LENGTH) {
                errorMessage = "Receipt ID cannot exceed " + RECEIPT_ID_MAX_LENGTH + " characters.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            if (!trimmedReceiptId.matches(ID_REGEX)) {
                errorMessage = "Receipt ID can only contain alphanumeric characters, hyphens, or underscores.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }

            String[] materialIds = request.getParameterValues("materialId[]");
            String[] quantities = request.getParameterValues("quantity[]");
            String[] unitPrices = request.getParameterValues("price_per_unit[]");
            String[] conditions = request.getParameterValues("materialCondition[]");
            String[] supplierIds = request.getParameterValues("supplierId[]");

            if (materialIds == null || materialIds.length == 0 || isArrayEmpty(materialIds)) {
                errorMessage = "The list of material IDs must not be empty.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            if (quantities == null || quantities.length == 0 || isArrayEmpty(quantities)) {
                errorMessage = "The list of quantities must not be empty.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            if (unitPrices == null || unitPrices.length == 0 || isArrayEmpty(unitPrices)) {
                errorMessage = "The list of unit prices must not be empty.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            if (conditions == null || conditions.length == 0 || isArrayEmpty(conditions)) {
                errorMessage = "The list of conditions must not be empty.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            if (supplierIds == null || supplierIds.length == 0 || isArrayEmpty(supplierIds)) {
                errorMessage = "The list of supplier IDs must not be empty.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            if (materialIds.length != quantities.length || materialIds.length != unitPrices.length
                    || materialIds.length != conditions.length || materialIds.length != supplierIds.length) {
                errorMessage = "The lists of material IDs, quantities, unit prices, conditions, and suppliers are not synchronized.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }

            String note = request.getParameter("note");
            String importDateStr = request.getParameter("import_date");
            if (note != null && note.length() > NOTE_MAX_LENGTH) {
                errorMessage = "Note cannot exceed " + NOTE_MAX_LENGTH + " characters.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            if (note != null && !note.isEmpty() && !note.matches("^[A-Za-z0-9\\s,.()-]+$")) {
                errorMessage = "Note can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            if (importDateStr == null || importDateStr.trim().isEmpty()) {
                errorMessage = "The import date must not be empty.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }

            try (Connection conn = DBContext.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    ImportDAO dao = new ImportDAO(conn);
                    SupplierDAO supplierDAO = new SupplierDAO(conn);
                    UserDAO userDAO = new UserDAO();
                    MaterialDAO materialDAO = new MaterialDAO();

                    if (dao.receiptIdExists(trimmedReceiptId)) { // Changed from voucherIdExists
                        errorMessage = "The import receipt code already exists. Please use a different code.";
                        sendErrorResponse(response, errorMessage, null);
                        return;
                    }

                    User user = userDAO.getUserByUsername(username);
                    if (user == null || user.getUserId() == 0) {
                        errorMessage = "Invalid user information. Please log in again.";
                        sendErrorResponse(response, errorMessage, null);
                        return;
                    }

                    int supplierId = Integer.parseInt(supplierIds[0].trim());
                    for (int i = 1; i < supplierIds.length; i++) {
                        if (!supplierIds[i].trim().equals(String.valueOf(supplierId))) {
                            errorMessage = "All materials must be supplied by the same supplier in a single import.";
                            sendErrorResponse(response, errorMessage, i);
                            return;
                        }
                    }
                    if (!supplierDAO.supplierExists(supplierId)) {
                        errorMessage = "Supplier ID " + supplierId + " does not exist.";
                        sendErrorResponse(response, errorMessage, null);
                        return;
                    }

                    ImportReceipt importReceipt = new ImportReceipt();
                    importReceipt.setReceiptId(trimmedReceiptId); // Changed from setVoucherId
                    importReceipt.setUserId(user.getUserId());
                    importReceipt.setImportDate(java.sql.Date.valueOf(LocalDate.parse(importDateStr)));
                    importReceipt.setNote(note != null ? note.trim() : "");
                    importReceipt.setSupplierId(supplierId);

                    List<ImportDetail> detailList = new ArrayList<>();
                    for (int i = 0; i < materialIds.length; i++) {
                        try {
                            if (materialIds[i] == null || materialIds[i].trim().isEmpty()) {
                                errorMessage = "Material ID must not be empty at row " + (i + 1);
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }
                            if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                                errorMessage = "Quantity must not be empty at row " + (i + 1);
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }
                            if (unitPrices[i] == null || unitPrices[i].trim().isEmpty()) {
                                errorMessage = "Unit price must not be empty at row " + (i + 1);
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }
                            if (conditions[i] == null || conditions[i].trim().isEmpty()) {
                                errorMessage = "Condition must not be empty at row " + (i + 1);
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }
                            if (supplierIds[i] == null || supplierIds[i].trim().isEmpty()) {
                                errorMessage = "Supplier ID must not be empty at row " + (i + 1);
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }

                            int materialId = Integer.parseInt(materialIds[i].trim());
                            double quantity = Double.parseDouble(quantities[i].trim());
                            double unitPrice = Double.parseDouble(unitPrices[i].trim());

                            if (!materialDAO.materialExists(materialId)) {
                                errorMessage = "Material ID " + materialId + " does not exist at row " + (i + 1);
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }

                            Material material = materialDAO.getMaterialById(materialId);
                            boolean supplierValid = false;
                            List<Supplier> suppliers = material.getSuppliers();
                            if (suppliers != null) {
                                for (Supplier supplier : suppliers) {
                                    if (supplier.getSupplierId() == supplierId) {
                                        supplierValid = true;
                                        break;
                                    }
                                }
                            }
                            if (!supplierValid) {
                                errorMessage = "Material '" + material.getName() + "' at row " + (i + 1) + " is not associated with the selected supplier.";
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }

                            if (quantity <= 0) {
                                errorMessage = "Quantity must be greater than 0 at row " + (i + 1);
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }
                            if (unitPrice <= 0) {
                                errorMessage = "Unit price must be greater than 0 at row " + (i + 1);
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }

                            if (!conditions[i].matches("new|used|damaged")) {
                                errorMessage = "Invalid material condition at row " + (i + 1);
                                sendErrorResponse(response, errorMessage, i);
                                return;
                            }

                            ImportDetail detail = new ImportDetail();
                            detail.setMaterialId(materialId);
                            detail.setQuantity(quantity);
                            detail.setPricePerUnit(unitPrice);
                            detail.setMaterialCondition(conditions[i].trim());
                            detailList.add(detail);
                        } catch (NumberFormatException e) {
                            errorMessage = "Invalid number format for material ID, quantity, unit price, or supplier ID at row " + (i + 1);
                            sendErrorResponse(response, errorMessage, i);
                            return;
                        }
                    }

                    int importId = dao.saveImport(importReceipt, detailList);
                    if (importId <= 0) {
                        errorMessage = "Failed to save the import receipt. Please try again.";
                        sendErrorResponse(response, errorMessage, null);
                        return;
                    }

                    materialDAO.updateInventoryFromImport(detailList);

                    conn.commit();
                    String successMessage = "The import receipt has been saved successfully! Data has been updated to the database. (Import Receipt ID: " + importId + ")";
                    out.print(GSON.toJson(new ResponseMessage("success", successMessage, importId, null)));
                    out.flush();
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                }
            } catch (SQLException e) {
                e.printStackTrace();
                errorMessage = "Database error: " + e.getMessage();
                sendErrorResponse(response, errorMessage, null);
            } catch (Exception e) {
                e.printStackTrace();
                errorMessage = "System error while processing the import receipt: " + e.getMessage();
                sendErrorResponse(response, errorMessage, null);
            }
        }
    }

    private void sendErrorResponse(HttpServletResponse response, String errorMessage, Integer errorRow)
            throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        try (PrintWriter out = response.getWriter()) {
            out.print(GSON.toJson(new ResponseMessage("error", errorMessage, 0, errorRow)));
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

    private static class ResponseMessage {

        String status;
        String message;
        int importId;
        Integer errorRow;

        ResponseMessage(String status, String message, int importId, Integer errorRow) {
            this.status = status;
            this.message = message;
            this.importId = importId;
            this.errorRow = errorRow;
        }
    }
}
