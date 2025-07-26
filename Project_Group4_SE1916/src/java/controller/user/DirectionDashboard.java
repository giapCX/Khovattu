/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.user;

import Dal.DBContext;
import dao.DashboardDirectorDAO;
import dao.DashboardWarehouseDAO;
import dao.InventoryDAO;
import dao.ProposalDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.time.Year;
import model.ImportPrice;
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
        try (java.io.PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet DirectionDashboard</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet DirectionDashboard at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

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
            DashboardWarehouseDAO dashboardWarehouseDAO = new DashboardWarehouseDAO();
            DashboardDirectorDAO dashboardDirectorDAO = new DashboardDirectorDAO();
            ProposalDAO proposalDAO = new ProposalDAO(DBContext.getConnection());
            InventoryDAO inventoryDAO = new InventoryDAO(DBContext.getConnection());

            // Fetch dashboard metrics
            int totalMaterials = dashboardDirectorDAO.countTotalMaterials();
            int lowStockThreshold = 10;
            int lowStockCount = dashboardDirectorDAO.countLowStockMaterials(lowStockThreshold);
            int pendingProposals = proposalDAO.getPendingProposalsCount(null, null, null, "pending");
            int todayTransactions = dashboardWarehouseDAO.countTodayTransactions();
            int activeSuppliers = dashboardDirectorDAO.countActiveSuppliers();
            int ongoingSites = dashboardDirectorDAO.countOngoingSites();
            int activeUsers = dashboardDirectorDAO.countUsers();
            int year = Year.now().getValue();
            List<ImportPrice> averageImportPrices = dashboardDirectorDAO.getAverageImportPricesByMonth(year);
            Map<String, Integer> materialDistribution = dashboardWarehouseDAO.getMaterialDistributionByParentCategory();
            List<Inventory> lowStockMaterials = inventoryDAO.searchInventory(null, null, null, null, null, 1, 5, "ASC");

            // Set request attributes
            request.setAttribute("totalMaterials", totalMaterials);
            request.setAttribute("lowStockCount", lowStockCount);
            request.setAttribute("pendingProposals", pendingProposals);
            request.setAttribute("todayTransactions", todayTransactions);
            request.setAttribute("activeSuppliers", activeSuppliers);
            request.setAttribute("ongoingSites", ongoingSites);
            request.setAttribute("activeUsers", activeUsers);
            request.setAttribute("averageImportPrices", averageImportPrices);
            request.setAttribute("materialDistribution", materialDistribution);
            request.setAttribute("lowStockMaterials", lowStockMaterials);

            request.getRequestDispatcher("/view/direction/directionDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Lỗi khi tải dashboard: " + e.getMessage(), e);
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
        return "Director Dashboard Servlet";
    }
}