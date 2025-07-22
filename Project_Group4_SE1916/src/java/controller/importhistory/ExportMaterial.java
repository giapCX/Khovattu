//exMaServlet
package controller.importhistory;

import Dal.DBContext;
import dao.ExportDAO;
import dao.UserDAO;
import dao.MaterialDAO;
import dao.ConstructionSiteDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.Export;
import model.ExportDetail;
import model.Material;
import model.User;
import model.ConstructionSite;
import com.google.gson.Gson;

public class ExportMaterial extends HttpServlet {

    private static final String ID_REGEX = "^[A-Za-z0-9-_]+$";
    private static final String TEXT_REGEX = "^[A-Za-z0-9\\s,.()-]+$";
    private static final int VOUCHER_ID_MAX_LENGTH = 50;
    private static final int RECEIVER_MAX_LENGTH = 100;
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
        } else if ("employees".equals(fetch)) {
            try {
                UserDAO userDAO = new UserDAO();
                List<User> employees = userDAO.getAllEmployees();
                Gson gson = new Gson();
                String json = gson.toJson(employees);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(json);
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Database error: " + e.getMessage() + "\"}");
            }
        } else if ("sites".equals(fetch)) {
            try (Connection conn = DBContext.getConnection()) {
                ConstructionSiteDAO siteDAO = new ConstructionSiteDAO(conn);
                List<ConstructionSite> sites = siteDAO.getAllConstructionSites();
                Gson gson = new Gson();
                String json = gson.toJson(sites);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(json);
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Database error: " + e.getMessage() + "\"}");
            }
        } else if ("checkReceiptId".equals(fetch)) {
            String receiptId = request.getParameter("receiptId");
            if (receiptId == null || receiptId.trim().isEmpty() || receiptId.length() > VOUCHER_ID_MAX_LENGTH || !receiptId.matches(ID_REGEX)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"error\": \"Invalid Receipt ID format\"}");
                return;
            }
            try (Connection conn = DBContext.getConnection()) {
                ExportDAO dao = new ExportDAO(conn);
                boolean exists = dao.checkReceiptIdExists(receiptId);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"exists\": " + exists + "}");
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Database error: " + e.getMessage() + "\"}");
            }
        } else {
            try {
                MaterialDAO materialDAO = new MaterialDAO();
                List<Material> materials = materialDAO.getAllMaterials();
                ConstructionSiteDAO siteDAO = new ConstructionSiteDAO();
                List<ConstructionSite> sites = siteDAO.getAllConstructionSites();
                request.setAttribute("material", materials);
                request.setAttribute("sites", sites);
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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            errorMessage = "Invalid or expired session.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        String username = (String) session.getAttribute("username");
        String voucherIdStr = request.getParameter("voucherId");
        String receiver = request.getParameter("receiver");
        String siteIdStr = request.getParameter("siteId");
        String siteName = request.getParameter("siteName");
        String[] materialCodes = request.getParameterValues("materialCode[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] conditions = request.getParameterValues("condition[]");
        String purpose = request.getParameter("purpose");
        String note = request.getParameter("additionalNote");
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByUsername(username);

        // Server-side validation
        if (username == null || user == null) {
            errorMessage = "User is not logged in or session is invalid.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (voucherIdStr == null || voucherIdStr.trim().isEmpty()) {
            errorMessage = "Export voucher ID cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (voucherIdStr.length() > VOUCHER_ID_MAX_LENGTH) {
            errorMessage = "Export voucher ID must not exceed " + VOUCHER_ID_MAX_LENGTH + " characters.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (!voucherIdStr.matches(ID_REGEX)) {
            errorMessage = "Export voucher ID can only contain letters, numbers, hyphens, or underscores.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (receiver == null || receiver.trim().isEmpty()) {
            errorMessage = "Receiver cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
       
        if (siteIdStr == null || siteIdStr.trim().isEmpty()) {
            errorMessage = "Construction site ID cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (siteName == null || siteName.trim().isEmpty()) {
            errorMessage = "Construction site name cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        int siteId;
        try (Connection conn = DBContext.getConnection()) {
            siteId = Integer.parseInt(siteIdStr);
            ConstructionSiteDAO siteDAO = new ConstructionSiteDAO(conn);
            ConstructionSite site = siteDAO.getConstructionSiteById(siteId);
            if (site == null || !site.getSiteName().equals(siteName)) {
                errorMessage = "Selected construction site is invalid or site name does not match.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            errorMessage = "Invalid construction site ID format.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        } catch (SQLException e) {
            errorMessage = "Database error while validating construction site: " + e.getMessage();
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        int receiverId = -1;
        try {
            receiverId = userDAO.getUserIdByFullName(receiver);
            if (receiverId == -1) {
                errorMessage = "Selected receiver is invalid.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }
        } catch (SQLException e) {
            errorMessage = "Database error while validating receiver: " + e.getMessage();
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ExportDAO dao = new ExportDAO(conn);
            if (dao.checkReceiptIdExists(voucherIdStr)) {
                errorMessage = "Export voucher ID already exists. Please use a unique voucher ID.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }
        } catch (SQLException e) {
            errorMessage = "Database error while checking voucher ID: " + e.getMessage();
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
            errorMessage = "Export purpose must not exceed " + PURPOSE_MAX_LENGTH + " characters.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (!purpose.matches(TEXT_REGEX)) {
            errorMessage = "Export purpose can only contain letters, numbers, spaces, commas, periods, parentheses, or hyphens.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (note != null && note.length() > NOTE_MAX_LENGTH) {
            errorMessage = "Additional note must not exceed " + NOTE_MAX_LENGTH + " characters.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (note != null && !note.isEmpty() && !note.matches(TEXT_REGEX)) {
            errorMessage = "Additional note can only contain letters, numbers, spaces, commas, periods, parentheses, or hyphens.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (materialCodes.length != quantities.length || materialCodes.length != conditions.length) {
            errorMessage = "Material code, quantity, and condition lists are not synchronized.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        int userId = user.getUserId();
        int exportId = -1;

        try (Connection conn = DBContext.getConnection()) {
            // Save export
            ExportDAO dao = new ExportDAO(conn);
            Export export = new Export();
            export.setExporterId(userId);
            //export.setReceiptId(voucherIdStr);
            export.setReceiverId(receiverId);
            export.setExportDate(LocalDate.now());
            export.setNote(note);
            export.setSiteId(siteId);
            exportId = dao.saveExport(export);
            if (exportId <= 0) {
                errorMessage = "Failed to save export voucher. Please try again.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }

            // Process export details
            MaterialDAO materialDAO = new MaterialDAO();
            String selectSql = "SELECT quantity_in_stock FROM Inventory WHERE material_id = ? AND material_condition = ?";
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
                    int materialId = materialDAO.getMaterialIdByCode(materialCodes[i]);
                    if (materialId == -1) {
                        errorMessage = "Invalid material code at row " + (i + 1);
                        request.setAttribute("error", errorMessage);
                        request.setAttribute("errorRow", i);
                        request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                        return;
                    }
                    double quantity = Double.parseDouble(quantities[i]);
                    if (quantity <= 0) {
                        errorMessage = "Quantity must be greater than 0 at row " + (i + 1);
                        request.setAttribute("error", errorMessage);
                        request.setAttribute("errorRow", i);
                        request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                        return;
                    }

                    // Check inventory
                    try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
                        selectStmt.setInt(1, materialId);
                        selectStmt.setString(2, conditions[i]);
                        ResultSet rs = selectStmt.executeQuery();
                        if (!rs.next()) {
                            errorMessage = "Material or condition does not exist in inventory at row " + (i + 1);
                            request.setAttribute("error", errorMessage);
                            request.setAttribute("errorRow", i);
                            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                            return;
                        }
                        double quantityInStock = rs.getDouble("quantity_in_stock");
                        if (quantityInStock < quantity) {
                            errorMessage = "Insufficient inventory quantity at row " + (i + 1);
                            request.setAttribute("error", errorMessage);
                            request.setAttribute("errorRow", i);
                            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                            return;
                        }
                    }

                    // Save export detail and update inventory
                    dao.exportMaterial(exportId, materialId, quantity, conditions[i]);
                } catch (NumberFormatException e) {
                    errorMessage = "Invalid quantity format at row " + (i + 1);
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i);
                    request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                    return;
                } catch (SQLException e) {
                    errorMessage = "Database error at row " + (i + 1) + ": " + e.getMessage();
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i);
                    request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                    return;
                }
            }

            // Forward success response
            if (!response.isCommitted()) {
                request.setAttribute("message", "Export voucher saved successfully!");
                request.setAttribute("exportId", exportId);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            } else {
                System.err.println("Response already committed, cannot forward.");
            }
        } catch (SQLException e) {
            errorMessage = "Database error while processing export: " + e.getMessage();
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "System error while processing export: " + e.getClass().getName() + " - " + e.getMessage();
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