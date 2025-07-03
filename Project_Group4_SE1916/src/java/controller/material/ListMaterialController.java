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

    // Trong ListMaterialController.java
private void listMaterials(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
    List<Material> materials;
    String filterParentCategory = request.getParameter("filterParentCategory");
    String filterChildCategory = request.getParameter("filterCategory"); // Thêm tham số lọc child category
    String pageParam = request.getParameter("page");
    String itemsPerPageParam = request.getParameter("itemsPerPage");

    int page = (pageParam != null && !pageParam.isEmpty()) ? Integer.parseInt(pageParam) : 1;
    int itemsPerPage = (itemsPerPageParam != null && !itemsPerPageParam.isEmpty()) ? Integer.parseInt(itemsPerPageParam) : 10;

    if (filterChildCategory != null && !filterChildCategory.isEmpty()) {
        try {
            int childCategoryId = Integer.parseInt(filterChildCategory);
            materials = materialDAO.getMaterialsByChildCategory(childCategoryId, page, itemsPerPage);
        } catch (NumberFormatException e) {
            materials = materialDAO.getAllMaterials(page, itemsPerPage);
            filterChildCategory = null;
        }
    } else if (filterParentCategory != null && !filterParentCategory.isEmpty()) {
        try {
            int parentCategoryId = Integer.parseInt(filterParentCategory);
            materials = materialDAO.getMaterialsByParentCategory(parentCategoryId, page, itemsPerPage);
        } catch (NumberFormatException e) {
            materials = materialDAO.getAllMaterials(page, itemsPerPage);
            filterParentCategory = null;
        }
    } else {
        materials = materialDAO.getAllMaterials(page, itemsPerPage);
    }

    int totalRecords;
    if (filterChildCategory != null && !filterChildCategory.isEmpty()) {
        totalRecords = materialDAO.getTotalMaterialsByChildCategory(Integer.parseInt(filterChildCategory));
    } else if (filterParentCategory != null && !filterParentCategory.isEmpty()) {
        totalRecords = materialDAO.getTotalMaterialsByParentCategory(Integer.parseInt(filterParentCategory));
    } else {
        totalRecords = materialDAO.getTotalMaterials();
    }
    
    int totalPages = (int) Math.ceil((double) totalRecords / itemsPerPage);

    // Các phần còn lại giữ nguyên
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
    request.setAttribute("selectedChildCategory", filterChildCategory); // Thêm selectedChildCategory
    request.setAttribute("currentPage", page);
    request.setAttribute("itemsPerPage", itemsPerPage);
    request.setAttribute("totalPages", totalPages);
    
    
    request.getRequestDispatcher("/view/material/listMaterial.jsp").forward(request, response);
}

    private void deleteMaterial(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        int materialId = Integer.parseInt(request.getParameter("id"));
        materialDAO.deleteMaterial(materialId);
        request.getSession().setAttribute("successMessage", "Xóa vật tư thành công!");
        response.sendRedirect(request.getContextPath() + "/ListMaterialController");
    }
}