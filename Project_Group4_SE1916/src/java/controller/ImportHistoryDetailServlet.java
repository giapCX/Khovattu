package controller;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */


import dao.ImportDetailDAO;
import dao.ImportReceiptDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.stream.Collectors;
import model.ImportDetailView;
import model.ImportReceipt;

/**
 *
 * @author quanh
 */
public class ImportHistoryDetailServlet extends HttpServlet {
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
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
            out.println("<title>Servlet ImportHistoryDetailServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ImportHistoryDetailServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 
    private final int PAGE_SIZE = 10;
    private final ImportReceiptDAO receiptDAO = new ImportReceiptDAO();
    private final ImportDetailDAO detailDAO = new ImportDetailDAO();
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
    throws ServletException, IOException {
        String importIdStr = req.getParameter("importId");
        String keyword = req.getParameter("keyword");
        String sort = req.getParameter("sort");
        String pageStr = req.getParameter("page");

        if (importIdStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing importId");
            return;
        }

        int importId = Integer.parseInt(importIdStr);
        int page = pageStr == null ? 1 : Integer.parseInt(pageStr);
        int offset = (page - 1) * PAGE_SIZE;

        try {
            ImportReceipt receipt = receiptDAO.getReceiptById(importId);
            List<ImportDetailView> allDetails = detailDAO.getDetailsByImportId(importId, keyword, sort);

            int totalItems = allDetails.size();
            int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);

            List<ImportDetailView> pagedDetails = allDetails.stream()
                .skip(offset)
                .limit(PAGE_SIZE)
                .collect(Collectors.toList());

            req.setAttribute("receipt", receipt);
            req.setAttribute("details", pagedDetails);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("param", req.getParameterMap());

            req.getRequestDispatcher("viewImportHistoryDetail.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
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
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
