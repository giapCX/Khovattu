/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.proposal;

import Dal.DBContext;
import dao.ConstructionSiteDAO;
import dao.MaterialCategoryDAO;
import dao.MaterialDAO;
import dao.ProposalDAO;
import dao.SupplierDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.ConstructionSite;
import model.Material;
import model.MaterialCategory;
import model.Proposal;
import model.ProposalDetails;
import model.Supplier;

/**
 *
 * @author Admin
 */
public class EditProposalServlet extends HttpServlet {

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
            out.println("<title>Servlet EditProposalServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditProposalServlet at " + request.getContextPath() + "</h1>");
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
            request.setAttribute("proposal", proposal);
            MaterialCategoryDAO categoryDAO = new MaterialCategoryDAO();
            MaterialDAO materialDAO = new MaterialDAO();
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();
            List<MaterialCategory> childCategories = categoryDAO.getAllChildCategories();
            List<Material> material = materialDAO.getAllMaterials();
            SupplierDAO supplierDAO = new SupplierDAO(conn);
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            ConstructionSiteDAO constructionSiteDAO = new ConstructionSiteDAO(conn);
            List<ConstructionSite> constructionSites = constructionSiteDAO.getAllConstructionSites();
            request.setAttribute("constructionSites", constructionSites);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("proposalId", proposalId);
            request.setAttribute("proposerId", proposal.getProposerId());
            request.setAttribute("material", material);
            request.setAttribute("parentCategories", parentCategories);
            request.setAttribute("childCategories", childCategories);
            request.getRequestDispatcher("/view/proposal/editProposalOfEmployee.jsp").forward(request, response);
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
        Integer proposalId = Integer.parseInt(request.getParameter("proposalId"));
        String proposalType = request.getParameter("proposalType");
        HttpSession session = request.getSession();
        Integer proposerId = (Integer) session.getAttribute("userId");
        if (proposerId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not logged in");
            return;
        }
        String note = request.getParameter("note");
        String[] materialIds = request.getParameterValues("materialId[]");
        String[] units = request.getParameterValues("unit[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] conditions = request.getParameterValues("materialCondition[]");
        String supplierIdStr = request.getParameter("supplierId");
        String[] priceStrings = request.getParameterValues("pricePerUnit[]");
        String siteIdStr = request.getParameter("siteId");
        Proposal proposal = new Proposal();
        if ("import_from_supplier".equals(proposalType)) {
            if (supplierIdStr != null && !supplierIdStr.isEmpty()) {
                proposal.setSupplierId(Integer.parseInt(supplierIdStr));
            }
        } else if ("export".equals(proposalType) || "import_returned".equals(proposalType)) {
            if (siteIdStr != null && !siteIdStr.isEmpty()) {
                proposal.setSiteId(Integer.parseInt(siteIdStr));
            }
        }

        List<Double> prices = new ArrayList<>();

        if (priceStrings != null) {
            for (String priceStr : priceStrings) {
                try {
                    priceStr = priceStr.trim();
                    BigDecimal priceDecimal = new BigDecimal(priceStr);
                    prices.add(priceDecimal.doubleValue());
                } catch (NumberFormatException e) {
                    prices.add(0.0);
                }
            }
        }

        proposal.setProposalType(proposalType);
        proposal.setProposerId(proposerId);
        proposal.setNote(note);
        proposal.setProposalSentDate(new Timestamp(System.currentTimeMillis()));
        proposal.setFinalStatus("pending");

        List<ProposalDetails> details = new ArrayList<>();
        for (int i = 0; i < materialIds.length; i++) {
            ProposalDetails detail = new ProposalDetails();
            detail.setMaterialId(Integer.parseInt(materialIds[i]));
            detail.setQuantity(Integer.parseInt(quantities[i]));
            detail.setUnit(units[i]);
            detail.setMaterialCondition(conditions[i]);

            if ("import_from_supplier".equals(proposalType)) {
                if (prices != null && i < prices.size() && prices.get(i) != null) {
                    detail.setPrice(prices.get(i));
                }
            }
            details.add(detail);
        }

        proposal.setProposalDetails(details);

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            boolean isInserted = proposalDAO.updateProposalById(proposalId, proposal);
            proposalDAO.updateApprovedByProposalId(proposalId);
            if (isInserted) {
                response.sendRedirect("ListProposalServlet");
            } else {
                request.setAttribute("error", "Failed to submit proposal");
                request.getRequestDispatcher("/view/proposal/proposalOfEmployee.jsp").forward(request, response);
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
