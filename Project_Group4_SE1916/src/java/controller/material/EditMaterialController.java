

package Controller.material;

import dao.MaterialDAO;
import dao.MaterialCategoryDAO;
import dao.MaterialBrandDAO;
import dao.SupplierDAO;
import jakarta.servlet.ServletException;
import model.Material;
import model.MaterialBrand;
import model.MaterialCategory;
import model.Supplier;


import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class EditMaterialController extends HttpServlet {
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
        try {
            int materialId = Integer.parseInt(request.getParameter("id"));
            Material material = materialDAO.getMaterialById(materialId);
            List<MaterialCategory> categories = categoryDAO.getAllCategories();
            List<MaterialBrand> brands = brandDAO.getAllBrands();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            
            request.setAttribute("material", material);
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.setAttribute("suppliers", suppliers);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            Material material = new Material();
            material.setMaterialId(Integer.parseInt(request.getParameter("id")));
            material.setCode(request.getParameter("code"));
            material.setName(request.getParameter("name"));
            material.setDescription(request.getParameter("description"));
            material.setUnit(request.getParameter("unit"));
            material.setImageUrl(request.getParameter("imageUrl"));
            
            MaterialBrand brand = new MaterialBrand();
            brand.setBrandId(Integer.parseInt(request.getParameter("brand")));
            material.setBrand(brand);
            
            String[] supplierIds = request.getParameterValues("suppliers");
            List<Integer> supplierIdList = new ArrayList<>();
            if (supplierIds != null) {
                for (String id : supplierIds) {
                    supplierIdList.add(Integer.parseInt(id));
                }
            }
            
            materialDAO.updateMaterial(material, supplierIdList);
            response.sendRedirect(request.getContextPath() + "/material?action=list");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}