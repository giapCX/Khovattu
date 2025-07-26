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
public class WarehouseDashboard extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
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
            out.println("<title>Servlet WarehouseDashboard</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet WarehouseDashboard at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try (Connection conn = DBContext.getConnection()) {
            HttpSession session = request.getSession(false);

            if (session == null || session.getAttribute("userId") == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            DashboardWarehouseDAO dao = new DashboardWarehouseDAO();
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            // Filter proposals by import_from_supplier and import_returned types
            String[] proposalTypes = new String[]{"import_from_supplier", "import_returned"};
            int totalToBeExecute = proposalDAO.countProposalsByTypeAndSearch("", "");
            int totalMaterials = dao.countTotalMaterials();
            int lowStock = dao.countLowStockMaterials(10);
            int todayTransactions = dao.countTodayTransactions();
            
            // 2. Biểu đồ
            int year = Year.now().getValue();
            List<InventoryTrendDTO> inventoryTrend = dao.getInventoryTrendByMonth(year);
            Map<String, Integer> materialDistribution = dao.getMaterialDistributionByParentCategory();

            // 3. Bảng vật tư sắp hết (lấy 5 vật tư tồn kho thấp nhất)
            InventoryDAO inventoryDAO = new InventoryDAO(Dal.DBContext.getConnection());
            List<Inventory> lowStockMaterials = inventoryDAO.searchInventory(null, null, null, null, null, 1, 5, "ASC");
            
            request.setAttribute("totalMaterials", totalMaterials);
            request.setAttribute("lowStock", lowStock);
            request.setAttribute("todayTransactions", todayTransactions);
            request.setAttribute("totalToBeExecute", totalToBeExecute);
            request.setAttribute("inventoryTrend", inventoryTrend);
            request.setAttribute("materialDistribution", materialDistribution);
            request.setAttribute("lowStockMaterials", lowStockMaterials);
            request.getRequestDispatcher("/view/warehouse/warehouseDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Lỗi khi tải dashboard nhân viên: " + e.getMessage(), e);
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
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
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
