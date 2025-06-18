/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
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
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import model.Material;
import model.MaterialCategory;
import model.Proposal;
import model.ProposalDetails;

/**
 *
 * @author Admin
 */
public class ProposalServlet extends HttpServlet {

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
            out.println("<title>Servlet ProposalServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProposalServlet at " + request.getContextPath() + "</h1>");
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
        String proposalType = request.getParameter("proposalType");
        HttpSession session = request.getSession();
        Integer proposerId = (Integer) session.getAttribute("userId");
        String note = request.getParameter("note");
        String[] materialIds = request.getParameterValues("materialId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] materialConditions = request.getParameterValues("materialCondition[]");

        Proposal proposal = new Proposal();
        proposal.setProposalType(proposalType);
        proposal.setProposerId(proposerId);
        proposal.setNote(note);

        List<ProposalDetails> proposalDetailsList = new ArrayList<>();
        for (int i = 0; i < materialIds.length; i++) {
            ProposalDetails proposalDetail = new ProposalDetails();
            proposalDetail.setProposal(proposal);
            proposalDetail.setMaterialId(Integer.parseInt(materialIds[i]));
            proposalDetail.setQuantity(Double.parseDouble(quantities[i]));
            proposalDetail.setMaterialCondition(materialConditions[i]);
            proposalDetailsList.add(proposalDetail);
        }

        proposal.setProposalDetails(proposalDetailsList);

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);

            boolean isInserted = proposalDAO.addProposal(proposal);
            if (isInserted) {
                request.setAttribute("message", "Proposal material sent success");
                request.getRequestDispatcher("/view/proposal/proposalOfEmployee.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "error");
                request.getRequestDispatcher("/view/proposal/proposalOfEmployee.jsp").forward(request, response);
            }
        } catch (Exception e) {
            throw new ServletException(e);
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
