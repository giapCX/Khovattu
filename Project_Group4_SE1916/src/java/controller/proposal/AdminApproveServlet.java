package controller.proposal;

import dao.ProposalDAO;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import Dal.DBContext;
import java.util.List;
import model.Proposal;

public class AdminApproveServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Retrieve parameters
        String search = request.getParameter("search") != null ? request.getParameter("search") : "";
        String dateFrom = request.getParameter("dateFrom") != null ? request.getParameter("dateFrom") : "";
        String dateTo = request.getParameter("dateTo") != null ? request.getParameter("dateTo") : "";
        String status = request.getParameter("status") != null ? request.getParameter("status") : "";
        int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
        int itemsPerPage = request.getParameter("itemsPerPage") != null ? Integer.parseInt(request.getParameter("itemsPerPage")) : 10;
        int offset = (page - 1) * itemsPerPage;

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            // Fetch pending proposals with search and filter parameters
            List<Proposal> pendingProposals = proposalDAO.getPendingProposals(search, dateFrom, dateTo, status, itemsPerPage, offset);
            // Get total number of proposals for pagination
            int totalProposals = proposalDAO.getPendingProposalsCount(search, dateFrom, dateTo, status);
            int totalPages = (int) Math.ceil((double) totalProposals / itemsPerPage);

            // Set attributes for JSP
            request.setAttribute("pendingProposals", pendingProposals);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("search", search);
            request.setAttribute("dateFrom", dateFrom);
            request.setAttribute("dateTo", dateTo);
            request.setAttribute("status", status);
            request.setAttribute("itemsPerPage", itemsPerPage);

            // Forward to JSP
            request.getRequestDispatcher("/view/admin/adminApprove.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
    }
}