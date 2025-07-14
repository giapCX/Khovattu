//exportHisDetailServlet
package controller.importhistory;

import dao.ExportDetailDAO;
import dao.ExportHistoryDAO;
import model.ExportDetail;
import model.Export;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;


public class ExportHistoryDetailServlet extends HttpServlet {
    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get parameters
            String exportIdRaw = request.getParameter("exportId");

            // Check null
            if (exportIdRaw == null || exportIdRaw.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing exportId");
                return;
            }

            int exportId;
            try {
                exportId = Integer.parseInt(exportIdRaw);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid exportId");
                return;
            }

            String materialName = request.getParameter("materialName");
            String constructionSite = request.getParameter("constructionSite");
            String reason = request.getParameter("reason");
            String pageRaw = request.getParameter("page");

            int page = 1;
            if (pageRaw != null) {
                try {
                    page = Integer.parseInt(pageRaw);
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            ExportDetailDAO exportDetailDAO = new ExportDetailDAO();
            ExportHistoryDAO dao = new ExportHistoryDAO();
            Export receipt = dao.getReceiptById(exportId);
            if (receipt == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Export receipt not found");
                return;
            }

            // Get details based on parameters
            List<ExportDetail> details;
            if ((materialName != null && !materialName.isEmpty()) || 
                (constructionSite != null && !constructionSite.isEmpty()) || 
                (reason != null && !reason.isEmpty())) {
                details = exportDetailDAO.searchByCriteria(exportId, materialName, constructionSite, reason, page, PAGE_SIZE);
            } else {
                details = exportDetailDAO.getByExportId(exportId, page, PAGE_SIZE);
            }

            // Calculate total pages
            int totalItems = exportDetailDAO.countSearchByCriteria(exportId, materialName, constructionSite, reason);
            int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);

            // Set attributes
            request.setAttribute("receipt", receipt);
            request.setAttribute("details", details);
            request.setAttribute("exportId", exportId);
            request.setAttribute("materialName", materialName);
            request.setAttribute("constructionSite", constructionSite);
            request.setAttribute("reason", reason);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);

            // Forward to JSP
            request.getRequestDispatcher("viewExportHistoryDetail.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error occurred while retrieving export details", e);
        }
    }
}
