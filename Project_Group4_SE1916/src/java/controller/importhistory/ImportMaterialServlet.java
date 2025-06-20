package controller.importhistory;

import Dal.DBContext;
import com.google.gson.Gson;
import dao.ImportDAO;
import dao.UserDAO;
import dao.MaterialDAO;
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
import model.Import;
import model.ImportDetail;
import model.Material;
import model.User;

public class ImportMaterialServlet extends HttpServlet {

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
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Server error: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/check_voucher_id".equals(path)) {
            handleCheckVoucherId(request, response);
            return;
        }

        String errorMessage = null;
        Integer errorRow = null;

        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        String voucherId = request.getParameter("voucher_id");
        System.out.println("Received raw voucherId: '" + voucherId + "'"); // Debug raw value
        if (voucherId == null) {
            errorMessage = "The import voucher code was not submitted.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }
        String trimmedVoucherId = voucherId.trim();
        System.out.println("Received trimmed voucherId: '" + trimmedVoucherId + "'"); // Debug trimmed value
        if (trimmedVoucherId.isEmpty()) {
            errorMessage = "The import voucher code must not be empty.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }
        String[] materialIds = request.getParameterValues("materialId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] unitPrices = request.getParameterValues("price_per_unit[]");
        String[] conditions = request.getParameterValues("materialCondition[]");
        String[] supplierIds = request.getParameterValues("supplierId[]");
        String note = request.getParameter("note");
        String importDateStr = request.getParameter("import_date");

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByUsername(username);

        if (materialIds == null || materialIds.length == 0 || isArrayEmpty(materialIds)) {
            errorMessage = "The list of material IDs must not be empty.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }
        if (quantities == null || quantities.length == 0 || isArrayEmpty(quantities)) {
            errorMessage = "The list of quantities must not be empty.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }
        if (unitPrices == null || unitPrices.length == 0 || isArrayEmpty(unitPrices)) {
            errorMessage = "The list of unit prices must not be empty.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }
        if (conditions == null || conditions.length == 0 || isArrayEmpty(conditions)) {
            errorMessage = "The list of conditions must not be empty.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }
        if (supplierIds == null || supplierIds.length == 0 || isArrayEmpty(supplierIds)) {
            errorMessage = "The list of supplier IDs must not be empty.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }
        if (importDateStr == null || importDateStr.trim().isEmpty()) {
            errorMessage = "The import date must not be empty.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }
        if (materialIds.length != quantities.length || materialIds.length != unitPrices.length ||
            materialIds.length != conditions.length || materialIds.length != supplierIds.length) {
            errorMessage = "The lists of material IDs, quantities, unit prices, conditions, and supplier IDs are not synchronized.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }
        if (user == null || user.getUserId() == 0) {
            errorMessage = "Invalid user information. Please log in again.";
            sendErrorResponse(request, response, errorMessage, null);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ImportDAO dao = new ImportDAO(conn);

            if (dao.voucherIdExists(trimmedVoucherId)) {
                errorMessage = "The import voucher code already exists. Please use a different code.";
                sendErrorResponse(request, response, errorMessage, null);
                return;
            }

            Import importReceipt = new Import();
            importReceipt.setVoucherId(trimmedVoucherId);
            importReceipt.setUserId(user.getUserId());
            importReceipt.setImportDate(LocalDate.parse(importDateStr));
            importReceipt.setNote(note);

            List<ImportDetail> detailList = new ArrayList<>();
            for (int i = 0; i < materialIds.length; i++) {
                if (materialIds[i] == null || materialIds[i].trim().isEmpty()) {
                    errorMessage = "Material ID must not be empty at row " + (i + 1);
                    sendErrorResponse(request, response, errorMessage, i);
                    return;
                }
                if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                    errorMessage = "Quantity must not be empty at row " + (i + 1);
                    sendErrorResponse(request, response, errorMessage, i);
                    return;
                }
                if (unitPrices[i] == null || unitPrices[i].trim().isEmpty()) {
                    errorMessage = "Unit price must not be empty at row " + (i + 1);
                    sendErrorResponse(request, response, errorMessage, i);
                    return;
                }
                if (conditions[i] == null || conditions[i].trim().isEmpty()) {
                    errorMessage = "Condition must not be empty at row " + (i + 1);
                    sendErrorResponse(request, response, errorMessage, i);
                    return;
                }
                if (supplierIds[i] == null || supplierIds[i].trim().isEmpty()) {
                    errorMessage = "Supplier ID must not be empty at row " + (i + 1);
                    sendErrorResponse(request, response, errorMessage, i);
                    return;
                }
                try {
                    int materialId = Integer.parseInt(materialIds[i]);
                    double quantity = Double.parseDouble(quantities[i]);
                    double unitPrice = Double.parseDouble(unitPrices[i]);
                    int supplierId = Integer.parseInt(supplierIds[i]);
                    if (quantity <= 0) {
                        errorMessage = "Quantity must be greater than 0 at row " + (i + 1);
                        sendErrorResponse(request, response, errorMessage, i);
                        return;
                    }
                    if (unitPrice <= 0) {
                        errorMessage = "Unit price must be greater than 0 at row " + (i + 1);
                        sendErrorResponse(request, response, errorMessage, i);
                        return;
                    }
                    ImportDetail detail = new ImportDetail();
                    detail.setImportId(0);
                    detail.setMaterialId(materialId);
                    detail.setQuantity(quantity);
                    detail.setPricePerUnit(unitPrice);
                    detail.setMaterialCondition(conditions[i]);
                    detail.setSupplierId(supplierId);
                    detailList.add(detail);
                } catch (NumberFormatException e) {
                    errorMessage = "Material ID, quantity, unit price, or supplier ID is invalid at row " + (i + 1);
                    sendErrorResponse(request, response, errorMessage, i);
                    return;
                }
            }

            int importId = dao.saveImport(importReceipt, detailList);
            if (importId <= 0) {
                errorMessage = "Unable to save the import voucher. Please try again.";
                sendErrorResponse(request, response, errorMessage, null);
                return;
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try (PrintWriter out = response.getWriter()) {
                Gson gson = new Gson();
                String json = gson.toJson(new ResponseMessage("success", "The import voucher has been saved successfully!", importId, null));
                out.print(json);
                out.flush();
            }

        } catch (SQLException e) {
            e.printStackTrace();
            errorMessage = "Database error: " + e.getMessage();
            sendErrorResponse(request, response, errorMessage, null);
        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "System error while processing the import voucher. Please try again.";
            sendErrorResponse(request, response, errorMessage, null);
        }
    }

    private void handleCheckVoucherId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            ImportDAO dao = new ImportDAO();
            String voucherId = request.getParameter("voucher_id");
            if (voucherId == null || voucherId.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"error\":\"The import voucher code must not be empty\"}");
                out.flush();
                return;
            }
            boolean exists = dao.voucherIdExists(voucherId);
            Gson gson = new Gson();
            String json = gson.toJson(new VoucherCheckResponse(exists));
            out.print(json);
            out.flush();
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error: " + e.getMessage() + "\"}");
        }
    }

    private void sendErrorResponse(HttpServletRequest request, HttpServletResponse response, String errorMessage, Integer errorRow)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            Gson gson = new Gson();
            String json = gson.toJson(new ResponseMessage("error", errorMessage, 0, errorRow));
            out.print(json);
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

        VoucherCheckResponse(boolean exists) {
            this.exists = exists;
        }
    }
}