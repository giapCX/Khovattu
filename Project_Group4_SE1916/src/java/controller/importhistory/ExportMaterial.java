
package controller.importhistory;

import Dal.DBContext;
import dao.ExportDAO;
import dao.UserDAO;
import dao.MaterialDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import model.Export;
import model.ExportDetail;
import model.Material;
import model.User;
import com.google.gson.Gson;

public class ExportMaterial extends HttpServlet {

    private static final String ID_REGEX = "^[A-Za-z0-9-_]+$";
    private static final String TEXT_REGEX = "^[A-Za-z0-9\\s,.()-]+$";
    private static final int VOUCHER_ID_MAX_LENGTH = 50;
    private static final int PURPOSE_MAX_LENGTH = 500;
    private static final int NOTE_MAX_LENGTH = 1000;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fetch = request.getParameter("fetch");
        if ("materials".equals(fetch)) {
            try {
                MaterialDAO materialDAO = new MaterialDAO();
                List<Material> materials = materialDAO.getAllMaterials();
                Gson gson = new Gson();
                String json = gson.toJson(materials);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(json);
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Database error: " + e.getMessage() + "\"}");
            }
        } else {
            try {
                MaterialDAO materialDAO = new MaterialDAO();
                List<Material> materials = materialDAO.getAllMaterials();
                request.setAttribute("material", materials);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            } catch (SQLException e) {
                throw new ServletException("Database error: " + e.getMessage(), e);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String errorMessage = null;
        Integer errorRow = null;

        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        String voucherIdStr = request.getParameter("voucherId");
        String[] materialCodes = request.getParameterValues("materialCode[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] conditions = request.getParameterValues("condition[]");
        String purpose = request.getParameter("purpose");
        String note = request.getParameter("additionalNote");
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByUsername(username);

        // Generate exportId automatically
        //String exportIdStr = "EXP-" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "-" + System.currentTimeMillis();

        // Server-side validation
        if (voucherIdStr == null || voucherIdStr.trim().isEmpty()) {
            errorMessage = "Voucher ID cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (voucherIdStr.length() > VOUCHER_ID_MAX_LENGTH) {
            errorMessage = "Voucher ID cannot exceed " + VOUCHER_ID_MAX_LENGTH + " characters.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (!voucherIdStr.matches(ID_REGEX)) {
            errorMessage = "Voucher ID can only contain alphanumeric characters, hyphens, or underscores.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        // Check for duplicate voucherId
        try (Connection conn = DBContext.getConnection()) {
            ExportDAO dao = new ExportDAO(conn);
            if (dao.checkVoucherIdExists(voucherIdStr)) {
                errorMessage = "Voucher ID already exists. Please use a unique Voucher ID.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }
        } catch (SQLException e) {
            errorMessage = "Database error while checking Voucher ID: " + e.getMessage();
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        if (materialCodes == null || materialCodes.length == 0 || isArrayEmpty(materialCodes)) {
            errorMessage = "Material code list cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (quantities == null || quantities.length == 0 || isArrayEmpty(quantities)) {
            errorMessage = "Quantity list cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (conditions == null || conditions.length == 0 || isArrayEmpty(conditions)) {
            errorMessage = "Condition list cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (purpose == null || purpose.trim().isEmpty()) {
            errorMessage = "Export purpose cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (purpose.length() > PURPOSE_MAX_LENGTH) {
            errorMessage = "Export purpose cannot exceed " + PURPOSE_MAX_LENGTH + " characters.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (!purpose.matches(TEXT_REGEX)) {
            errorMessage = "Export purpose can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (note != null && note.length() > NOTE_MAX_LENGTH) {
            errorMessage = "Additional note cannot exceed " + NOTE_MAX_LENGTH + " characters.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (note != null && !note.isEmpty() && !note.matches(TEXT_REGEX)) {
            errorMessage = "Additional note can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        if (materialCodes.length != quantities.length || materialCodes.length != conditions.length) {
            errorMessage = "Material codes, quantities, and conditions are not synchronized.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        int userId = user.getUserId();

        try (Connection conn = DBContext.getConnection()) {
            ExportDAO dao = new ExportDAO(conn);
            Export export = new Export();
            export.setUserId(userId);
            export.setVoucherId(voucherIdStr);
            export.setExportDate(LocalDate.now());
            export.setNote(note);
            int exportId = dao.saveExport(export);
            if (exportId <= 0) {
                errorMessage = "Unable to save export voucher. Please try again.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }
            List<ExportDetail> detailList = new ArrayList<>();
            for (int i = 0; i < materialCodes.length; i++) {
                if (materialCodes[i] == null || materialCodes[i].trim().isEmpty()) {
                    errorMessage = "Material code cannot be empty at row " + (i + 1);
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i);
                    request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                    return;
                }
                if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                    errorMessage = "Quantity cannot be empty at row " + (i + 1);
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i);
                    request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                    return;
                }
                if (conditions[i] == null || conditions[i].trim().isEmpty()) {
                    errorMessage = "Condition cannot be empty at row " + (i + 1);
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i);
                    request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                    return;
                }
                try {
                    MaterialDAO m = new MaterialDAO();
                    int materialId = m.getMaterialIdByCode(materialCodes[i]);
                    int quantity = Integer.parseInt(quantities[i]);
                    if (quantity <= 0) {
                        errorMessage = "Quantity must be greater than 0 at row " + (i + 1);
                        request.setAttribute("error", errorMessage);
                        request.setAttribute("errorRow", i);
                        request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                        return;
                    }
                    ExportDetail detail = new ExportDetail();
                    detail.setExportId(exportId);
                    detail.setMaterialId(materialId);
                    detail.setQuantity(quantity);
                    detail.setMaterialCondition(conditions[i]);
                    detail.setReason(purpose);
                    detailList.add(detail);
                } catch (NumberFormatException e) {
                    errorMessage = "Invalid material code or quantity at row " + (i + 1);
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i);
                    request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                    return;
                }
            }

            try {
                dao.saveExportDetails(detailList, exportId);
            } catch (SQLException e) {
                errorMessage = "Error saving export details. Please try again.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }

            request.setAttribute("message", "Export voucher saved successfully!");
            request.setAttribute("exportId", exportId);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "System error while processing export. Please try again or contact the administrator.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
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