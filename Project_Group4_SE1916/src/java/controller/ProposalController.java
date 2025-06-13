package controller;

import dao.ProposalDAO;
import model.Proposal;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/proposals")
public class ProposalController extends HttpServlet {
    
    private ProposalDAO proposalDAO;

    @Override
    public void init() throws ServletException {
        proposalDAO = new ProposalDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        
        
        
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
        int itemsPerPage = request.getParameter("itemsPerPage") != null ? Integer.parseInt(request.getParameter("itemsPerPage")) : 10;

        try {
            List<Proposal> proposals = proposalDAO.getProposals(search, status, startDate, endDate, page, itemsPerPage);
            int totalProposals = proposalDAO.getTotalProposals(search, status, startDate, endDate);
            int totalPages = (int) Math.ceil((double) totalProposals / itemsPerPage);

            request.setAttribute("requests", proposals);
            request.setAttribute("totalPages", totalPages);

            
            request.getRequestDispatcher("/directorApprovalHistory.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi truy vấn cơ sở dữ liệu");
        }
    }
}