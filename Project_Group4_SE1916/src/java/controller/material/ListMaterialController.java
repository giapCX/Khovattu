package controller.material;

import dao.MaterialDAO;
import dao.MaterialCategoryDAO;
import model.Material;
import model.MaterialCategory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ListMaterialController", urlPatterns = {"/ListMaterialController"})
public class ListMaterialController extends HttpServlet {
    private MaterialDAO materialDAO;
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        materialDAO = new MaterialDAO();
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            listMaterials(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("delete".equals(action)) {
                deleteMaterial(request, response);
            } else {
                listMaterials(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void listMaterials(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        List<Material> materials;
        String filterParentCategory = request.getParameter("filterParentCategory");
        String filterChildCategory = request.getParameter("filterCategory");
        String search = request.getParameter("search");
        if (search != null) search = search.trim();
        String pageParam = request.getParameter("page");
        String itemsPerPageParam = request.getParameter("itemsPerPage");

        // Fix: Xử lý NumberFormatException khi parse page và itemsPerPage
        int page = 1;
        int itemsPerPage = 10;
        
        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        try {
            if (itemsPerPageParam != null && !itemsPerPageParam.isEmpty()) {
                itemsPerPage = Integer.parseInt(itemsPerPageParam);
                if (itemsPerPage < 1) itemsPerPage = 10;
            }
        } catch (NumberFormatException e) {
            itemsPerPage = 10;
        }

        int totalRecords;
        
        if (search != null && !search.isEmpty()) {
            materials = materialDAO.searchMaterialsByName(search, page, itemsPerPage);
            totalRecords = materialDAO.getTotalMaterialsByName(search);
        } else if (filterChildCategory != null && !filterChildCategory.isEmpty()) {
            try {
                int childCategoryId = Integer.parseInt(filterChildCategory);
                materials = materialDAO.getMaterialsByChildCategory(childCategoryId, page, itemsPerPage);
                totalRecords = materialDAO.getTotalMaterialsByChildCategory(childCategoryId);
            } catch (NumberFormatException e) {
                materials = materialDAO.getAllMaterials(page, itemsPerPage);
                filterChildCategory = null;
                totalRecords = materialDAO.getTotalMaterials();
            }
        } else if (filterParentCategory != null && !filterParentCategory.isEmpty()) {
            try {
                int parentCategoryId = Integer.parseInt(filterParentCategory);
                materials = materialDAO.getMaterialsByParentCategory(parentCategoryId, page, itemsPerPage);
                totalRecords = materialDAO.getTotalMaterialsByParentCategory(parentCategoryId);
            } catch (NumberFormatException e) {
                materials = materialDAO.getAllMaterials(page, itemsPerPage);
                filterParentCategory = null;
                totalRecords = materialDAO.getTotalMaterials();
            }
        } else {
            materials = materialDAO.getAllMaterials(page, itemsPerPage);
            totalRecords = materialDAO.getTotalMaterials();
        }

        // Fix: Đảm bảo totalPages ít nhất là 1
        int totalPages = (int) Math.ceil((double) totalRecords / itemsPerPage);
        if (totalPages == 0) totalPages = 1;

        List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
        List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();

        Map<Integer, List<MaterialCategory>> childCategoriesMap = new HashMap<>();
        for (MaterialCategory parent : parentCategories) {
            List<MaterialCategory> childCategories = categoryDAO.getChildCategoriesByParentId(parent.getCategoryId());
            childCategoriesMap.put(parent.getCategoryId(), childCategories);
        }

        request.setAttribute("materials", materials);
        request.setAttribute("categories", categories);
        request.setAttribute("parentCategories", parentCategories);
        request.setAttribute("childCategoriesMap", childCategoriesMap);
        request.setAttribute("selectedParentCategory", filterParentCategory);
        request.setAttribute("selectedChildCategory", filterChildCategory);
        request.setAttribute("currentPage", page);
        request.setAttribute("itemsPerPage", itemsPerPage);
        request.setAttribute("totalPages", totalPages);
        
        request.getRequestDispatcher("/view/material/listMaterial.jsp").forward(request, response);
    }

    private void deleteMaterial(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        // Fix: Xử lý NumberFormatException khi parse ID
        try {
            int materialId = Integer.parseInt(request.getParameter("id"));
            materialDAO.deleteMaterial(materialId);
            request.getSession().setAttribute("successMessage", "Disabled successfully!");
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Invalid ID!");
        }
        response.sendRedirect(request.getContextPath() + "/ListMaterialController");
    }
}