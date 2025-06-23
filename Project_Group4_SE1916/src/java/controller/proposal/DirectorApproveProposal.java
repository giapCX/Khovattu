package controller.proposal;

import dao.ProposalDAO;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Proposal;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import Dal.DBContext;


public class DirectorApproveProposal extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String proposalIdStr = request.getParameter("id");
        if (proposalIdStr == null || proposalIdStr.isEmpty()) {
            request.setAttribute("error", "Proposal ID is required.");
            request.getRequestDispatcher("view/direction/directorProposalsHistory.jsp").forward(request, response);
            return;
        }

        int proposalId;
        try {
            proposalId = Integer.parseInt(proposalIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid Proposal ID.");
            request.getRequestDispatcher("view/direction/directorProposalsHistory.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            Proposal proposal = proposalDAO.getProposalById(proposalId);
            if (proposal == null) {
                request.setAttribute("error", "Proposal not found.");
                request.getRequestDispatcher("view/direction/directorProposalsHistory.jsp").forward(request, response);
                return;
            }

            request.setAttribute("proposal", proposal);
            request.getRequestDispatcher("view/direction/directorApproveProposal.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer directorId = (Integer) session.getAttribute("userId");
        if (directorId == null) {
            request.setAttribute("error", "Please login as a director.");
            request.getRequestDispatcher("view/direction/directorProposalsHistory.jsp").forward(request, response);
            return;
        }

        String proposalIdStr = request.getParameter("proposalId");
        String directorStatus = request.getParameter("directorStatus");
        String directorReason = request.getParameter("directorReason");
        String directorNote = request.getParameter("directorNote");

        if (proposalIdStr == null || directorStatus == null || directorStatus.isEmpty()) {
            request.setAttribute("error", "Proposal ID and status are required.");
            request.getRequestDispatcher("view/direction/directorApproveProposal.jsp").forward(request, response);
            return;
        }

        if ("rejected".equals(directorStatus) && (directorReason == null || directorReason.trim().isEmpty())) {
            request.setAttribute("error", "Reason is required when rejecting a proposal.");
            request.getRequestDispatcher("view/direction/directorApproveProposal.jsp").forward(request, response);
            return;
        }

        int proposalId;
        try {
            proposalId = Integer.parseInt(proposalIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid Proposal ID.");
            request.getRequestDispatcher("view/direction/directorApproveProposal.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            proposalDAO.directorUpdateProposal(proposalId, directorStatus, directorReason, directorNote, directorId);
            request.setAttribute("message", "Proposal updated successfully.");
            response.sendRedirect(request.getContextPath() + "/proposals");
        } catch (SQLException e) {
            request.setAttribute("error", "Error updating proposal: " + e.getMessage());
            request.getRequestDispatcher("view/direction/directorApproveProposal.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for director to approve or reject proposals";
    }
}