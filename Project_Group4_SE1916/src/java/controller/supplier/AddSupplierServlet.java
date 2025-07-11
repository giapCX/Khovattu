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
public class AddSupplierServlet extends HttpServlet {

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
            out.println("<title>Servlet AddSupplierServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddSupplierServlet at " + request.getContextPath() + "</h1>");
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
        request.getRequestDispatcher("view/supplier/addSupplier.jsp").forward(request, response);
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
        String supplierName = request.getParameter("supplierName");
        String supplierPhone = request.getParameter("supplierPhone");
        String supplierAddress = request.getParameter("supplierAddress");
        String supplierEmail = request.getParameter("supplierEmail");
        String supplierStatus = request.getParameter("supplierStatus");

        Connection conn = DBContext.getConnection();
        SupplierDAO supplierDAO = new SupplierDAO(conn);

        boolean isNameExist = supplierDAO.checkNameExists(supplierName);
        boolean isPhoneExist = supplierDAO.checkPhoneExists(supplierPhone);
        boolean isEmailExist = supplierDAO.checkEmailExists(supplierEmail);
        if (isPhoneExist) {
            request.setAttribute("errorMessage", "Phone number already exists.");
            request.getRequestDispatcher("view/supplier/addSupplier.jsp").forward(request, response);
            return;
        }
        if (isEmailExist) {
            request.setAttribute("errorMessage", "Email already exists.");
            request.getRequestDispatcher("view/supplier/addSupplier.jsp").forward(request, response);
            return;
        }
        if (isNameExist) {
            request.setAttribute("errorMessage", "Supplier name already exists.");
            request.getRequestDispatcher("view/supplier/addSupplier.jsp").forward(request, response);
            return;
        }
        Supplier supplier = new Supplier();
        supplier.setSupplierName(supplierName);
        supplier.setSupplierPhone(supplierPhone);
        supplier.setSupplierAddress(supplierAddress);
        supplier.setSupplierEmail(supplierEmail);
        supplier.setSupplierStatus(supplierStatus);

        boolean success = supplierDAO.addSupplier(supplier);
        if (success) {
            response.sendRedirect("ListSupplierServlet");
        } else {
            request.setAttribute("errorMessage", "Add supplier fail!");
            request.getRequestDispatcher("view/supplier/addSupplier.jsp").forward(request, response);
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
