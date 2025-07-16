/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.proposal;

import Dal.DBContext;
import dao.ProposalDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Proposal;
import java.sql.Connection;
/**
 *
 * @author Admin
 */
public class ListProposalExecute extends HttpServlet {

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
            out.println("<title>Servlet ListProposalExecute</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ListProposalExecute at " + request.getContextPath() + "</h1>");
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
        String searchType = request.getParameter("searchType");
        String filter = request.getParameter("filter"); // Get the filter parameter
        String searchStatus = "approved_but_not_executed";
        String searchStartDateStr = request.getParameter("searchStartDate");
        String searchEndDateStr = request.getParameter("searchEndDate");

        Timestamp searchStartDate = null;
        Timestamp searchEndDate = null;

        if (searchStartDateStr != null && !searchStartDateStr.isEmpty()) {
            searchStartDate = Timestamp.valueOf(searchStartDateStr + " 00:00:00");
        }
        if (searchEndDateStr != null && !searchEndDateStr.isEmpty()) {
            searchEndDate = Timestamp.valueOf(searchEndDateStr + " 23:59:59");
        }

        String pageParam = request.getParameter("page");
   
        int currentPage = 1;
        int recordsPerPage = 5;
        String rppParam = request.getParameter("recordsPerPage");
        if (rppParam != null && !rppParam.isEmpty()) {
            try {
                recordsPerPage = Integer.parseInt(rppParam);
            } catch (NumberFormatException e) {

            }
        }

        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) {
                    currentPage = 1;
                }
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);

            // If filter=import_only, restrict to import_from_supplier and import_returned
            String[] proposalTypes = null;
            if ("import_only".equals(filter)) {
                proposalTypes = new String[]{"import_from_supplier", "import_returned"};
            } else if (searchType != null && !searchType.isEmpty()) {
                proposalTypes = new String[]{searchType};
            } else {
                proposalTypes = new String[]{"import_from_supplier", "import_returned", "export"};
            }

            // Count total records with the filtered proposal types
            int totalRecords = proposalDAO.countProposalsByTypeExecuteStatusFromStartDateToEndDate(proposalTypes, searchStatus, searchStartDate, searchEndDate);

            // Calculate total pages
            int totalPages = 1;
            if (totalRecords > 0) {
                totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
            }

            // Ensure currentPage is within valid bounds
            if (currentPage > totalPages) {
                currentPage = totalPages;
            }

            int offset = (currentPage - 1) * recordsPerPage;

            // Fetch proposals with the filtered proposal types
            List<Proposal> proposals = proposalDAO.searchProposalsByTypeExecuteStatusFromStartDateToEndDateWithPaging(proposalTypes, searchStatus, searchStartDate, searchEndDate, offset, recordsPerPage);

            if (proposals == null) {
                proposals = new ArrayList<>();
            }

            request.setAttribute("proposals", proposals);
            request.setAttribute("searchType", searchType);
            request.setAttribute("filter", filter); // Pass filter to JSP if needed
            request.setAttribute("searchStatus", searchStatus);
            request.setAttribute("searchStartDate", searchStartDate);
            request.setAttribute("searchEndDate", searchEndDate);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("recordsPerPage", recordsPerPage);
            request.getRequestDispatcher("/view/warehouse/listProposalExecute.jsp").forward(request, response);
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
        processRequest(request, response);
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