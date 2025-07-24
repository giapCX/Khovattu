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

@WebServlet(name = "EditCategoryController", urlPatterns = {"/EditCategoryController"})
public class EditCategoryController extends HttpServlet {
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
                return;
            }

            int categoryId = Integer.parseInt(idParam);
            
            // Get category information to edit
            MaterialCategory categoryToEdit = categoryDAO.getCategoryById(categoryId);
            if (categoryToEdit == null) {
                request.setAttribute("errorMessage", "Category does not exist!");
                request.getRequestDispatcher("/view/material/editCategory.jsp").forward(request, response);
                return;
            }

            // Get all parent categories to display in dropdown
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories2();
            
            // If editing a parent category, remove itself from the list
            if (categoryToEdit.getParentId() == 0) {
                parentCategories.removeIf(cat -> cat.getCategoryId() == categoryId);
            }

            request.setAttribute("categoryToEdit", categoryToEdit);
            request.setAttribute("parentCategories", parentCategories);
            request.getRequestDispatcher("/view/material/editCategory.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid category ID!");
            request.getRequestDispatcher("/view/material/editCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading category information: " + e.getMessage());
            request.getRequestDispatcher("/view/material/editCategory.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryIdParam = request.getParameter("categoryId");
        String name = request.getParameter("name");
        String status = request.getParameter("status");
        String parentCategoryParam = request.getParameter("parentCategory");

        try {
            int categoryId = Integer.parseInt(categoryIdParam);
            
            // Get current category information
            MaterialCategory currentCategory = categoryDAO.getCategoryById(categoryId);
            if (currentCategory == null) {
                request.setAttribute("errorMessage", "Category does not exist!");
                loadDataAndForward(request, response, categoryId);
                return;
            }

            // Validate input data
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Category name cannot be empty!");
                loadDataAndForward(request, response, categoryId);
                return;
            }

            if (status == null || (!status.equals("active") && !status.equals("inactive"))) {
                request.setAttribute("errorMessage", "Invalid status!");
                loadDataAndForward(request, response, categoryId);
                return;
            }

            // Handle case of converting from child category to parent category
            if (parentCategoryParam == null || parentCategoryParam.trim().isEmpty()) {
                // Check if category has materials (if it's a child category)
                if (currentCategory.getParentId() != 0) {
                    if (categoryDAO.hasMaterials(categoryId)) {
                        request.setAttribute("errorMessage", "Cannot update. This category is being used by materials. Please move materials to another category first.");
                        loadDataAndForward(request, response, categoryId);
                        return;
                    }
                }

                // Check if parent category name already exists (excluding itself)
                if (categoryDAO.categoryExistsByNameExcludingId(name.trim(), 0, categoryId)) {
                    request.setAttribute("errorMessage", "Parent category name already exists!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // Update to parent category
                categoryDAO.updateToParentCategory(categoryId, name.trim(), status);
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
                return;
            } else {
                // Handle case of updating child category
                int parentId;
                try {
                    parentId = Integer.parseInt(parentCategoryParam);
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid parent category ID!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // Check if parent category exists
                MaterialCategory parentCategory = categoryDAO.getParentCategoryById(parentId);
                if (parentCategory == null) {
                    request.setAttribute("errorMessage", "Parent category does not exist!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // Cannot select itself as parent category
                if (parentId == categoryId) {
                    request.setAttribute("errorMessage", "Cannot select itself as parent category!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // If currently a parent category, check if it has child categories
                if (currentCategory.getParentId() == 0) {
                    if (categoryDAO.getChildCategoryCount(categoryId) > 0) {
                        request.setAttribute("errorMessage", "Cannot convert parent category to child category when it still has child categories!");
                        loadDataAndForward(request, response, categoryId);
                        return;
                    }
                }

                // Check if child category name already exists in the same parent category (excluding itself)
                if (categoryDAO.categoryExistsByNameExcludingId(name.trim(), parentId, categoryId)) {
                    request.setAttribute("errorMessage", "Child category name already exists in this parent category!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // Update to child category
                categoryDAO.updateToChildCategory(categoryId, name.trim(), parentId, status);
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
                return;
            }

            // No need to reload form when already redirected
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid category ID!");
            try {
                int categoryId = Integer.parseInt(categoryIdParam);
                loadDataAndForward(request, response, categoryId);
            } catch (NumberFormatException ex) {
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating category: " + e.getMessage());
            try {
                int categoryId = Integer.parseInt(categoryIdParam);
                loadDataAndForward(request, response, categoryId);
            } catch (NumberFormatException ex) {
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
            }
        }
    }

    private void loadDataAndForward(HttpServletRequest request, HttpServletResponse response, int categoryId) 
            throws ServletException, IOException {
        try {
            MaterialCategory categoryToEdit = categoryDAO.getCategoryById(categoryId);
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories2();
            
            // If editing a parent category, remove itself from the list
            if (categoryToEdit != null && categoryToEdit.getParentId() == 0) {
                parentCategories.removeIf(cat -> cat.getCategoryId() == categoryId);
            }
            
            request.setAttribute("categoryToEdit", categoryToEdit);
            request.setAttribute("parentCategories", parentCategories);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading data: " + e.getMessage());
        }
        request.getRequestDispatcher("/view/material/editCategory.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet to edit material category (both parent and child)";
    }
}