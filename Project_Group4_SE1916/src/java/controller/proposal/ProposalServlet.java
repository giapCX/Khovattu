/*
 * Click .netbeans.org/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click .netbeans.org/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.proposal;

import Dal.DBContext;
import dao.MaterialCategoryDAO;
import dao.MaterialDAO;
import dao.ProposalDAO;
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
import model.Material;
import model.MaterialCategory;
import model.Proposal;
import model.ProposalDetails;

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
        String[] quantities = request.getParameterValues("quantity[]");
        String[] materialConditions = request.getParameterValues("materialCondition[]");

        if (materialIds == null || quantities == null || materialConditions == null || materialIds.length == 0) {
            request.setAttribute("error", "Missing proposal details");
            request.getRequestDispatcher("/view/proposal/proposalOfEmployee.jsp").forward(request, response);
            return;
        }

        Proposal proposal = new Proposal();
        proposal.setProposalType(proposalType);
        proposal.setProposerId(proposerId);
        proposal.setNote(note);
        proposal.setProposalSentDate(new Timestamp(System.currentTimeMillis()));
        proposal.setFinalStatus("pending");

        List<ProposalDetails> proposalDetailsList = new ArrayList<>();
        for (int i = 0; i < materialIds.length; i++) {
            ProposalDetails proposalDetail = new ProposalDetails();
            proposalDetail.setProposal(proposal);
            try {
                proposalDetail.setMaterialId(Integer.parseInt(materialIds[i]));
                proposalDetail.setQuantity(Double.parseDouble(quantities[i]));
                proposalDetail.setMaterialCondition(materialConditions[i]);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid quantity or material ID");
                request.getRequestDispatcher("/view/proposal/proposalOfEmployee.jsp").forward(request, response);
                return;
            }
            proposalDetailsList.add(proposalDetail);
        }

        proposal.setProposalDetails(proposalDetailsList);

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            boolean isInserted = proposalDAO.addProposal(proposal);
            if (isInserted) {
                request.setAttribute("message", "Proposal material sent successfully");
                request.getRequestDispatcher("/view/proposal/proposalOfEmployee.jsp").forward(request, response);
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