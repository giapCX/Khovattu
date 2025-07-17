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
            
            // Lấy thông tin danh mục cần chỉnh sửa
            MaterialCategory categoryToEdit = categoryDAO.getCategoryById(categoryId);
            if (categoryToEdit == null) {
                request.setAttribute("errorMessage", "Danh mục không tồn tại!");
                request.getRequestDispatcher("/view/material/editCategory.jsp").forward(request, response);
                return;
            }

            // Lấy danh sách tất cả danh mục cha để hiển thị trong dropdown
            List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories2();
            
            // Nếu đang chỉnh sửa danh mục cha, loại bỏ chính nó khỏi danh sách
            if (categoryToEdit.getParentId() == 0) {
                parentCategories.removeIf(cat -> cat.getCategoryId() == categoryId);
            }

            request.setAttribute("categoryToEdit", categoryToEdit);
            request.setAttribute("parentCategories", parentCategories);
            request.getRequestDispatcher("/view/material/editCategory.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "ID danh mục không hợp lệ!");
            request.getRequestDispatcher("/view/material/editCategory.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Lỗi khi tải thông tin danh mục: " + e.getMessage());
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
            
            // Lấy thông tin danh mục hiện tại
            MaterialCategory currentCategory = categoryDAO.getCategoryById(categoryId);
            if (currentCategory == null) {
                request.setAttribute("errorMessage", "Danh mục không tồn tại!");
                loadDataAndForward(request, response, categoryId);
                return;
            }

            // Kiểm tra dữ liệu đầu vào
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Tên danh mục không được để trống!");
                loadDataAndForward(request, response, categoryId);
                return;
            }

            if (status == null || (!status.equals("active") && !status.equals("inactive"))) {
                request.setAttribute("errorMessage", "Trạng thái không hợp lệ!");
                loadDataAndForward(request, response, categoryId);
                return;
            }

            // Xử lý trường hợp chuyển đổi từ danh mục con thành danh mục cha
            if (parentCategoryParam == null || parentCategoryParam.trim().isEmpty()) {
                // Kiểm tra xem danh mục có vật tư không (nếu là danh mục con)
                if (currentCategory.getParentId() != 0) {
                    if (categoryDAO.hasMaterials(categoryId)) {
                        request.setAttribute("errorMessage", "Không thể cập nhật. Danh mục này đang được sử dụng bởi các vật tư. Hãy di chuyển vật tư sang danh mục khác trước.");
                        loadDataAndForward(request, response, categoryId);
                        return;
                    }
                }

                // Kiểm tra tên danh mục cha đã tồn tại (loại trừ chính nó)
                if (categoryDAO.categoryExistsByNameExcludingId(name.trim(), 0, categoryId)) {
                    request.setAttribute("errorMessage", "Tên danh mục cha đã tồn tại!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // Cập nhật thành danh mục cha
                categoryDAO.updateToParentCategory(categoryId, name.trim(), status);
                request.setAttribute("successMessage", "Cập nhật danh mục cha thành công!");
                
            } else {
                // Xử lý trường hợp cập nhật danh mục con
                int parentId;
                try {
                    parentId = Integer.parseInt(parentCategoryParam);
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "ID danh mục cha không hợp lệ!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // Kiểm tra danh mục cha có tồn tại không
                MaterialCategory parentCategory = categoryDAO.getParentCategoryById(parentId);
                if (parentCategory == null) {
                    request.setAttribute("errorMessage", "Danh mục cha không tồn tại!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // Kiểm tra không thể chọn chính nó làm danh mục cha
                if (parentId == categoryId) {
                    request.setAttribute("errorMessage", "Không thể chọn chính nó làm danh mục cha!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // Nếu đang là danh mục cha, kiểm tra có danh mục con không
                if (currentCategory.getParentId() == 0) {
                    if (categoryDAO.getChildCategoryCount(categoryId) > 0) {
                        request.setAttribute("errorMessage", "Không thể chuyển danh mục cha thành danh mục con khi còn có danh mục con!");
                        loadDataAndForward(request, response, categoryId);
                        return;
                    }
                }

                // Kiểm tra tên danh mục con đã tồn tại trong cùng danh mục cha (loại trừ chính nó)
                if (categoryDAO.categoryExistsByNameExcludingId(name.trim(), parentId, categoryId)) {
                    request.setAttribute("errorMessage", "Tên danh mục con đã tồn tại trong danh mục cha này!");
                    loadDataAndForward(request, response, categoryId);
                    return;
                }

                // Cập nhật thành danh mục con
                categoryDAO.updateToChildCategory(categoryId, name.trim(), parentId, status);
                request.setAttribute("successMessage", "Cập nhật danh mục con thành công!");
            }

            loadDataAndForward(request, response, categoryId);

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "ID danh mục không hợp lệ!");
            try {
                int categoryId = Integer.parseInt(categoryIdParam);
                loadDataAndForward(request, response, categoryId);
            } catch (NumberFormatException ex) {
                response.sendRedirect(request.getContextPath() + "/ListParentCategoryController");
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Lỗi khi cập nhật danh mục: " + e.getMessage());
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
            
            // Nếu đang chỉnh sửa danh mục cha, loại bỏ chính nó khỏi danh sách
            if (categoryToEdit != null && categoryToEdit.getParentId() == 0) {
                parentCategories.removeIf(cat -> cat.getCategoryId() == categoryId);
            }
            
            request.setAttribute("categoryToEdit", categoryToEdit);
            request.setAttribute("parentCategories", parentCategories);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Lỗi khi tải dữ liệu: " + e.getMessage());
        }
        request.getRequestDispatcher("/view/material/editCategory.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet to edit material category (both parent and child)";
    }
}