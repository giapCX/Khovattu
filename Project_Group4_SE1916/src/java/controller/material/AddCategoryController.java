package controller.material;

import dao.MaterialCategoryDAO;
import model.MaterialCategory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "AddCategoryController", urlPatterns = {"/AddCategoryController"})
public class AddCategoryController extends HttpServlet {
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get list of parent categories to display in dropdown
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories2();
            request.setAttribute("parentCategories", parentCategories);
            
            // Forward to JSP page to display add category form
            request.getRequestDispatcher("/view/material/addCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading parent categories list: " + e.getMessage());
            request.getRequestDispatcher("/view/material/addCategory.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String status = request.getParameter("status");
        String parentCategoryParam = request.getParameter("parentCategory");

        // Validate input data
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Category name cannot be empty!");
            loadParentCategoriesAndForward(request, response);
            return;
        }

        if (status == null || (!status.equals("active") && !status.equals("inactive"))) {
            request.setAttribute("errorMessage", "Invalid status!");
            loadParentCategoriesAndForward(request, response);
            return;
        }

        try {
            // Handle adding parent category
            if (parentCategoryParam == null || parentCategoryParam.trim().isEmpty()) {
                // Check if parent category already exists
                if (categoryDAO.categoryExistsByName(name.trim(), 0)) {
                    request.setAttribute("errorMessage", "Parent category already exists!");
                    loadParentCategoriesAndForward(request, response);
                    return;
                }

                // Add parent category
                categoryDAO.addParentCategory(name.trim(), status);
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
                return;
            } else {
                // Handle adding child category
                int parentId;
                try {
                    parentId = Integer.parseInt(parentCategoryParam);
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid parent category ID!");
                    loadParentCategoriesAndForward(request, response);
                    return;
                }

                // Check if parent category exists
                MaterialCategory parentCategory = categoryDAO.getParentCategoryById(parentId);
                if (parentCategory == null) {
                    request.setAttribute("errorMessage", "Parent category does not exist!");
                    loadParentCategoriesAndForward(request, response);
                    return;
                }

                // Check if child category already exists in the same parent category
                if (categoryDAO.categoryExistsByName(name.trim(), parentId)) {
                    request.setAttribute("errorMessage", "Child category already exists in this parent category!");
                    loadParentCategoriesAndForward(request, response);
                    return;
                }

                // Add child category with status
                categoryDAO.addChildCategory(name.trim(), parentId, status);
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
                return;
            }
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error adding category: " + e.getMessage());
            loadParentCategoriesAndForward(request, response);
        }
    }

    private void loadParentCategoriesAndForward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories2();
            request.setAttribute("parentCategories", parentCategories);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading parent categories list: " + e.getMessage());
        }
        request.getRequestDispatcher("/view/material/addCategory.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet to add material category (parent or child)";
    }
}