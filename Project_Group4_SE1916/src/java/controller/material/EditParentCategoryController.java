package controller.material;

import dao.MaterialCategoryDAO;
import model.MaterialCategory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.regex.Pattern;

@WebServlet(name = "EditParentCategoryController", urlPatterns = {"/EditParentCategoryController"})
public class EditParentCategoryController extends HttpServlet {

    private MaterialCategoryDAO categoryDAO;
    
    // Constants for validation
    private static final int MIN_NAME_LENGTH = 2;
    private static final int MAX_NAME_LENGTH = 100;
    private static final Pattern NAME_PATTERN = Pattern.compile("^[a-zA-ZÀ-ỹ0-9\\s\\-_]+$");

    @Override
    public void init() throws ServletException {
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryIdParam = request.getParameter("categoryId");
        if (categoryIdParam == null || categoryIdParam.trim().isEmpty()) {
            setErrorMessage(request, "Category ID is required!");
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
            return;
        }

        try {
            int categoryId = Integer.parseInt(categoryIdParam);
            MaterialCategory category = categoryDAO.getParentCategoryById(categoryId);
            if (category == null) {
                setErrorMessage(request, "Parent category not found!");
                request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
                return;
            }
            request.setAttribute("category", category);
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            setErrorMessage(request, "Invalid category ID format!");
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            setErrorMessage(request, "Error retrieving category: " + e.getMessage());
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get parameters
        String categoryIdParam = request.getParameter("categoryId");
        String name = request.getParameter("name");
        String status = request.getParameter("status");

        // Validate category ID
        if (categoryIdParam == null || categoryIdParam.trim().isEmpty()) {
            setErrorMessage(request, "Category ID is required!");
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
            return;
        }

        int categoryId;
        try {
            categoryId = Integer.parseInt(categoryIdParam);
        } catch (NumberFormatException e) {
            setErrorMessage(request, "Invalid category ID format!");
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
            return;
        }

        // Get existing category
        MaterialCategory existingCategory;
        try {
            existingCategory = categoryDAO.getParentCategoryById(categoryId);
            if (existingCategory == null) {
                setErrorMessage(request, "Parent category not found!");
                request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
                return;
            }
        } catch (SQLException e) {
            setErrorMessage(request, "Error retrieving category: " + e.getMessage());
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
            return;
        }

        // Server-side validation
        String validationError = validateInput(name, status);
        if (validationError != null) {
            setErrorMessage(request, validationError);
            request.setAttribute("category", existingCategory);
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
            return;
        }

        // Trim name for processing
        name = name.trim();

        // Check if there are any changes
        if (name.equals(existingCategory.getName()) && status.equals(existingCategory.getStatus())) {
            setErrorMessage(request, "No changes detected!");
            request.setAttribute("category", existingCategory);
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
            return;
        }

        try {
            // Check for duplicate name only if name is changed
            if (!name.equals(existingCategory.getName())) {
                if (categoryDAO.categoryExistsByName(name, 0)) {
                    setErrorMessage(request, "Category name already exists!");
                    request.setAttribute("category", existingCategory);
                    request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
                    return;
                }
            }

            // Update category
            categoryDAO.updateParentCategory(categoryId, name, status);
            
            // Get updated category to show new values
            MaterialCategory updatedCategory = categoryDAO.getParentCategoryById(categoryId);
            request.setAttribute("category", updatedCategory);
            setSuccessMessage(request, "Parent category updated successfully!");
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
            
        } catch (SQLException e) {
            setErrorMessage(request, "Error updating category: " + e.getMessage());
            request.setAttribute("category", existingCategory);
            request.getRequestDispatcher("/view/material/editParentCategory.jsp").forward(request, response);
        }
    }

    
    private String validateInput(String name, String status) {
        // Validate name
        if (name == null || name.trim().isEmpty()) {
            return "Tên danh mục không được để trống.";
        }

        name = name.trim();

        if (name.length() < MIN_NAME_LENGTH || name.length() > MAX_NAME_LENGTH) {
            return "Tên danh mục phải có từ " + MIN_NAME_LENGTH + " đến " + MAX_NAME_LENGTH + " ký tự.";
        }

        // Check for valid characters (optional - depends on your requirements)
        if (!NAME_PATTERN.matcher(name).matches()) {
            return "Tên danh mục chỉ được chứa chữ cái, số, dấu gạch ngang và dấu gạch dưới.";
        }

        // Validate status
        if (status == null || (!status.equals("active") && !status.equals("inactive"))) {
            return "Trạng thái không hợp lệ!";
        }

        return null; // Valid input
    }

    /**
     * Sets error message in session to persist across redirects
     */
    private void setErrorMessage(HttpServletRequest request, String message) {
        HttpSession session = request.getSession();
        session.setAttribute("errorMessage", message);
    }

    /**
     * Sets success message in session to persist across redirects
     */
    private void setSuccessMessage(HttpServletRequest request, String message) {
        HttpSession session = request.getSession();
        session.setAttribute("successMessage", message);
    }

    @Override
    public String getServletInfo() {
        return "Servlet to edit parent material category with enhanced validation";
    }
}