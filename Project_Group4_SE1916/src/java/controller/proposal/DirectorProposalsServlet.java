package controller.proposal;

import dao.ProposalDAO;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import Dal.DBContext;
import jakarta.servlet.annotation.WebServlet;
import java.util.List;
import model.Proposal;

@WebServlet("/proposals")
public class DirectorProposalsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check session and role authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/view/accessDenied.jsp");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if (!"direction".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/view/accessDenied.jsp");
            return;
        }
        
        // Retrieve and validate parameters
        String search = request.getParameter("search");
        search = (search != null) ? search.trim() : "";
        
        String startDate = request.getParameter("startDate");
        startDate = (startDate != null) ? startDate.trim() : "";
        
        String endDate = request.getParameter("endDate");
        endDate = (endDate != null) ? endDate.trim() : "";
        
        String status = request.getParameter("status");
        status = (status != null) ? status.trim() : "";
        
        // Validate dates
        if (!startDate.isEmpty() && !isValidDate(startDate)) {
            request.setAttribute("error", "Invalid start date format. Please use YYYY-MM-DD format.");
            forwardToJSP(request, response);
            return;
        }
        
        if (!endDate.isEmpty() && !isValidDate(endDate)) {
            request.setAttribute("error", "Invalid end date format. Please use YYYY-MM-DD format.");
            forwardToJSP(request, response);
            return;
        }
        
        if (!startDate.isEmpty() && !endDate.isEmpty() && endDate.compareTo(startDate) < 0) {
            request.setAttribute("error", "End date must be on or after start date.");
            forwardToJSP(request, response);
            return;
        }
        
        // Validate status parameter
        if (!status.isEmpty() && !isValidStatus(status)) {
            request.setAttribute("error", "Invalid status parameter.");
            forwardToJSP(request, response);
            return;
        }
        
        // Parse pagination parameters
        int page = parsePage(request.getParameter("page"));
        int itemsPerPage = parseItemsPerPage(request.getParameter("itemsPerPage"));
        int offset = (page - 1) * itemsPerPage;
        
        // Log parameters for debugging
        System.out.println("DirectorProposalsServlet - Parameters: search=" + search + 
                          ", startDate=" + startDate + ", endDate=" + endDate + 
                          ", status=" + status + ", page=" + page + ", itemsPerPage=" + itemsPerPage);
        
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            
            // Get proposals and count
            List<Proposal> requests = proposalDAO.directorGetPendingProposals(
                search, startDate, endDate, status, itemsPerPage, offset);
            int totalProposals = proposalDAO.directorGetPendingProposalsCount(
                search, startDate, endDate, status);
            
            int totalPages = (totalProposals > 0) ? (int) Math.ceil((double) totalProposals / itemsPerPage) : 1;
            
            // Adjust page if it exceeds total pages
            if (page > totalPages && totalPages > 0) {
                page = totalPages;
                offset = (page - 1) * itemsPerPage;
                requests = proposalDAO.directorGetPendingProposals(
                    search, startDate, endDate, status, itemsPerPage, offset);
            }
            
            System.out.println("DirectorProposalsServlet - Results: requestsSize=" + requests.size() + 
                              ", totalProposals=" + totalProposals + ", totalPages=" + totalPages);
            
            // Set request attributes
            request.setAttribute("requests", requests);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalProposals", totalProposals);
            request.setAttribute("search", search);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            request.setAttribute("status", status);
            request.setAttribute("itemsPerPage", itemsPerPage);
            
            // Forward to JSP
            forwardToJSP(request, response);
            
        } catch (SQLException e) {
            System.err.println("Database error in DirectorProposalsServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Database error occurred. Please try again later.");
            forwardToJSP(request, response);
        } catch (Exception e) {
            System.err.println("Unexpected error in DirectorProposalsServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An unexpected error occurred. Please try again later.");
            forwardToJSP(request, response);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("Error closing database connection: " + e.getMessage());
                }
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // For form submissions, redirect to GET to avoid duplicate form submissions
        response.sendRedirect(request.getRequestURI() + "?" + request.getQueryString());
    }
    
    /**
     * Validates date string format (YYYY-MM-DD)
     */
    private boolean isValidDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return true;
        }
        
        try {
            java.time.LocalDate.parse(dateStr.trim());
            return true;
        } catch (java.time.format.DateTimeParseException e) {
            return false;
        }
    }
    
    /**
     * Validates status parameter
     */
    private boolean isValidStatus(String status) {
        if (status == null || status.trim().isEmpty()) {
            return true;
        }
        
        String normalizedStatus = status.trim().toLowerCase();
        return normalizedStatus.equals("pending") || 
               normalizedStatus.equals("approved") || 
               normalizedStatus.equals("rejected");
    }
    
    /**
     * Parses page parameter with validation
     */
    private int parsePage(String pageParam) {
        int page = 1;
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
                if (page < 1) {
                    page = 1;
                }
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        return page;
    }
    
    /**
     * Parses itemsPerPage parameter with validation
     */
    private int parseItemsPerPage(String itemsPerPageParam) {
        int itemsPerPage = 10; // Default value
        if (itemsPerPageParam != null && !itemsPerPageParam.trim().isEmpty()) {
            try {
                itemsPerPage = Integer.parseInt(itemsPerPageParam.trim());
                // Validate range
                if (itemsPerPage < 1) {
                    itemsPerPage = 10;
                } else if (itemsPerPage > 100) {
                    itemsPerPage = 100; // Maximum limit
                }
            } catch (NumberFormatException e) {
                itemsPerPage = 10;
            }
        }
        return itemsPerPage;
    }
    
    /**
     * Forwards request to JSP page
     */
    private void forwardToJSP(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("view/direction/directorProposalsHistory.jsp")
                .forward(request, response);
    }
    
    @Override
    public String getServletInfo() {
        return "DirectorProposalsServlet - Handles director proposal approval history with search, filtering, and pagination";
    }
}