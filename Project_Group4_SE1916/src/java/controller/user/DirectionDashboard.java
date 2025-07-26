/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.user;

import Dal.DBContext;
import dao.DashboardWarehouseDAO;
import dao.InventoryDAO;
import dao.ProposalDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.time.Year;
import java.util.List;
import java.util.Map;
import model.Inventory;
import model.InventoryTrendDTO;

/**
 *
 * @author Admin
 */
public class DirectionDashboard extends HttpServlet {
   
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
            out.println("<title>Servlet DirectionDashboard</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet DirectionDashboard at " + request.getContextPath () + "</h1>");
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
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try (Connection conn = DBContext.getConnection()) {
           // 1. Thá»‘ng kÃª tá»•ng quan
            DashboardWarehouseDAO dashboardDAO = new DashboardWarehouseDAO();
            ProposalDAO proposalDAO = new ProposalDAO(Dal.DBContext.getConnection());
            int totalMaterials = dashboardDAO.countTotalMaterials();
            int lowStockThreshold = 10; // NgÆ°á»¡ng váº­t tÆ° sáº¯p háº¿t, cÃ³ thá»ƒ Ä‘iá»u chá»‰nh
            int lowStockCount = dashboardDAO.countLowStockMaterials(lowStockThreshold);
            int pendingProposals = proposalDAO.getPendingProposalsCount(null, null, null, "pending");
            int todayTransactions = dashboardDAO.countTodayTransactions();

            // 2. Biá»ƒu Ä‘á»“
            int year = Year.now().getValue();
            List<InventoryTrendDTO> inventoryTrend = dashboardDAO.getInventoryTrendByMonth(year);
            Map<String, Integer> materialDistribution = dashboardDAO.getMaterialDistributionByParentCategory();

            // 3. Báº£ng váº­t tÆ° sáº¯p háº¿t (láº¥y 5 váº­t tÆ° tá»“n kho tháº¥p nháº¥t)
            InventoryDAO inventoryDAO = new InventoryDAO(Dal.DBContext.getConnection());
            List<Inventory> lowStockMaterials = inventoryDAO.searchInventory(null, null, null, null, null, 1, 5, "ASC");

//            // 4. Báº£ng giao dá»‹ch gáº§n Ä‘Ã¢y (5 giao dá»‹ch nháº­p + 5 giao dá»‹ch xuáº¥t gáº§n nháº¥t)
//            ExportHistoryDAO exportHistoryDAO = new ExportHistoryDAO(Dal.DBContext.getConnection());
//            ImportReceiptDAO importReceiptDAO = new ImportReceiptDAO();
//            List<model.Export> recentExports = exportHistoryDAO.searchExportReceipts(null, null, null, 1, 5);
//            List<model.ImportReceipt> recentImports = importReceiptDAO.searchImportReceipts(null, null, null, 1, 5);

            // ÄÆ°a dá»¯ liá»‡u lÃªn request
            request.setAttribute("totalMaterials", totalMaterials);
            request.setAttribute("lowStockCount", lowStockCount);
            request.setAttribute("pendingProposals", pendingProposals);
            request.setAttribute("todayTransactions", todayTransactions);
            request.setAttribute("inventoryTrend", inventoryTrend);
            request.setAttribute("materialDistribution", materialDistribution);
            request.setAttribute("lowStockMaterials", lowStockMaterials);

            request.getRequestDispatcher("/view/direction/directionDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Lá»—i khi táº£i dashboard nhÃ¢n viÃªn: " + e.getMessage(), e);
        }
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
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
