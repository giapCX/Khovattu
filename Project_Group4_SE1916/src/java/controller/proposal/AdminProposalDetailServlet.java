/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.proposal;

import Dal.DBContext;

import dao.ProposalDAO;
import model.Proposal;
import java.sql.SQLException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import model.ProposalApprovals;

/**
 *
 * @author quanh
 */
public class AdminProposalDetailServlet extends HttpServlet {

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
            out.println("<title>Servlet AdminProposalDetailServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminProposalDetailServlet at " + request.getContextPath() + "</h1>");
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
        try (Connection conn = new DBContext().getConnection()) {
            String rawId = request.getParameter("proposalId");
            if (rawId == null || !rawId.matches("\\d+")) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid proposal ID");
                return;
            }
            int proposalId = Integer.parseInt(rawId);
            ProposalDAO dao = new ProposalDAO(conn);

            Proposal proposal = dao.getProposalById(proposalId);
            if (proposal == null) {
                System.err.println("Proposal not found for ID: " + proposalId);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Proposal not found.");
                return;
            }
            ProposalApprovals approval = dao.getApprovalByProposalId(proposalId);
            proposal.setApproval(approval);
            request.setAttribute("proposal", proposal);
            request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            System.err.println("Invalid proposal ID format: " + request.getParameter("proposalId"));
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid proposal ID.");
        } catch (SQLException e) {
            System.err.println("Database error loading proposal detail for ID: " + request.getParameter("proposalId"));
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading proposal detail.");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unexpected error occurred.");
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
