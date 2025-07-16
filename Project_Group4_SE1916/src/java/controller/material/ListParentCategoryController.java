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
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

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
                    page = 1;
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
                    itemsPerPage = 10;
                }
            }

            // Lấy danh sách danh mục cha với tìm kiếm, lọc trạng thái và phân trang
            List<MaterialCategory> parentCategories = categoryDAO.getParentCategoriesWithFilters(search, status, page, itemsPerPage);
            
            // Đảm bảo parentCategories không null
            if (parentCategories == null) {
                parentCategories = new ArrayList<>();
            }
            
            // Tạo map cho child categories
            Map<Integer, List<MaterialCategory>> childCategoriesMap = new HashMap<>();
            
            // Chỉ xử lý child categories nếu có parent categories
            if (!parentCategories.isEmpty()) {
                for (MaterialCategory parent : parentCategories) {
                    try {
                        int childCount = categoryDAO.getChildCategoryCount(parent.getCategoryId());
                        parent.setChildCount(childCount);
                        
                        // Lấy danh sách child categories
                        List<MaterialCategory> childCategories = categoryDAO.getChildCategoriesByParentId(parent.getCategoryId());
                        if (childCategories == null) {
                            childCategories = new ArrayList<>();
                        }
                        childCategoriesMap.put(parent.getCategoryId(), childCategories);
                    } catch (SQLException e) {
                        // Log error nhưng không throw exception
                        System.err.println("Error processing parent category " + parent.getCategoryId() + ": " + e.getMessage());
                        parent.setChildCount(0);
                        childCategoriesMap.put(parent.getCategoryId(), new ArrayList<>());
                    }
                }
            }

            // Lấy tổng số records
            int totalRecords = categoryDAO.getTotalParentCategories(search, status);
            int totalPages = totalRecords > 0 ? (int) Math.ceil((double) totalRecords / itemsPerPage) : 1;

            // Đặt các thuộc tính cho JSP - CHỈ SET 1 LẦN
            request.setAttribute("parentCategories", parentCategories);
            request.setAttribute("childCategoriesMap", childCategoriesMap);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("search", search);
            request.setAttribute("status", status);
            request.setAttribute("itemsPerPage", itemsPerPage);
            request.setAttribute("totalRecords", totalRecords);

            // Debug info (có thể xóa sau khi fix)
            System.out.println("Search: " + search + ", Status: " + status);
            System.out.println("Found " + parentCategories.size() + " parent categories");
            System.out.println("Total records: " + totalRecords + ", Total pages: " + totalPages);

            // Chuyển đến trang JSP
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
            
        } catch (SQLException e) {
            // Log error và set error attributes thay vì throw exception
            System.err.println("Database error in ListParentCategoryController: " + e.getMessage());
            e.printStackTrace();
            
            // Set empty data để tránh màn hình trắng
            request.setAttribute("parentCategories", new ArrayList<>());
            request.setAttribute("childCategoriesMap", new HashMap<>());
            request.setAttribute("totalPages", 1);
            request.setAttribute("currentPage", 1);
            request.setAttribute("search", request.getParameter("search") != null ? request.getParameter("search").trim() : "");
            request.setAttribute("status", request.getParameter("status") != null ? request.getParameter("status").trim() : "");
            request.setAttribute("itemsPerPage", 10);
            request.setAttribute("totalRecords", 0);
            request.setAttribute("errorMessage", "Có lỗi xảy ra khi tải dữ liệu. Vui lòng thử lại.");
            
            // Vẫn forward đến JSP để hiển thị thông báo lỗi
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
        } catch (Exception e) {
            // Handle các exception khác
            System.err.println("Unexpected error in ListParentCategoryController: " + e.getMessage());
            e.printStackTrace();
            
            // Set empty data
            request.setAttribute("parentCategories", new ArrayList<>());
            request.setAttribute("childCategoriesMap", new HashMap<>());
            request.setAttribute("totalPages", 1);
            request.setAttribute("currentPage", 1);
            request.setAttribute("search", "");
            request.setAttribute("status", "");
            request.setAttribute("itemsPerPage", 10);
            request.setAttribute("totalRecords", 0);
            request.setAttribute("errorMessage", "Có lỗi hệ thống. Vui lòng liên hệ admin.");
            
            request.getRequestDispatcher("/view/material/listParentCategory.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet to list parent material categories with search, filter, and pagination";
    }
}