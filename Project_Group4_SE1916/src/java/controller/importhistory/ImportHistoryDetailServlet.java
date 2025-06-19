package controller.importhistory;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */


import dao.ImportDetailDAO;
import dao.ImportReceiptDAO;
import model.ImportDetailView;
import model.ImportReceipt;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

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
    private final int PAGE_SIZE = 5;
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
         String search = request.getParameter("search");
    String sort = request.getParameter("sort");
    String pageRaw = request.getParameter("page");
    String importIdRaw = request.getParameter("importId");

    // Check null
    if (importIdRaw == null || importIdRaw.trim().isEmpty()) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing importId");
        return;
    }

    int importId;
    try {
        importId = Integer.parseInt(importIdRaw);
    } catch (NumberFormatException e) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid importId");
        return;
    }

    int page = 1;
    if (pageRaw != null) {
        try {
            page = Integer.parseInt(pageRaw);
        } catch (NumberFormatException e) {
            page = 1;
        }
    }

    ImportDetailDAO detailDAO = new ImportDetailDAO();
    ImportReceiptDAO receiptDAO = new ImportReceiptDAO();

    // === Chọn DAO phù hợp ===
    List<ImportDetailView> details;
    if (search != null && !search.isEmpty() && sort != null && !sort.isEmpty()) {
        details = detailDAO.searchAndSortByPrice(importId, search, sort, page, PAGE_SIZE);
    } else if (search != null && !search.isEmpty()) {
        details = detailDAO.searchByName(importId, search, page, PAGE_SIZE);
    } else if (sort != null && !sort.isEmpty()) {
        details = detailDAO.sortByPrice(importId, sort, page, PAGE_SIZE);
    } else {
        details = detailDAO.getByImportId(importId, page, PAGE_SIZE);
    }

    int totalItems = detailDAO.countSearch(importId, search);
    int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);

    ImportReceipt receipt = receiptDAO.getReceiptById(importId);
    if (receipt == null) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Import receipt not found");
        return;
    }

    request.setAttribute("receipt", receipt);
    request.setAttribute("details", details);
    request.setAttribute("importId", importId);
    request.setAttribute("search", search);
    request.setAttribute("sort", sort);
    request.setAttribute("currentPage", page);
    request.setAttribute("totalPages", totalPages);

    request.getRequestDispatcher("viewImportHistoryDetail.jsp").forward(request, response);
   
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
