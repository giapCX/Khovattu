/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.supplier;

import Dal.DBContext;
import dao.MaterialCategoryDAO;
import dao.MaterialDAO;

import dao.SupplierDAO;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Material;
import model.MaterialCategory;

/**
 *
 * @author quanh
 */
public class AddMaterialSupplier extends HttpServlet {

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
            out.println("<title>Servlet AddMaterialSupplier</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddMaterialSupplier at " + request.getContextPath() + "</h1>");
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
        try {
            MaterialCategoryDAO categoryDAO = new MaterialCategoryDAO();
            MaterialDAO materialDAO = new MaterialDAO();

            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();
            List<MaterialCategory> childCategories = categoryDAO.getAllChildCategories();
            List<Material> material = materialDAO.getAllMaterials();

            String supplierId = request.getParameter("supplierId");
            if (supplierId == null || supplierId.isEmpty()) {
                throw new ServletException("Thiếu supplierId trên URL");
            }
            String status = request.getParameter("status");
            if ("success".equals(status)) {
                request.setAttribute("message", "Thêm vật tư thành công!");
            }
            request.setAttribute("material", material);
            request.setAttribute("supplierId", supplierId);
            request.setAttribute("parentCategories", parentCategories);
            request.setAttribute("childCategories", childCategories);
            request.getRequestDispatcher("/view/supplier/addMaterialSupplier.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Lỗi cơ sở dữ liệu: " + e.getMessage());
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
         String[] materialIds = request.getParameterValues("materialId[]");
        String supplierIdStr = request.getParameter("supplierId");
        try {
            int supplierId = Integer.parseInt(supplierIdStr);
            List<Integer> materialIdList = new ArrayList<>();
            List<Integer> duplicateMaterials = new ArrayList<>();

            Connection conn = DBContext.getConnection();
            SupplierDAO supplierDAO = new SupplierDAO(conn);

            for (String id : materialIds) {
                int materialId = Integer.parseInt(id);
                if (supplierDAO.isMaterialAlreadyExists(supplierId, materialId)) {
                    duplicateMaterials.add(materialId);
                } else {
                    materialIdList.add(materialId);
                }
            }

            if (!materialIdList.isEmpty()) {
                supplierDAO.addMaterialsToSupplier(supplierId, materialIdList);
            }

            if (!duplicateMaterials.isEmpty()) {
                // Báo lỗi nếu có vật tư đã tồn tại
                request.setAttribute("error", "Material Exist!");
                doGet(request, response); // gọi lại doGet để load lại dữ liệu
                return;
            }

            // Nếu không có lỗi gì
            response.sendRedirect("AddMaterialSupplier?supplierId=" + supplierId + "&status=success");

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Định dạng dữ liệu không hợp lệ.");
            request.getRequestDispatcher("/view/supplier/addMaterialSupplier.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Lỗi cơ sở dữ liệu.");
            request.getRequestDispatcher("/view/supplier/addMaterialSupplier.jsp").forward(request, response);
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
