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
import jakarta.servlet.annotation.WebServlet;
import java.util.List;
import model.Proposal;
@WebServlet("/proposals")
public class DirectorProposalsServlet extends HttpServlet {

   @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    // Retrieve parameters
    String search = request.getParameter("search") != null ? request.getParameter("search").trim() : "";
    String startDate = request.getParameter("startDate") != null ? request.getParameter("startDate") : "";
    String endDate = request.getParameter("endDate") != null ? request.getParameter("endDate") : "";
    String status = request.getParameter("status") != null ? request.getParameter("status") : "";
    
    // Validate dates
    if (!startDate.isEmpty() && !isValidDate(startDate)) {
        request.setAttribute("error", "Invalid start date format.");
        request.getRequestDispatcher("view/direction/directorProposalsHistory.jsp").forward(request, response);
        return;
    }
    if (!endDate.isEmpty() && !isValidDate(endDate)) {
        request.setAttribute("error", "Invalid end date format.");
        request.getRequestDispatcher("view/direction/directorProposalsHistory.jsp").forward(request, response);
        return;
    }
    if (!startDate.isEmpty() && !endDate.isEmpty() && endDate.compareTo(startDate) < 0) {
        request.setAttribute("error", "End date must be on or after start date.");
        request.getRequestDispatcher("view/direction/directorProposalsHistory.jsp").forward(request, response);
        return;
    }

    int page = 1;
    try {
        page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
        if (page < 1) page = 1;
    } catch (NumberFormatException e) {
        page = 1;
    }

    int itemsPerPage = 10;
    try {
        itemsPerPage = request.getParameter("itemsPerPage") != null ? Integer.parseInt(request.getParameter("itemsPerPage")) : 10;
        if (itemsPerPage < 1) itemsPerPage = 10;
    } catch (NumberFormatException e) {
        itemsPerPage = 10;
    }

    int offset = (page - 1) * itemsPerPage;
    System.out.println("Parameters: search=" + search + ", startDate=" + startDate + ", endDate=" + endDate + 
                      ", status=" + status + ", page=" + page + ", itemsPerPage=" + itemsPerPage);

    try (Connection conn = DBContext.getConnection()) {
        ProposalDAO proposalDAO = new ProposalDAO(conn);
 
        List<Proposal> requests = proposalDAO.directorGetPendingProposals(search, startDate, endDate, status, itemsPerPage, offset);
        int totalProposals = proposalDAO.directorGetPendingProposalsCount(search, startDate, endDate, status);
        int totalPages = (int) Math.ceil((double) totalProposals / itemsPerPage);

        System.out.println("Requests size: " + requests.size() + ", totalProposals: " + totalProposals + ", totalPages: " + totalPages);

        request.setAttribute("requests", requests);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("search", search);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("status", status);
        request.setAttribute("itemsPerPage", itemsPerPage);

        request.getRequestDispatcher("view/direction/directorProposalsHistory.jsp").forward(request, response);
    } catch (SQLException e) {
        throw new ServletException("Database error: " + e.getMessage(), e);
    }
}

private boolean isValidDate(String dateStr) {
    if (dateStr == null || dateStr.isEmpty()) {
        return true; 
    }
    try {
        java.time.LocalDate.parse(dateStr); 
        return true;
    } catch (java.time.format.DateTimeParseException e) {
        return false;
    }
}
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // Redirect to doGet for now
    }

    @Override
    public String getServletInfo() {
        return "Servlet for handling director approval history";
    }
}