//ExportHistory.java
package controller.importhistory;

import Dal.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
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
        // Lấy tham số từ request
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        String exporter = request.getParameter("exporter");
        String pageParam = request.getParameter("page");

        // Thiết lập phân trang
        int page = 1;
        int pageSize = 10;
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {
            }
        }

        // Chuyển đổi ngày
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
            request.setAttribute("errorMessage", "Định dạng ngày không hợp lệ.");
        }
        
        Connection conn = DBContext.getConnection();
        
        // Truy vấn dữ liệu
        ExportHistoryDAO dao = new ExportHistoryDAO();
        List<Export> receipts;
        int totalRecords;

        if (exporter != null && !exporter.trim().isEmpty()) {
            // Tìm kiếm theo tên người xuất
            receipts = dao.searchByExporterName(exporter);
            totalRecords = receipts.size(); // Không phân trang nếu searchByExporterName không hỗ trợ
            System.out.println("Tìm kiếm theo exporter: " + exporter);
            System.out.println("Kích thước results: " + receipts.size());
        } else {
            // Lấy tất cả dữ liệu với bộ lọc ngày và phân trang
            receipts = dao.searchExportReceipts(fromDate, toDate, exporter, page, pageSize);
            totalRecords = dao.countExportReceipts(fromDate, toDate, exporter);
            System.out.println("Kích thước receipts: " + receipts.size());
            System.out.println("Tổng số bản ghi: " + totalRecords);
        }

        // Tính toán số trang
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        // Đặt thuộc tính cho JSP
        request.setAttribute("historyData", receipts);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("fromDate", fromDateStr);
        request.setAttribute("toDate", toDateStr);
        request.setAttribute("exporter", exporter);

        // Chuyển tiếp đến JSP
        request.getRequestDispatcher("exportHistory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // Gọi doGet để xử lý POST nếu cần
    }

    @Override
    public String getServletInfo() {
        return "Servlet to handle export history requests";
    }
}