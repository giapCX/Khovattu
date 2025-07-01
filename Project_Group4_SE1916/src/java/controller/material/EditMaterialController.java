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
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

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
            String origin = request.getParameter("origin");
            String supplierId = request.getParameter("supplierId");
            String supplierName = request.getParameter("supplierName");

            // 2. Lấy thông tin vật tư, danh mục và nhà cung cấp từ database
            Material material = materialDAO.getMaterialById(materialId);
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();

            // 3. Gửi dữ liệu tới JSP để hiển thị form
            request.setAttribute("material", material);
            request.setAttribute("categories", categories);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("origin", origin);
            request.setAttribute("supplierId", supplierId);
            request.setAttribute("supplierName", supplierName);
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
        String origin = request.getParameter("origin");
        String supplierId = request.getParameter("supplierId");
        String supplierName = request.getParameter("supplierName");

        try {
            // Lấy và validate các tham số từ form
            String materialIdStr = request.getParameter("id");
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String unit = request.getParameter("unit");
            String imageUrl = request.getParameter("imageUrl");
            String categoryIdStr = request.getParameter("category");
            String[] supplierIds = request.getParameterValues("suppliers");

            // Validation rules
            StringBuilder errorMessage = new StringBuilder();

            // Validate material ID
            if (materialIdStr == null || materialIdStr.trim().isEmpty()) {
                errorMessage.append("Material ID is required. ");
            } else if (!materialIdStr.matches("\\d+")) {
                errorMessage.append("Material ID must be a number. ");
            }

            // Validate code: not blank, max 50 chars, alphanumeric, underscore, and hyphen
            if (code == null || code.trim().isEmpty()) {
                errorMessage.append("Code is required. ");
            } else if (code.length() > 50) {
                errorMessage.append("Code must not exceed 50 characters. ");
            } else if (!Pattern.matches("^[a-zA-Z0-9_.-]+$", code)) {
                errorMessage.append("Code can only contain letters, numbers, underscores, dots, and hyphens. ");
            }

            // Validate name: not blank, max 100 chars, allow Vietnamese characters
            if (name == null || name.trim().isEmpty()) {
                errorMessage.append("Name is required. ");
            } else if (name.length() > 100) {
                errorMessage.append("Name must not exceed 100 characters. ");
            } else if (!Pattern.matches("^[\\p{L}\\d\\s_.-]+$", name)) {
                errorMessage.append("Name can only contain letters (including Vietnamese), numbers, spaces, underscores, dots, and hyphens. ");
            }

            // Validate description: max 500 chars (can be empty), allow Vietnamese characters
            if (description != null && description.length() > 500) {
                errorMessage.append("Description must not exceed 500 characters. ");
            } 

            // Validate unit: not blank, max 20 chars, allow Vietnamese characters
            if (unit == null || unit.trim().isEmpty()) {
                errorMessage.append("Unit is required. ");
            } else if (unit.length() > 20) {
                errorMessage.append("Unit must not exceed 20 characters. ");
            } else if (!Pattern.matches("^[\\p{L}\\d\\s_-]+$", unit)) {
                errorMessage.append("Unit can only contain letters (including Vietnamese), numbers, spaces, underscores, and hyphens. ");
            }

            // Validate imageUrl: max 255 chars (can be empty)
            if (imageUrl != null && imageUrl.length() > 255) {
                errorMessage.append("Image URL must not exceed 255 characters. ");
            }

            // Validate category: must be selected
            if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
                errorMessage.append("Category is required. ");
            } else if (!categoryIdStr.matches("\\d+")) {
                errorMessage.append("Invalid category selection. ");
            }

            // Validate suppliers: at least one must be selected
            if (supplierIds == null || supplierIds.length == 0) {
                errorMessage.append("At least one supplier must be selected. ");
            }

            // If there are validation errors, reload form with error message
            if (errorMessage.length() > 0) {
                request.setAttribute("message", errorMessage.toString());
                request.setAttribute("messageType", "danger");
                reloadFormData(request, materialIdStr, code, name, description, unit, imageUrl);
                request.setAttribute("origin", origin);
                request.setAttribute("supplierId", supplierId);
                request.setAttribute("supplierName", supplierName);
                request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
                return;
            }

            // Set material properties after validation
            material.setMaterialId(Integer.parseInt(materialIdStr));
            material.setCode(code.trim());
            material.setName(name.trim());
            material.setDescription(description != null ? description.trim() : "");
            material.setUnit(unit.trim());
            material.setImageUrl(imageUrl != null ? imageUrl.trim() : "");

            int categoryId = Integer.parseInt(categoryIdStr);
            MaterialCategory category = new MaterialCategory();
            category.setCategoryId(categoryId);
            material.setCategory(category);

            List<Integer> supplierIdList = new ArrayList<>();
            for (String id : supplierIds) {
                supplierIdList.add(Integer.parseInt(id));
            }

            // Cập nhật vào DB
            materialDAO.updateMaterial(material, supplierIdList);

            // Gán thông báo thành công
            request.setAttribute("message", "Update material success!");
            request.setAttribute("messageType", "success");

            // Load lại dữ liệu cần thiết để hiển thị form
            reloadFormData(request, materialIdStr, code, name, description, unit, imageUrl);

            // Lấy lại thông tin vật tư mới nhất để hiển thị
            Material updatedMaterial = materialDAO.getMaterialById(material.getMaterialId());
            request.setAttribute("material", updatedMaterial);
            request.setAttribute("origin", origin);
            request.setAttribute("supplierId", supplierId);
            request.setAttribute("supplierName", supplierName);

            // Hiển thị lại trang chỉnh sửa
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("message", "Invalid input! Please check your data.");
            request.setAttribute("messageType", "danger");
            reloadFormData(request, request.getParameter("id"), request.getParameter("code"),
                    request.getParameter("name"), request.getParameter("description"),
                    request.getParameter("unit"), request.getParameter("imageUrl"));
            request.setAttribute("origin", origin);
            request.setAttribute("supplierId", supplierId);
            request.setAttribute("supplierName", supplierName);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("message", "Error updating material: " + e.getMessage());
            request.setAttribute("messageType", "danger");
            reloadFormData(request, request.getParameter("id"), request.getParameter("code"),
                    request.getParameter("name"), request.getParameter("description"),
                    request.getParameter("unit"), request.getParameter("imageUrl"));
            request.setAttribute("origin", origin);
            request.setAttribute("supplierId", supplierId);
            request.setAttribute("supplierName", supplierName);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        }
    }

    // Hàm hỗ trợ: Tải lại dữ liệu cho form khi có lỗi
    private void reloadFormData(HttpServletRequest request, String materialId, String code,
            String name, String description, String unit, String imageUrl)
            throws ServletException {
        try {
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            request.setAttribute("categories", categories);
            request.setAttribute("suppliers", suppliers);

            // Giữ lại thông tin vật tư đã nhập
            Material material = new Material();
            if (materialId != null && materialId.matches("\\d+")) {
                material.setMaterialId(Integer.parseInt(materialId));
            }
            material.setCode(code != null ? code : "");
            material.setName(name != null ? name : "");
            material.setDescription(description != null ? description : "");
            material.setUnit(unit != null ? unit : "");
            material.setImageUrl(imageUrl != null ? imageUrl : "");
            request.setAttribute("material", material);
        } catch (SQLException e) {
            throw new ServletException("Failed to reload data for form", e);
        }
    }
}