package controller.importhistory;

import Dal.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import model.Export;
import dao.ExportHistoryDAO;
import java.sql.Connection;

public class ExportHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Retrieve parameters from the request
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        String exporter = request.getParameter("exporter");
        String pageParam = request.getParameter("page");

        // Set up pagination
        int page = (pageParam != null && !pageParam.isEmpty()) ? Integer.parseInt(pageParam) : 1;
        int pageSize = 10;

        // Convert dates
        Date fromDate = null;
        Date toDate = null;
        try {
            if (fromDateStr != null && !fromDateStr.isEmpty()) {
                fromDate = java.sql.Date.valueOf(fromDateStr);
            }
            if (toDateStr != null && !toDateStr.isEmpty()) {
                toDate = java.sql.Date.valueOf(toDateStr);
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Invalid date format.");
        }

        // Get database connection
        Connection conn = DBContext.getConnection();

        // Query data
        ExportHistoryDAO dao = new ExportHistoryDAO(conn);
        List<Export> receipts;
        int totalRecords;

        // Handle default action (display all) or search-based action
        if ((exporter != null && !exporter.trim().isEmpty()) || fromDate != null || toDate != null) {
            // Search by exporter name and/or dates
            receipts = dao.searchExportReceipts(fromDate, toDate, exporter, page, pageSize);
            totalRecords = dao.countExportReceipts(fromDate, toDate, exporter);
            System.out.println("Searching by exporter: " + exporter + ", fromDate: " + fromDate + ", toDate: " + toDate);
            System.out.println("Result size: " + receipts.size());
        } else {
            // Display all records by default
            receipts = dao.searchExportReceipts(null, null, null, page, pageSize);
            totalRecords = dao.countExportReceipts(null, null, null);
        }

        System.out.println("Receipts size: " + receipts.size());
        System.out.println("Total records: " + totalRecords);

        // Calculate total pages
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        // Set attributes for JSP
        request.setAttribute("historyData", receipts);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("fromDate", fromDateStr);
        request.setAttribute("toDate", toDateStr);
        request.setAttribute("exporter", exporter);

        // Forward to JSP
        request.getRequestDispatcher("exportHistory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // Call doGet to handle POST if needed
    }

    @Override
    public String getServletInfo() {
        return "Servlet to handle warehouse export history requests";
    }
}