/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.user;

import java.sql.Connection;
import Dal.DBContext;
import dao.ProposalDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author Admin
 */
public class EmployeeDashboard extends HttpServlet {

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
            out.println("<title>Servlet EmployeeDashboard</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EmployeeDashboard at " + request.getContextPath() + "</h1>");
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

            int userId = (Integer) session.getAttribute("userId");

            ProposalDAO proposalDAO = new ProposalDAO(conn);
            int totalPending = proposalDAO.countProposalsByProposerTypeStatusFromStartDateToEndDate(userId, "", "pending", null, null);
            int totalExecuted = proposalDAO.countProposalsByProposerTypeStatusFromStartDateToEndDate(userId, "", "executed", null, null);
            int totalRejected = proposalDAO.countProposalsByProposerTypeStatusFromStartDateToEndDate(userId, "", "rejected", null, null);

            request.setAttribute("totalPending", totalPending);
            request.setAttribute("totalExecuted", totalExecuted);
            request.setAttribute("totalRejected", totalRejected);

            request.getRequestDispatcher("/view/employee/employeeDashboard.jsp").forward(request, response);
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
        try (Connection conn = DBContext.getConnection()) {
            HttpSession session = request.getSession(false);

            if (session == null || session.getAttribute("userId") == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            int userId = (Integer) session.getAttribute("userId");

            ProposalDAO proposalDAO = new ProposalDAO(conn);
            int totalPending = proposalDAO.countProposalsByProposerTypeStatusFromStartDateToEndDate(userId, "", "pending", null, null);
            int totalExecuted = proposalDAO.countProposalsByProposerTypeStatusFromStartDateToEndDate(userId, "", "executed", null, null);
            int totalRejected = proposalDAO.countProposalsByProposerTypeStatusFromStartDateToEndDate(userId, "", "rejected", null, null);

            request.setAttribute("totalPending", totalPending);
            request.setAttribute("totalExecuted", totalExecuted);
            request.setAttribute("totalRejected", totalRejected);

            request.getRequestDispatcher("/view/employee/employeeDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Lỗi khi tải dashboard nhân viên: " + e.getMessage(), e);
        }

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
