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

@WebServlet("/listParentCategory")
public class ListParentCategoryController extends HttpServlet {
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Lấy các tham số từ request
            String search = request.getParameter("search") != null ? request.getParameter("search").trim() : "";
            String status = request.getParameter("status") != null ? request.getParameter("status").trim() : "";
            
            // Xử lý tham số page
            int page = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1; // Giá trị mặc định nếu parse thất bại
                }
            }

            // Xử lý tham số itemsPerPage
            int itemsPerPage = 10;
            String itemsPerPageParam = request.getParameter("itemsPerPage");
            if (itemsPerPageParam != null && !itemsPerPageParam.trim().isEmpty()) {
                try {
                    itemsPerPage = Integer.parseInt(itemsPerPageParam);
                    if (itemsPerPage != 10 && itemsPerPage != 20 && itemsPerPage != 30) {
                        itemsPerPage = 10;
                    }
                } catch (NumberFormatException e) {
                    itemsPerPage = 10; // Giá trị mặc định nếu parse thất bại
                }
            }

            // Lấy danh sách danh mục cha với tìm kiếm, lọc trạng thái và phân trang
            List<MaterialCategory> parentCategories = categoryDAO.getParentCategoriesWithFilters(search, status, page, itemsPerPage);
            int totalRecords = categoryDAO.getTotalParentCategories(search, status);
            int totalPages = (int) Math.ceil((double) totalRecords / itemsPerPage);

            // Đặt các thuộc tính cho JSP
            request.setAttribute("parentCategories", parentCategories);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("search", search);
            request.setAttribute("status", status);
            request.setAttribute("itemsPerPage", itemsPerPage);

            // Chuyển đến trang JSP
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Lỗi khi lấy danh sách danh mục cha: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response); // Chuyển hướng đến doGet để xử lý
    }

    @Override
    public String getServletInfo() {
        return "Servlet to list parent material categories with search, filter, and pagination";
    }
}