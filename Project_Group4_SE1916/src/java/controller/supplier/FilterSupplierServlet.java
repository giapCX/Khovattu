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
import java.util.ArrayList;
import java.util.List;
import model.Material;
import model.Supplier;

/**
 *
 * @author Admin
 */
public class FilterSupplierServlet extends HttpServlet {

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
            out.println("<title>Servlet FilterSupplierServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet FilterSupplierServlet at " + request.getContextPath() + "</h1>");
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
        String searchCategory = request.getParameter("searchCategory");
        String searchName = request.getParameter("searchName");
        String supplierName = request.getParameter("supplierName");
        int supplierId = Integer.parseInt(request.getParameter("supplierId"));
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
                    currentPage = 1; // đảm bảo currentPage không âm hoặc 0
                }
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        try (Connection conn = DBContext.getConnection()) {
            SupplierDAO supplierDAO = new SupplierDAO(conn);

            int totalRecords = supplierDAO.countMaterialOfSupplierBySupplierIdCategoryNameMaterialName(supplierId, searchCategory, searchName);

            // Nếu không có bản ghi nào, set totalPages tối thiểu là 1
            int totalPages = 1;
            if (totalRecords > 0) {
                totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
            }

            // Nếu currentPage lớn hơn tổng số trang, gán lại cho đúng
            if (currentPage > totalPages) {
                currentPage = totalPages;
            }

            int offset = (currentPage - 1) * recordsPerPage;

            List<Material> materials = supplierDAO.searchMaterialOfSuppliersBySupplierIdCategoryNameMaterialNameWithPaging(supplierId, searchCategory, searchName, offset, recordsPerPage);

            // Đảm bảo suppliers không null, nếu null thì khởi tạo list rỗng
            if (materials == null) {
                materials = new ArrayList<>();
            }
            
            SupplierDAO s = new SupplierDAO(conn);
            Supplier supplier = s.getSupplierById(supplierId);
            request.setAttribute("supplier", supplier);
            request.setAttribute("materials", materials);
            request.setAttribute("searchName", searchName);
            request.setAttribute("searchCategory", searchCategory);
            request.setAttribute("supplierId", supplierId);
            request.setAttribute("supplierName", supplierName);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("recordsPerPage", recordsPerPage);

            request.getRequestDispatcher("/view/supplier/listMaterialOfSupplier.jsp").forward(request, response);
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
