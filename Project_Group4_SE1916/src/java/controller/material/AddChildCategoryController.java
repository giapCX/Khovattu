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
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "AddChildCategoryController", urlPatterns = {"/AddChildCategoryController"})
public class AddChildCategoryController extends HttpServlet {
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Lấy danh sách danh mục cha
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();
            request.setAttribute("parentCategories", parentCategories);
            request.getRequestDispatcher("/view/material/addChildCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Lỗi lấy danh sách danh mục cha: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Lấy dữ liệu từ form
            String categoryName = request.getParameter("categoryName");
            String parentIdStr = request.getParameter("parentId");
            int parentId = Integer.parseInt(parentIdStr);

            // Kiểm tra tên danh mục đã tồn tại chưa trong cùng danh mục cha
            if (categoryDAO.categoryExistsByName(categoryName, parentId)) {
                request.setAttribute("errorMessage", "Tên danh mục đã tồn tại trong danh mục cha này!");
            } else {
                // Thêm danh mục con
                categoryDAO.addChildCategory(categoryName, parentId);
                request.setAttribute("successMessage", "Thêm danh mục con thành công!");
            }

            // Tải lại danh sách danh mục cha
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories();
            request.setAttribute("parentCategories", parentCategories);

            // Quay lại trang addChildCategory.jsp
            request.getRequestDispatcher("/view/material/addChildCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Lỗi khi thêm danh mục con: " + e.getMessage());
            List<MaterialCategory> parentCategories = null;
            try {
                parentCategories = categoryDAO.getAllParentCategories();
            } catch (SQLException ex) {
                Logger.getLogger(AddChildCategoryController.class.getName()).log(Level.SEVERE, null, ex);
            }
            request.setAttribute("parentCategories", parentCategories);
            request.getRequestDispatcher("/view/material/addChildCategory.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Vui lòng chọn danh mục cha hợp lệ!");
            List<MaterialCategory> parentCategories = null;
            try {
                parentCategories = categoryDAO.getAllParentCategories();
            } catch (SQLException ex) {
                Logger.getLogger(AddChildCategoryController.class.getName()).log(Level.SEVERE, null, ex);
            }
            request.setAttribute("parentCategories", parentCategories);
            request.getRequestDispatcher("/view/material/addChildCategory.jsp").forward(request, response);
        }
    }
}