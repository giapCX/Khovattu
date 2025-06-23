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

@WebServlet(name = "EditParentCategoryController", urlPatterns = {"/EditParentCategoryController"})
public class EditParentCategoryController extends HttpServlet {
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryIdParam = request.getParameter("categoryId");
        if (categoryIdParam == null || categoryIdParam.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Category ID is required!");
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
            return;
        }

        try {
            int categoryId = Integer.parseInt(categoryIdParam);
            MaterialCategory category = categoryDAO.getParentCategoryById(categoryId);
            if (category == null) {
                request.setAttribute("errorMessage", "Parent category not found!");
                request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
                return;
            }
            request.setAttribute("category", category);
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid category ID format!");
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error retrieving category: " + e.getMessage());
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryIdParam = request.getParameter("categoryId");
        String name = request.getParameter("name");
        String status = request.getParameter("status");

        // Validate input
        if (categoryIdParam == null || categoryIdParam.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Category ID is required!");
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
            return;
        }
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Category name cannot be empty!");
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
            return;
        }
        if (status == null || (!status.equals("active") && !status.equals("inactive"))) {
            request.setAttribute("errorMessage", "Invalid status!");
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
            return;
        }

        try {
            int categoryId = Integer.parseInt(categoryIdParam);
            MaterialCategory existingCategory = categoryDAO.getParentCategoryById(categoryId);
            if (existingCategory == null) {
                request.setAttribute("errorMessage", "Parent category not found!");
                request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
                return;
            }

            // Check if new name already exists (excluding current category)
            if (!name.equals(existingCategory.getName()) && categoryDAO.categoryExistsByName(name, 0)) {
                request.setAttribute("errorMessage", "Category name already exists!");
                request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
                return;
            }

            // Update category
            categoryDAO.updateParentCategory(categoryId, name, status);
            request.getSession().setAttribute("successMessage", "Parent category updated successfully!");
            response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid category ID format!");
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating category: " + e.getMessage());
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet to edit parent material category";
    }
}