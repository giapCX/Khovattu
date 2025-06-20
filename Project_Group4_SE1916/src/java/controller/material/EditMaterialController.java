package controller.material;

import Dal.DBContext;
import dao.MaterialDAO;
import dao.MaterialCategoryDAO;
import dao.SupplierDAO;
import jakarta.servlet.ServletException;
import model.Material;
import model.MaterialCategory;
import model.Supplier;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

// em note các bước ra để sau đọc lại hiểu luôn nên thầy đừng bắt bẻ em nhá =(( 
public class EditMaterialController extends HttpServlet {

    private MaterialDAO materialDAO;
    private MaterialCategoryDAO categoryDAO;
    private SupplierDAO supplierDAO;

    // Khởi tạo các DAO để làm việc với database
    @Override
    public void init() throws ServletException {
        materialDAO = new MaterialDAO();
        categoryDAO = new MaterialCategoryDAO();
        Connection conn = DBContext.getConnection();
        supplierDAO = new SupplierDAO(conn);
    }

    // Xử lý GET request: Hiển thị form chỉnh sửa vật tư
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // 1. Lấy ID vật tư từ tham số URL
            int materialId = Integer.parseInt(request.getParameter("id"));

            // 2. Lấy thông tin vật tư, danh mục và nhà cung cấp từ database
            Material material = materialDAO.getMaterialById(materialId);
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();

            // 3. Gửi dữ liệu tới JSP để hiển thị form
            request.setAttribute("material", material);
            request.setAttribute("categories", categories);
            request.setAttribute("suppliers", suppliers);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            // Nếu có lỗi khi lấy dữ liệu, báo lỗi chi tiết
            throw new ServletException("Failed to retrieve material data", e);
        } catch (NumberFormatException e) {
            // Nếu ID không hợp lệ (không phải số)
            throw new ServletException("Invalid material ID", e);
        }
    }

    // Xử lý POST request: Lưu thông tin chỉnh sửa vật tư
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Material material = new Material();

        try {
            material.setMaterialId(Integer.parseInt(request.getParameter("id")));
            material.setCode(request.getParameter("code"));
            material.setName(request.getParameter("name"));
            material.setDescription(request.getParameter("description"));
            material.setUnit(request.getParameter("unit"));
            material.setImageUrl(request.getParameter("imageUrl"));

            int categoryId = Integer.parseInt(request.getParameter("category"));
            MaterialCategory category = new MaterialCategory();
            category.setCategoryId(categoryId);
            material.setCategory(category);

            String[] supplierIds = request.getParameterValues("suppliers");
            List<Integer> supplierIdList = new ArrayList<>();
            if (supplierIds != null) {
                for (String id : supplierIds) {
                    supplierIdList.add(Integer.parseInt(id));
                }
            }

            // Cập nhật vào DB
            materialDAO.updateMaterial(material, supplierIdList);

            // Gán thông báo thành công vào request (ko dùng session nữa)
            request.setAttribute("message", "Update material success!");
            request.setAttribute("messageType", "success");

            // Load lại dữ liệu cần thiết để hiển thị form
            reloadFormData(request);

            // Lấy lại thông tin vật tư mới nhất để hiển thị
            Material updatedMaterial = materialDAO.getMaterialById(material.getMaterialId());
            request.setAttribute("material", updatedMaterial);

            // Hiển thị lại trang chỉnh sửa
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("message", "Invalid input! Please check your data.");
            request.setAttribute("messageType", "danger");
            reloadFormData(request);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("message", "Error updating material: " + e.getMessage());
            request.setAttribute("messageType", "danger");
            reloadFormData(request);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        }
    }

    // Hàm hỗ trợ: Tải lại dữ liệu cho form khi có lỗi
    private void reloadFormData(HttpServletRequest request) throws ServletException {
        try {
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            request.setAttribute("categories", categories);
            request.setAttribute("suppliers", suppliers);
            // Giữ lại thông tin vật tư đã nhập (nếu cần)
            Material material = new Material();
            material.setMaterialId(Integer.parseInt(request.getParameter("id")));
            material.setCode(request.getParameter("code"));
            material.setName(request.getParameter("name"));
            material.setDescription(request.getParameter("description"));
            material.setUnit(request.getParameter("unit"));
            material.setImageUrl(request.getParameter("imageUrl"));
            request.setAttribute("material", material);
        } catch (SQLException | NumberFormatException e) {
            throw new ServletException("Failed to reload data for form", e);
        }
    }
}
