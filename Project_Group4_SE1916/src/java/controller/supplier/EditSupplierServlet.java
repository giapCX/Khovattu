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
            out.println("<title>Servlet EditSupplierServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditSupplierServlet at " + request.getContextPath() + "</h1>");
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
        String sId = request.getParameter("supplierId");
        int supplierId = Integer.parseInt(sId);
        Connection conn = DBContext.getConnection();
        SupplierDAO s = new SupplierDAO(conn);
        Supplier supplier = s.getSupplierById(supplierId);
        request.setAttribute("supplier", supplier);
        request.getRequestDispatcher("/view/supplier/editSupplier.jsp").forward(request, response);
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

        String supplierId = request.getParameter("supplierId");
        String supplierName = request.getParameter("supplierName").trim();
        String supplierPhone = request.getParameter("supplierPhone").trim();
        String supplierAddress = request.getParameter("supplierAddress").trim();
        String supplierEmail = request.getParameter("supplierEmail").trim();
        String supplierStatus = request.getParameter("supplierStatus");

        Supplier supplier = new Supplier();
        supplier.setSupplierId(Integer.parseInt(supplierId));
        supplier.setSupplierName(supplierName);
        supplier.setSupplierPhone(supplierPhone);
        supplier.setSupplierAddress(supplierAddress);
        supplier.setSupplierEmail(supplierEmail);
        supplier.setSupplierStatus(supplierStatus);

        Connection conn = DBContext.getConnection();
        SupplierDAO supplierDAO = new SupplierDAO(conn);
        Supplier oldSupplier = supplierDAO.getSupplierById(supplier.getSupplierId());

        boolean isChanged = false;
        if (oldSupplier != null) {
            if (!supplier.getSupplierName().equals(oldSupplier.getSupplierName())) {
                isChanged = true;
            } else if (!supplier.getSupplierPhone().equals(oldSupplier.getSupplierPhone())) {
                isChanged = true;
            } else if (!supplier.getSupplierAddress().equals(oldSupplier.getSupplierAddress())) {
                isChanged = true;
            } else if (!supplier.getSupplierEmail().equals(oldSupplier.getSupplierEmail())) {
                isChanged = true;
            } else if (!supplier.getSupplierStatus().equals(oldSupplier.getSupplierStatus())) {
                isChanged = true;
            }
        } else {
            isChanged = true;
        }
        String errorMessage;
        if (!isChanged) {
            errorMessage = "You haven't changed anything!";
            request.setAttribute("errorMessage", errorMessage);
            doGet(request, response);
        } else {
            boolean isNameExist = supplierDAO.checkNameExistsExcept(supplierName, Integer.parseInt(supplierId));
            boolean isPhoneExist = supplierDAO.checkPhoneExistsExcept(supplierPhone, Integer.parseInt(supplierId));
            boolean isEmailExist = supplierDAO.checkEmailExistsExcept(supplierEmail, Integer.parseInt(supplierId));
            if (isPhoneExist) {
                request.setAttribute("errorMessage", "Phone number already exists.");
                doGet(request, response);
                return;
            }
            if (isEmailExist) {
                request.setAttribute("errorMessage", "Email already exists.");
                doGet(request, response);
                return;
            }
            if (isNameExist) {
                request.setAttribute("errorMessage", "Supplier name already exists.");
                doGet(request, response);
                return;
            }
            boolean updated = supplierDAO.updateSupplier(supplier);
            errorMessage = updated ? "Update successful!" : "Update failful!";
            request.setAttribute("errorMessage", errorMessage);
            doGet(request, response);
        }
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
