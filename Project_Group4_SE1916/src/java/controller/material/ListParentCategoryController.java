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

public class ListParentCategoryController extends HttpServlet {
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

            // Chuyển đến trang JSP
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Lỗi khi lấy danh sách danh mục cha: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response); // Hiện tại chưa xử lý POST, chuyển hướng đến doGet
    }

    @Override
    public String getServletInfo() {
        return "Servlet to list parent material categories";
    }
}