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
import java.sql.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.stream.Collectors;
import model.ImportDetail;

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
    private ImportReceiptDAO importReceiptDAO;
    private ImportDetailDAO importDetailDAO;
    @Override
    public void init() throws ServletException {
        importReceiptDAO = new ImportReceiptDAO();   
        importDetailDAO = new ImportDetailDAO();
    }
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
        try {
            int importId = Integer.parseInt(request.getParameter("importId"));
            
            // Lấy thông tin phiếu nhập
            ImportReceipt receipt = importReceiptDAO.getImportReceiptById(importId);

            // Lấy danh sách chi tiết vật tư
            String materialNameFilter = request.getParameter("materialName");
            String conditionFilter = request.getParameter("condition");

            List<ImportDetail> details = importDetailDAO.getDetailsByImportIdWithFilter(
                importId, materialNameFilter, conditionFilter
            );

            // Đẩy dữ liệu sang JSP
            request.setAttribute("receipt", receipt);
            request.setAttribute("details", details);
            request.setAttribute("materialName", materialNameFilter);
            request.setAttribute("condition", conditionFilter);

            request.getRequestDispatcher("/viewImportHistoryDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi khi lấy dữ liệu chi tiết phiếu nhập: " + e.getMessage());
            request.getRequestDispatcher("/viewImportHistoryDetail.jsp").forward(request, response);
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
