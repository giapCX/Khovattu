/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.user;

import Dal.DBContext;
import dao.DashboardWarehouseDAO;
import dao.ProposalDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;

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
            int totalToBeExecute = proposalDAO.countProposalsByTypeExecuteStatusFromStartDateToEndDate(proposalTypes, "approved_but_not_executed", null, null);
            int totalMaterials = dao.countTotalMaterials();
            int lowStock = dao.countLowStockMaterials(10);
            int todayTransactions = dao.countTodayTransactions();
            request.setAttribute("totalMaterials", totalMaterials);
            request.setAttribute("lowStock", lowStock);
            request.setAttribute("todayTransactions", todayTransactions);
            request.setAttribute("totalToBeExecute", totalToBeExecute);
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
