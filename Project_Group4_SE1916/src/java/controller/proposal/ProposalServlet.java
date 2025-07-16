/*
 * Click .netbeans.org/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click .netbeans.org/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
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
public class ProposalServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ProposalServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProposalServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            MaterialCategoryDAO categoryDAO = new MaterialCategoryDAO();
            MaterialDAO materialDAO = new MaterialDAO();
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();
            List<MaterialCategory> childCategories = categoryDAO.getAllChildCategories();
            List<Material> material = materialDAO.getAllMaterials();
            Connection conn = DBContext.getConnection();
            SupplierDAO supplierDAO = new SupplierDAO(conn);
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            ConstructionSiteDAO constructionSiteDAO = new ConstructionSiteDAO(conn);
            List<ConstructionSite> constructionSites = constructionSiteDAO.getAllConstructionSites();
            request.setAttribute("constructionSites", constructionSites);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("material", material);
            request.setAttribute("parentCategories", parentCategories);
            request.setAttribute("childCategories", childCategories);
            request.getRequestDispatcher("/view/proposal/proposalOfEmployee.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Error " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
        String[] prices = request.getParameterValues("pricePerUnit[]");
        String siteIdStr = request.getParameter("siteId");

        Proposal proposal = new Proposal();
        proposal.setProposalType(proposalType);
        proposal.setProposerId(proposerId);
        proposal.setNote(note);
        proposal.setProposalSentDate(new Timestamp(System.currentTimeMillis()));
        proposal.setFinalStatus("pending");

        List<ProposalDetails> details = new ArrayList<>();
        if ("import_from_supplier".equals(proposalType)) {
            if (supplierIdStr != null && !supplierIdStr.isEmpty()) {
                proposal.setSupplierId(Integer.parseInt(supplierIdStr));
            }
        } else if ("export".equals(proposalType) || "import_returned".equals(proposalType)) {
            if (siteIdStr != null && !siteIdStr.isEmpty()) {
                proposal.setSiteId(Integer.parseInt(siteIdStr));
            }
        }
        for (int i = 0; i < materialIds.length; i++) {
            ProposalDetails detail = new ProposalDetails();
            detail.setMaterialId(Integer.parseInt(materialIds[i]));
            detail.setQuantity(Integer.parseInt(quantities[i]));
            detail.setUnit(units[i]);
            detail.setMaterialCondition(conditions[i]);
            if ("import_from_supplier".equals(proposalType)) {
                if (prices != null && i < prices.length && prices[i] != null && !prices[i].isEmpty()) {
                    detail.setPrice(Double.parseDouble(prices[i]));
                }
            }

            details.add(detail);
        }
        proposal.setProposalDetails(details);

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            boolean isInserted = proposalDAO.addProposal(proposal);
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

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
