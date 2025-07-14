/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.importhistory;

import Dal.DBContext;
import dao.ImportDAO;
import dao.ProposalDAO;
import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Import;
import model.ImportDetail;
import model.Proposal;
import model.ProposalApprovals;
import model.ProposalDetails;
import model.User;

/**
 *
 * @author Admin
 */
public class ImportServlet extends HttpServlet {

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
            out.println("<title>Servlet ImportServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ImportServlet at " + request.getContextPath() + "</h1>");
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
        Integer proposalId = Integer.parseInt(request.getParameter("proposalId"));
        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            Proposal proposal = proposalDAO.getProposalWithDetailsById(proposalId);
            UserDAO userDAO = new UserDAO();
            List<User> activeUsers = userDAO.getAllActiveUsers();
            request.setAttribute("activeUsers", activeUsers);
            request.setAttribute("proposal", proposal);
            request.setAttribute("proposalId", proposalId);
            request.setAttribute("proposerId", proposal.getProposerId());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
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
        String proposalId = request.getParameter("proposalId");
        String proposalType = request.getParameter("proposalType");

        HttpSession session = request.getSession();
        Integer executorId = (Integer) session.getAttribute("userId");
        if (executorId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not logged in");
            return;
        }
        String note = request.getParameter("note");
        String[] materialIds = request.getParameterValues("materialId[]");
        String[] units = request.getParameterValues("unit[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] conditions = request.getParameterValues("materialCondition[]");
        
        
        

        Import importOb = new Import();
        importOb.setProposalId(Integer.parseInt(proposalId));
        importOb.setImportType(proposalType);

        importOb.setNote(note);
        importOb.setImportDate(new Timestamp(System.currentTimeMillis()));

        List<ImportDetail> details = new ArrayList<>();

        for (int i = 0; i < materialIds.length; i++) {
            ImportDetail detail = new ImportDetail();
            detail.setMaterialId(Integer.parseInt(materialIds[i]));
            detail.setQuantity(Double.parseDouble(quantities[i]));
            detail.setUnit(units[i]);
            detail.setMaterialCondition(conditions[i]);

            if ("import_from_supplier".equals(proposalType)) {
                String[] supplierIds = request.getParameterValues("supplierIds[]");
                if (supplierIds != null && i < supplierIds.length && supplierIds[i] != null && !supplierIds[i].isEmpty()) {
                    detail.setSupplierId(Integer.parseInt(supplierIds[i]));
                }
                String[] prices = request.getParameterValues("pricePerUnit[]");
                if (prices != null && i < prices.length && prices[i] != null && !prices[i].isEmpty()) {
                    detail.setPrice(Double.parseDouble(prices[i]));
                }

            } else if ("import_returned".equals(proposalType)) {
                String[] siteIds = request.getParameterValues("siteId[]");
                if (siteIds != null && i < siteIds.length && siteIds[i] != null && !siteIds[i].isEmpty()) {
                    detail.setSiteId(Integer.parseInt(siteIds[i]));
                }
                String responsibleId = request.getParameter("responsibleId");
                importOb.setResponsibleId(Integer.parseInt(responsibleId));
            }

            details.add(detail);

        }
        importOb.setImportDetail(details);

        try (Connection conn = DBContext.getConnection()) {
            ImportDAO importDAO = new ImportDAO(conn);
            boolean isInserted = importDAO.addImport(importOb);
            importDAO.addToInventory(details);
            importDAO.updateProposalStatusToExecuted(Integer.parseInt(proposalId));
            if (isInserted) {
                response.sendRedirect("ListImportServlet");
            } else {
                request.setAttribute("error", "Failed to submit proposal");
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
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
