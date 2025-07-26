/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.user;

import Dal.DBContext;
import dao.DashboardWarehouseDAO;
import dao.InventoryDAO;
import dao.ProposalDAO;
import dao.ExportHistoryDAO;
import dao.ImportReceiptDAO;
import model.Inventory;
import model.InventoryTrendDTO;
import java.util.List;
import java.util.Map;
import java.time.LocalDate;
import java.time.Year;
import java.sql.Date;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.math.BigDecimal;

/**
 *
 * @author Admin
 */
public class AdminDashboard extends HttpServlet {
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AdminDashboard</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminDashboard at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            // 1. Thống kê tổng quan
            DashboardWarehouseDAO dashboardDAO = new DashboardWarehouseDAO();
            ProposalDAO proposalDAO = new ProposalDAO(Dal.DBContext.getConnection());
            int totalMaterials = dashboardDAO.countTotalMaterials();
            int lowStockThreshold = 10; // Ngưỡng vật tư sắp hết, có thể điều chỉnh
            int lowStockCount = dashboardDAO.countLowStockMaterials(lowStockThreshold);
            int pendingProposals = proposalDAO.getPendingProposalsCount(null, null, null, "pending");
            int todayTransactions = dashboardDAO.countTodayTransactions();

            // 2. Lấy tồn kho thực tế hiện tại
            BigDecimal currentTotalStock = dashboardDAO.getCurrentTotalStock();

            // 3. Biểu đồ xuất nhập tồn chính xác
            int year = Year.now().getValue();
            List<InventoryTrendDTO> inventoryTrend = dashboardDAO.getInventoryTrendByMonth(year);
            Map<String, Integer> materialDistribution = dashboardDAO.getMaterialDistributionByParentCategory();

            // 4. Thống kê tổng nhập xuất trong tháng hiện tại
            Map<String, BigDecimal> monthlyStats = dashboardDAO.getCurrentMonthImportExport();
            BigDecimal totalImportThisMonth = monthlyStats.getOrDefault("totalImport", BigDecimal.ZERO);
            BigDecimal totalExportThisMonth = monthlyStats.getOrDefault("totalExport", BigDecimal.ZERO);

            // 5. Bảng vật tư sắp hết (lấy 5 vật tư tồn kho thấp nhất)
            InventoryDAO inventoryDAO = new InventoryDAO(Dal.DBContext.getConnection());
            List<Inventory> lowStockMaterials = inventoryDAO.searchInventory(null, null, null, null, null, 1, 5, "ASC");

//            // 6. Bảng giao dịch gần đây (5 giao dịch nhập + 5 giao dịch xuất gần nhất)
//            ExportHistoryDAO exportHistoryDAO = new ExportHistoryDAO(Dal.DBContext.getConnection());
//            ImportReceiptDAO importReceiptDAO = new ImportReceiptDAO();
//            List<model.Export> recentExports = exportHistoryDAO.searchExportReceipts(null, null, null, 1, 5);
//            List<model.ImportReceipt> recentImports = importReceiptDAO.searchImportReceipts(null, null, null, 1, 5);

            // Đưa dữ liệu lên request
            request.setAttribute("totalMaterials", totalMaterials);
            request.setAttribute("lowStockCount", lowStockCount);
            request.setAttribute("pendingProposals", pendingProposals);
            request.setAttribute("todayTransactions", todayTransactions);
            request.setAttribute("currentTotalStock", currentTotalStock);
            request.setAttribute("totalImportThisMonth", totalImportThisMonth);
            request.setAttribute("totalExportThisMonth", totalExportThisMonth);
            request.setAttribute("inventoryTrend", inventoryTrend);
            request.setAttribute("materialDistribution", materialDistribution);
            request.setAttribute("lowStockMaterials", lowStockMaterials);
//            request.setAttribute("recentExports", recentExports);
//            request.setAttribute("recentImports", recentImports);

            // Forward sang JSP
            request.getRequestDispatcher("/view/admin/adminDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Lỗi lấy dữ liệu dashboard: " + e.getMessage());
        }
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
