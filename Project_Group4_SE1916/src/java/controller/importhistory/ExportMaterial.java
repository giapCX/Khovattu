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
            errorMessage = "Mã xuất không được để trống.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (voucherIdStr == null || voucherIdStr.trim().isEmpty()) {
            errorMessage = "Mã phiếu không được để trống.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (materialCodes == null || materialCodes.length == 0 || isArrayEmpty(materialCodes)) {
            errorMessage = "Danh sách mã vật tư không được để trống.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (quantities == null || quantities.length == 0 || isArrayEmpty(quantities)) {
            errorMessage = "Danh sách số lượng không được để trống.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (conditions == null || conditions.length == 0 || isArrayEmpty(conditions)) {
            errorMessage = "Danh sách điều kiện không được để trống.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }
        if (purpose == null || purpose.trim().isEmpty()) {
            errorMessage = "Lý do xuất kho không được để trống.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        // Validate array lengths
        if (materialCodes.length != quantities.length || materialCodes.length != conditions.length) {
            errorMessage = "Dữ liệu mã vật tư, số lượng và điều kiện không đồng bộ.";
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
            return;
        }

        // Validate wareId
        String userId = user.getCode();
        if (userId == null || userId.trim().isEmpty()) {
            errorMessage = "Mã nhân viên không được để trống.";
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
            //Save export
            int exportId = dao.saveExport(export);
            if (exportId <= 0) {
                errorMessage = "Không thể lưu phiếu xuất. Vui lòng thử lại.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }
            // Process export details
            List<ExportDetail> detailList = new ArrayList<>();
            for (int i = 0; i < materialCodes.length; i++) {
                if (materialCodes[i] == null || materialCodes[i].trim().isEmpty()) {
                    errorMessage = "Mã vật tư không được để trống tại dòng " + (i + 1);
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i); // Set error row index
                    request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                    return;
                }
                if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                    errorMessage = "Số lượng không được để trống tại dòng " + (i + 1);
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i);
                    request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                    return;
                }
                if (conditions[i] == null || conditions[i].trim().isEmpty()) {
                    errorMessage = "Điều kiện không được để trống tại dòng " + (i + 1);
                    request.setAttribute("error", errorMessage);
                    request.setAttribute("errorRow", i);
                    request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                    return;
                }
                try {
                    int materialId = Integer.parseInt(materialCodes[i]);
                    int quantity = Integer.parseInt(quantities[i]);
                    if (quantity <= 0) {
                        errorMessage = "Số lượng phải lớn hơn 0 tại dòng " + (i + 1);
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
                    errorMessage = "Mã vật tư hoặc số lượng không hợp lệ tại dòng " + (i + 1);
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
                errorMessage = "Lỗi khi lưu chi tiết phiếu xuất. Vui lòng thử lại.";
                request.setAttribute("error", errorMessage);
                request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);
                return;
            }

            // Success
            request.setAttribute("message", "Phiếu xuất đã được lưu thành công!");
            request.setAttribute("exportId", exportId);
            request.getRequestDispatcher("./exportMaterial.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "Lỗi hệ thống khi xử lý xuất kho. Vui lòng thử lại hoặc liên hệ quản trị viên.";
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
