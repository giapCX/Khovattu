package controller.proposal;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import Dal.DBContext;
import dao.ProposalDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.SQLException;

/**
 *
 * @author quanh
 */
public class AdminUpdateProposalServlet extends HttpServlet {

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
            out.println("<title>Servlet AdminUpdateProposalServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminUpdateProposalServlet at " + request.getContextPath() + "</h1>");
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
        processRequest(request, response);
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
        try (Connection conn = new DBContext().getConnection()) {
            String adminStatus = request.getParameter("adminStatus");
            String adminReason = request.getParameter("adminReason");
            String adminNote = request.getParameter("adminNote");
            String rawProposalId = request.getParameter("proposalId");
            String rawAdminApproverId = request.getParameter("adminApproverId");

            if (rawProposalId == null || !rawProposalId.matches("\\d+")
                    || rawAdminApproverId == null || !rawAdminApproverId.matches("\\d+")) {
                System.err.println("Invalid input format: proposalId=" + rawProposalId + ", adminApproverId=" + rawAdminApproverId);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid input format.");
                return;
            }

            int proposalId = Integer.parseInt(rawProposalId);
            int adminApproverId = Integer.parseInt(rawAdminApproverId);

            // Validate input
            if (adminStatus == null || !adminStatus.matches("approved|rejected")) {
                System.err.println("Invalid admin status: " + adminStatus);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid status provided.");
                return;
            }
            if (adminReason == null) {
                adminReason = "";
            }
            if (adminNote == null) {
                adminNote = "";
            }

            ProposalDAO dao = new ProposalDAO(conn);
            dao.adminUpdateProposal(proposalId, adminStatus, adminReason, adminNote, adminApproverId);

            request.getSession().setAttribute("successMessage", "Proposal updated successfully.");
            response.sendRedirect(request.getContextPath() + "/AdminApproveServlet");

        } catch (NumberFormatException e) {
            System.err.println("Invalid input format for proposalId or adminApproverId");
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid input format.");

        } catch (SQLException e) {
            String errorMessage = e.getMessage();
            System.err.println("Database error updating proposal ID: " + request.getParameter("proposalId"));
            e.printStackTrace();

            if (errorMessage != null && errorMessage.contains("only update when admin_status is 'pending'")) {
                request.getSession().setAttribute("errorMessage", "This proposal has already been processed.");
                response.sendRedirect(request.getContextPath() + "/AdminProposalDetailServlet?proposalId=" + request.getParameter("proposalId"));
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error updating proposal.");
            }

        } catch (Exception e) {
            System.err.println("Unexpected error updating proposal");
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unexpected error occurred.");
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
