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
        // Retrieve and validate parameters
        String search = request.getParameter("search") != null ? request.getParameter("search").trim() : "";
        String dateFrom = request.getParameter("dateFrom") != null ? request.getParameter("dateFrom").trim() : "";
        String dateTo = request.getParameter("dateTo") != null ? request.getParameter("dateTo").trim() : "";
        String status = request.getParameter("status") != null ? request.getParameter("status").trim() : "";
        int page = 1;
        int itemsPerPage = 10;

        // Safely parse page and itemsPerPage
        try {
            String pageStr = request.getParameter("page");
            String itemsPerPageStr = request.getParameter("itemsPerPage");
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr);
            }
            if (itemsPerPageStr != null && !itemsPerPageStr.isEmpty()) {
                itemsPerPage = Integer.parseInt(itemsPerPageStr);
            }
            // Ensure valid values
            if (page < 1) {
                page = 1;
            }
            if (itemsPerPage < 1) {
                itemsPerPage = 10;
            }
        } catch (NumberFormatException e) {
            // Log the error (optional, add logging framework like Log4j)
            System.err.println("Invalid number format for page or itemsPerPage: " + e.getMessage());
            page = 1;
            itemsPerPage = 10;
        }

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
            request.setAttribute("totalPages", totalPages > 0 ? totalPages : 1);
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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp); // Handle POST same as GET if needed
    }
}
