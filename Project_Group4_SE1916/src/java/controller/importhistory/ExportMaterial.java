package controller.importhistory;

import Dal.DBContext;
import com.google.gson.Gson;
import dao.ExportDAO;
import dao.UserDAO;
import dao.MaterialDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.Export;
import model.ExportDetail;
import model.Material;
import model.User;


public class ExportMaterial extends HttpServlet {

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
        String username = (String) session.getAttribute("username");
        Connection con = DBContext.getConnection();
        String exportIdStr = request.getParameter("exportId");
        String voucherIdStr = request.getParameter("voucherId");
        String[] materialCodes = request.getParameterValues("materialCode[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] conditions = request.getParameterValues("condition[]");
        String purpose = request.getParameter("purpose");

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByUsername(username);

        // Validate inputs for null or empty
        if (exportIdStr == null || exportIdStr.trim().isEmpty()) {
            errorMessage = "Export ID cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (voucherIdStr == null || voucherIdStr.trim().isEmpty()) {
            errorMessage = "Voucher ID cannot be empty.";
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

        // Validate array lengths
        if (materialCodes.length != quantities.length || materialCodes.length != conditions.length) {
            errorMessage = "Material codes, quantities, and conditions are not synchronized.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        // Validate userId
        String userId = user.getCode();
        if (userId == null || userId.trim().isEmpty()) {
            errorMessage = "Employee code cannot be empty.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ExportDAO dao = new ExportDAO(conn);

            // Create Export object
            Export export = new Export();
            export.setUserId(userId);
            export.setExportDate(LocalDate.now());
            export.setNote(purpose);
            // Save export
            int exportId = dao.saveExport(export);
            if (exportId <= 0) {
                errorMessage = "Unable to save export voucher. Please try again.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }
            // Process export details
            List<ExportDetail> detailList = new ArrayList<>();
            for (int i = 0; i < materialCodes.length; i++) {
                if (materialCodes[i] == null || materialCodes[i].trim().isEmpty()) {
                    errorMessage = "Material code cannot be empty at row " + (i + 1);
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i); // Set error row index
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
                    int materialId = Integer.parseInt(materialCodes[i]);
                    int quantity = Integer.parseInt(quantities[i]);
                    if (quantity <= 0) {
                        errorMessage = "Quantity must be greater than 0 at row " + (i + 1);
                        request.setAttribute("error", errorMessage);
                        request.setAttribute("errorRow", i); // Set error row index
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

            // Save export details
            try {
                dao.saveExportDetails(detailList, exportId);
            } catch (SQLException e) {
                errorMessage = "Error saving export details. Please try again.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }

            // Success
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
