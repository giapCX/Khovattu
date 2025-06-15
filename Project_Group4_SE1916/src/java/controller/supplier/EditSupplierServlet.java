/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.supplier;

import Dal.DBContext;
import dao.SupplierDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import model.Supplier;

/**
 *
 * @author Admin
 */
public class EditSupplierServlet extends HttpServlet {
   
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
            out.println("<title>Servlet EditSupplierServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditSupplierServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
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
        String sId = request.getParameter("supplierId");
        int supplierId = Integer.parseInt(sId);
        Connection conn = DBContext.getConnection();
        SupplierDAO s= new SupplierDAO(conn);
        Supplier supplier = s.getSupplierById(supplierId);
        request.setAttribute("supplier", supplier);
        request.getRequestDispatcher("/view/supplier/editSupplier.jsp").forward(request, response);
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
        String supplierId = request.getParameter("supplierId");
        String supplierName = request.getParameter("supplierName");
        String supplierPhone = request.getParameter("supplierPhone");
        String supplierAddress = request.getParameter("supplierAddress");
        String supplierEmail = request.getParameter("supplierEmail");
        String supplierStatus = request.getParameter("supplierStatus");
        
        Supplier supplier = new Supplier();
        supplier.setSupplierId(Integer.parseInt(supplierId));
        supplier.setSupplierName(supplierName);
        supplier.setSupplierPhone(supplierPhone);
        supplier.setSupplierAddress(supplierAddress);
        supplier.setSupplierEmail(supplierEmail);
        supplier.setSupplierStatus(supplierStatus);
        
        Connection conn = DBContext.getConnection();
        SupplierDAO s= new SupplierDAO(conn);     
        Supplier oldSupplier = s.getSupplierById(supplier.getSupplierId());

         boolean isChanged = false;

    if (oldSupplier != null) {
        if (!supplier.getSupplierName().equals(oldSupplier.getSupplierName())) isChanged = true;
        else if (!supplier.getSupplierPhone().equals(oldSupplier.getSupplierPhone())) isChanged = true;
        else if (!supplier.getSupplierAddress().equals(oldSupplier.getSupplierAddress())) isChanged = true;
        else if (!supplier.getSupplierEmail().equals(oldSupplier.getSupplierEmail())) isChanged = true;
        else if (!supplier.getSupplierStatus().equals(oldSupplier.getSupplierStatus())) isChanged = true;
    } else {
        // Nếu không tìm thấy supplier hiện tại thì coi như có thay đổi
        isChanged = true;
    }

    String message;
    if (!isChanged) {
        message = "You haven't changed anything!";
    } else {
        boolean updated = s.updateSupplier(supplier);
        message = updated ? "Update successful!" : "Update failful!";
    }

    request.setAttribute("errorMessage", message);
    // Chuyển tiếp tới trang hiển thị, ví dụ editSupplier.jsp
    request.getRequestDispatcher("/view/supplier/editSupplier.jsp").forward(request, response);
      
        
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
