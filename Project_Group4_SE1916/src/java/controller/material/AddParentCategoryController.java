package controller.material;

import dao.MaterialCategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AddParentCategoryController", urlPatterns = {"/AddParentCategoryController"})
public class AddParentCategoryController extends HttpServlet {
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Chuyển đến trang JSP để hiển thị form thêm danh mục cha
        request.getRequestDispatcher("/view/material/addParentCategory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");

        // Kiểm tra dữ liệu đầu vào
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Tên danh mục không được để trống!");
            request.getRequestDispatcher("/view/material/addParentCategory.jsp").forward(request, response);
            return;
        }

        try {
            // Kiểm tra danh mục cha đã tồn tại
            if (categoryDAO.categoryExistsByName(name, 0)) { // parent_id = 0 để kiểm tra danh mục cha
                request.setAttribute("errorMessage", "Danh mục cha đã tồn tại!");
                request.getRequestDispatcher("/view/material/addParentCategory.jsp").forward(request, response);
                return;
            }

            // Thêm danh mục cha (parent_id = NULL)
            categoryDAO.addParentCategory(name);
            request.getSession().setAttribute("successMessage", "Thêm danh mục cha thành công!");
            response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Lỗi khi thêm danh mục: " + e.getMessage());
            request.getRequestDispatcher("/view/material/addParentCategory.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet to add parent material category";
    }
}