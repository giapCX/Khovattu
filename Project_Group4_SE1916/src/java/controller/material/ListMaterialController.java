package controller.material;

import dao.MaterialDAO;
import dao.MaterialCategoryDAO;
import dao.MaterialBrandDAO;
import dao.SupplierDAO;
import model.Material;
import model.MaterialCategory;
import model.MaterialBrand;
import model.Supplier;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ListMaterialController", urlPatterns = {"/listMaterialController"})
public class ListMaterialController extends HttpServlet {
    private MaterialDAO materialDAO;
    private MaterialCategoryDAO categoryDAO;
    private MaterialBrandDAO brandDAO;
    private SupplierDAO supplierDAO;

    @Override
    public void init() throws ServletException {
        materialDAO = new MaterialDAO();
        categoryDAO = new MaterialCategoryDAO();
        brandDAO = new MaterialBrandDAO();
        supplierDAO = new SupplierDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            // Chỉ giữ logic cho action "list" hoặc null
            listMaterials(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if (action.equals("delete")) {
                deleteMaterial(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void listMaterials(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        List<Material> materials = materialDAO.getAllMaterials();
        List<MaterialCategory> categories = categoryDAO.getAllCategories();
        List<MaterialBrand> brands = brandDAO.getAllBrands();
        List<Supplier> suppliers = supplierDAO.getAllSuppliers();
        
        request.setAttribute("materials", materials);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        request.setAttribute("suppliers", suppliers);
        request.getRequestDispatcher("/view/material/listMaterial.jsp").forward(request, response);
    }

    private void deleteMaterial(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        int materialId = Integer.parseInt(request.getParameter("id"));
        materialDAO.deleteMaterial(materialId);
        response.sendRedirect(request.getContextPath() + "/ListMaterialController?action=list");
    }
}