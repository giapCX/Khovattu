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

        // Lấy danh sách vật tư dựa trên bộ lọc
        if (filterParentCategory != null && !filterParentCategory.isEmpty()) {
            try {
                int parentCategoryId = Integer.parseInt(filterParentCategory);
                materials = materialDAO.getMaterialsByParentCategory(parentCategoryId);
            } catch (NumberFormatException e) {
                materials = materialDAO.getAllMaterials();
                filterParentCategory = null; // Đặt lại nếu ID không hợp lệ
            }
        } else {
            materials = materialDAO.getAllMaterials();
        }

        // Lấy danh sách danh mục
        List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
        List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();

        // Tạo map chứa danh sách child categories theo parentId
        Map<Integer, List<MaterialCategory>> childCategoriesMap = new HashMap<>();
        for (MaterialCategory parent : parentCategories) {
            List<MaterialCategory> childCategories = categoryDAO.getChildCategoriesByParentId(parent.getCategoryId());
            childCategoriesMap.put(parent.getCategoryId(), childCategories);
        }

        // Lưu dữ liệu vào request
        request.setAttribute("materials", materials);
        request.setAttribute("categories", categories);
        request.setAttribute("parentCategories", parentCategories);
        request.setAttribute("childCategoriesMap", childCategoriesMap);
        request.setAttribute("selectedParentCategory", filterParentCategory);
        request.getRequestDispatcher("/view/material/listMaterial.jsp").forward(request, response);
    }

    private void deleteMaterial(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        int materialId = Integer.parseInt(request.getParameter("id"));
        materialDAO.deleteMaterial(materialId);
        request.getSession().setAttribute("successMessage", "Xóa vật tư thành công!");
        response.sendRedirect(request.getContextPath() + "/ListMaterialController");
    }
}