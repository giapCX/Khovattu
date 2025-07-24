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
            // Lấy danh sách danh mục cha để hiển thị trong dropdown
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories2();
            request.setAttribute("parentCategories", parentCategories);
            
            // Chuyển đến trang JSP để hiển thị form thêm danh mục
            request.getRequestDispatcher("/view/material/addCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Lỗi khi tải danh sách danh mục cha: " + e.getMessage());
            request.getRequestDispatcher("/view/material/addCategory.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String status = request.getParameter("status");
        String parentCategoryParam = request.getParameter("parentCategory");

        // Kiểm tra dữ liệu đầu vào
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Tên danh mục không được để trống!");
            loadParentCategoriesAndForward(request, response);
            return;
        }

        if (status == null || (!status.equals("active") && !status.equals("inactive"))) {
            request.setAttribute("errorMessage", "Trạng thái không hợp lệ!");
            loadParentCategoriesAndForward(request, response);
            return;
        }

        try {
            // Xử lý trường hợp thêm danh mục cha
            if (parentCategoryParam == null || parentCategoryParam.trim().isEmpty()) {
                // Kiểm tra danh mục cha đã tồn tại
                if (categoryDAO.categoryExistsByName(name.trim(), 0)) {
                    request.setAttribute("errorMessage", "Danh mục cha đã tồn tại!");
                    loadParentCategoriesAndForward(request, response);
                    return;
                }

                // Thêm danh mục cha
                categoryDAO.addParentCategory(name.trim(), status);
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
                return;
            } else {
                // Xử lý trường hợp thêm danh mục con
                int parentId;
                try {
                    parentId = Integer.parseInt(parentCategoryParam);
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "ID danh mục cha không hợp lệ!");
                    loadParentCategoriesAndForward(request, response);
                    return;
                }

                // Kiểm tra danh mục cha có tồn tại không
                MaterialCategory parentCategory = categoryDAO.getParentCategoryById(parentId);
                if (parentCategory == null) {
                    request.setAttribute("errorMessage", "Danh mục cha không tồn tại!");
                    loadParentCategoriesAndForward(request, response);
                    return;
                }

                // Kiểm tra danh mục con đã tồn tại trong cùng danh mục cha
                if (categoryDAO.categoryExistsByName(name.trim(), parentId)) {
                    request.setAttribute("errorMessage", "Danh mục con đã tồn tại trong danh mục cha này!");
                    loadParentCategoriesAndForward(request, response);
                    return;
                }

                // Thêm danh mục con với trạng thái
                categoryDAO.addChildCategory(name.trim(), parentId, status);
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
                return;
            }
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Lỗi khi thêm danh mục: " + e.getMessage());
            loadParentCategoriesAndForward(request, response);
        }
    }

    private void loadParentCategoriesAndForward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories2();
            request.setAttribute("parentCategories", parentCategories);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Lỗi khi tải danh sách danh mục cha: " + e.getMessage());
        }
        request.getRequestDispatcher("/view/material/addCategory.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet to add material category (parent or child)";
    }
}