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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            String getSuppliers = request.getParameter("getSuppliers");
            if ("true".equals(getSuppliers)) {
                try (Connection conn = DBContext.getConnection()) {
                    SupplierDAO supplierDAO = new SupplierDAO(conn);
                    List<Supplier> suppliers = supplierDAO.getAllSuppliers();
                    out.print(GSON.toJson(suppliers));
                    out.flush();
                } catch (SQLException e) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print(GSON.toJson(new ResponseMessage("error", "Database error: " + e.getMessage(), 0, null)));
                }
                return;
            }
            MaterialDAO materialDAO = new MaterialDAO();
            List<Material> materials = materialDAO.getAllMaterials();
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
            String path = request.getServletPath();
            if ("/check_voucher_id".equals(path)) {
                handleCheckVoucherId(request, response);
                return;
            }

            String errorMessage = null;
            Integer errorRow = null;

            HttpSession session = request.getSession();
            String username = (String) session.getAttribute("username");
            if (username == null || username.trim().isEmpty()) {
                errorMessage = "User not logged in. Please log in again.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }

            String voucherId = request.getParameter("voucher_id");
            System.out.println("Received raw voucherId from request: '" + voucherId + "'");
            if (voucherId == null || voucherId.trim().isEmpty()) {
                errorMessage = "The import voucher code was not submitted.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            String trimmedVoucherId = voucherId.trim();
            System.out.println("Received trimmed voucherId: '" + trimmedVoucherId + "'");

            String[] materialIds = request.getParameterValues("materialId[]");
            String[] quantities = request.getParameterValues("quantity[]");
            String[] unitPrices = request.getParameterValues("price_per_unit[]");
            String[] conditions = request.getParameterValues("materialCondition[]");
            String[] supplierIds = request.getParameterValues("supplierId[]"); // Lấy supplierId từ bảng
            String note = request.getParameter("note");
            String importDateStr = request.getParameter("import_date");

            // Validate input arrays
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
            if (materialIds.length != quantities.length || materialIds.length != unitPrices.length ||
                materialIds.length != conditions.length || materialIds.length != supplierIds.length) {
                errorMessage = "The lists of material IDs, quantities, unit prices, conditions, and suppliers are not synchronized.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }
            if (importDateStr == null || importDateStr.trim().isEmpty()) {
                errorMessage = "The import date must not be empty.";
                sendErrorResponse(response, errorMessage, null);
                return;
            }

            try (Connection conn = DBContext.getConnection()) {
                ImportDAO dao = new ImportDAO(conn);
                SupplierDAO supplierDAO = new SupplierDAO(conn);
                UserDAO userDAO = new UserDAO();
                MaterialDAO materialDAO = new MaterialDAO();

                // Check voucher ID uniqueness
                if (dao.voucherIdExists(trimmedVoucherId)) {
                    errorMessage = "The import voucher code already exists. Please use a different code.";
                    sendErrorResponse(response, errorMessage, null);
                    return;
                }

                // Validate user
                User user = userDAO.getUserByUsername(username);
                if (user == null || user.getUserId() == 0) {
                    errorMessage = "Invalid user information. Please log in again.";
                    sendErrorResponse(response, errorMessage, null);
                    return;
                }

                // Create ImportReceipt object (supplierId sẽ lấy từ detail đầu tiên)
                ImportReceipt importReceipt = new ImportReceipt();
                importReceipt.setVoucherId(trimmedVoucherId);
                importReceipt.setUserId(user.getUserId());
                importReceipt.setImportDate(java.sql.Date.valueOf(LocalDate.parse(importDateStr)));
                importReceipt.setNote(note != null ? note.trim() : "");
                // Lấy supplierId từ hàng đầu tiên làm supplierId cho biên lai
                int supplierId = Integer.parseInt(supplierIds[0].trim());
                importReceipt.setSupplierId(supplierId);

                // Validate materials and create ImportDetail list
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
                        supplierId = Integer.parseInt(supplierIds[i].trim());
                        // Validate material existence
                        if (!materialDAO.materialExists(materialId)) {
                            errorMessage = "Material ID " + materialId + " does not exist at row " + (i + 1);
                            sendErrorResponse(response, errorMessage, i);
                            return;
                        }

                        // Validate supplier existence
                        if (!supplierDAO.supplierExists(supplierId)) {
                            errorMessage = "Supplier ID " + supplierId + " does not exist at row " + (i + 1);
                            sendErrorResponse(response, errorMessage, i);
                            return;
                        }

                        // Validate supplier-material relationship
                        Material material = materialDAO.getMaterialById(materialId);
                        boolean supplierValid = false;
                        for (Supplier supplier : material.getSuppliers()) {
                            if (supplier.getSupplierId() == supplierId) {
                                supplierValid = true;
                                break;
                            }
                        }
                        if (!supplierValid) {
                            errorMessage = "Material '" + material.getName() + "' at row " + (i + 1) + " is not associated with the selected supplier.";
                            sendErrorResponse(response, errorMessage, i);
                            return;
                        }

                        double quantity = Double.parseDouble(quantities[i].trim());
                        double unitPrice = Double.parseDouble(unitPrices[i].trim());

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

                        ImportDetail detail = new ImportDetail();
                        detail.setImportId(0); // Will be set by DAO
                        detail.setMaterialId(materialId);
                        detail.setQuantity(quantity);
                        detail.setPricePerUnit(unitPrice);
                        detail.setMaterialCondition(conditions[i].trim());
                        detail.setMaterialCode(material.getCode());
                        detail.setMaterialName(material.getName());
                        detail.setUnit(material.getUnit());
                        detail.setSupplierId(supplierId); // Set supplierId from table
                        detailList.add(detail);
                    } catch (NumberFormatException e) {
                        errorMessage = "Invalid number format for material ID, quantity, unit price, or supplier ID at row " + (i + 1);
                        sendErrorResponse(response, errorMessage, i);
                        return;
                    }
                }

                // Save to database
                int importId = dao.saveImport(importReceipt, detailList);
                if (importId <= 0) {
                    errorMessage = "Failed to save the import voucher. Please try again.";
                    sendErrorResponse(response, errorMessage, null);
                    return;
                }

                String successMessage = "The import voucher has been saved successfully! Data has been updated to the database. (Import Voucher ID: " + importId + ")";
                out.print(GSON.toJson(new ResponseMessage("success", successMessage, importId, null)));
                out.flush();
            } catch (SQLException e) {
                e.printStackTrace();
                errorMessage = "Database error: " + e.getMessage();
                sendErrorResponse(response, errorMessage, null);
            } catch (Exception e) {
                e.printStackTrace();
                errorMessage = "System error while processing the import voucher: " + e.getMessage();
                sendErrorResponse(response, errorMessage, null);
            }
        }
    }

    private void handleCheckVoucherId(HttpServletRequest request, HttpServletResponse response) throws IOException {
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    try (PrintWriter out = response.getWriter()) {
        String voucherId = request.getParameter("voucher_id");
        if (voucherId == null || voucherId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print(GSON.toJson(new VoucherCheckResponse(false, "The import voucher code must not be empty")));
            return;
        }
        ImportDAO dao = new ImportDAO(); // Sử dụng constructor mặc định, đảm bảo DBContext được cấu hình
        boolean exists = dao.voucherIdExists(voucherId.trim());
        out.print(GSON.toJson(new VoucherCheckResponse(exists, null)));
        out.flush();
    } catch (SQLException e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        try (PrintWriter out = response.getWriter()) {
            out.print(GSON.toJson(new VoucherCheckResponse(false, "Database error: " + e.getMessage())));
            out.flush();
        }
    } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        try (PrintWriter out = response.getWriter()) {
            out.print(GSON.toJson(new VoucherCheckResponse(false, "Server error: " + e.getMessage())));
            out.flush();
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

    private static class VoucherCheckResponse {
        boolean exists;
        String error;

        VoucherCheckResponse(boolean exists, String error) {
            this.exists = exists;
            this.error = error;
        }
    }
}