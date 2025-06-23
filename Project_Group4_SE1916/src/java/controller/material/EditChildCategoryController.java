/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.material;

import dao.MaterialCategoryDAO;
import model.MaterialCategory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author quanh
 */
public class EditChildCategoryController extends HttpServlet {
   
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
            out.println("<title>Servlet EditChildCategoryController</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditChildCategoryController at " + request.getContextPath () + "</h1>");
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
    private MaterialCategoryDAO categoryDAO;
    @Override
    public void init() throws ServletException {
        categoryDAO = new MaterialCategoryDAO();
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            List<MaterialCategory> childCategories = categoryDAO.getAllChildCategories();
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();
            request.setAttribute("childCategories", childCategories);
            request.setAttribute("parentCategories", parentCategories);
            request.getRequestDispatcher("/view/material/editChildCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Error " + e.getMessage());
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
        try {
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String newCategoryName = request.getParameter("newCategoryName");
            int parentId = Integer.parseInt(request.getParameter("parentId"));
            boolean success = categoryDAO.updateChildCategory(categoryId, newCategoryName, parentId);
            if (success) {
                request.setAttribute("successMessage", "Child category updated successfully!");
            } else {
                request.setAttribute("errorMessage", "Failed to update child category.");
            }
            List<MaterialCategory> childCategories = categoryDAO.getAllChildCategories();
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();
            request.setAttribute("childCategories", childCategories);
            request.setAttribute("parentCategories", parentCategories);
            request.getRequestDispatcher("/view/material/editChildCategory.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("Error " + ex.getMessage());
        }
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
