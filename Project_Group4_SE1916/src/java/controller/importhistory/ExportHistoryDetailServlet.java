
package controller.importhistory;

import dao.ExportDetailDAO;
import model.ExportDetail;
import model.Export;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;


public class ExportHistoryDetailServlet extends HttpServlet {
    private static final int PAGE_SIZE = 10;
    private ExportDetailDAO exportDetailDAO;

    @Override
    public void init() throws ServletException {
        exportDetailDAO = new ExportDetailDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get parameters
            int exportId = Integer.parseInt(request.getParameter("exportId"));
            String keyword = request.getParameter("keyword");
            String sort = request.getParameter("sort");
            int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;

            // Get receipt from session or database (assuming it's stored in session)
            Export receipt = (Export) request.getSession().getAttribute("receipt");

            // Get details based on parameters
            List<ExportDetail> details;
            if (keyword != null && !keyword.isEmpty() && sort != null && !sort.isEmpty()) {
                details = exportDetailDAO.searchAndSortByQuantity(exportId, keyword, sort, page, PAGE_SIZE);
            } else if (keyword != null && !keyword.isEmpty()) {
                details = exportDetailDAO.searchByName(exportId, keyword, page, PAGE_SIZE);
            } else if (sort != null && !sort.isEmpty()) {
                details = exportDetailDAO.sortByQuantity(exportId, sort, page, PAGE_SIZE);
            } else {
                details = exportDetailDAO.getByExportId(exportId, page, PAGE_SIZE);
            }

            // Calculate total pages
            int totalItems = exportDetailDAO.countSearch(exportId, keyword);
            int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);

            // Set attributes
            request.setAttribute("receipt", receipt);
            request.setAttribute("details", details);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);

            // Forward to JSP
            request.getRequestDispatcher("/viewExportHistoryDetail.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error occurred while retrieving export details", e);
        }
    }
}