package controller.material;

import dao.MaterialDAO;
import dao.MaterialCategoryDAO;
import model.Material;
import model.MaterialCategory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class AddMaterialController extends HttpServlet {

    private MaterialDAO materialDAO;
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        materialDAO = new MaterialDAO();
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            loadFormData(request);
            request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Không thể lấy dữ liệu cho form", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set character encoding for Vietnamese
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        try {
            Material material = new Material();
            
            // Lấy dữ liệu từ form
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String unit = request.getParameter("unit");
            // Đã xóa parentCategoryId
            String childCategoryId = request.getParameter("childCategory"); // Khớp với name trong JSP
            
            // Validation
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("message", "Tên vật tư không được để trống!");
                request.setAttribute("messageType", "error");
                loadFormData(request);
                request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
                return;
            }
            
            if (unit == null || unit.trim().isEmpty()) {
                request.setAttribute("message", "Đơn vị không được để trống!");
                request.setAttribute("messageType", "error");
                loadFormData(request);
                request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
                return;
            }
            // Đã xóa kiểm tra parentCategoryId
            if (childCategoryId == null || childCategoryId.trim().isEmpty()) {
                request.setAttribute("message", "Vui lòng chọn danh mục con!");
                request.setAttribute("messageType", "error");
                loadFormData(request);
                request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
                return;
            }
            
            // Kiểm tra trùng tên vật tư trong cùng sub category
            int subCategoryId = Integer.parseInt(childCategoryId);
            if (materialDAO.isMaterialNameExistsInSubCategory(name, subCategoryId)) {
                request.setAttribute("message", "Tên vật tư đã tồn tại trong danh mục con này!");
                request.setAttribute("messageType", "error");
                loadFormData(request);
                request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
                return;
            }
            
            // Set basic information
            material.setName(name.trim());
            material.setDescription(description != null ? description.trim() : "");
            material.setUnit(unit.trim());
            int unitId = materialDAO.getUnitIdByName(unit); // Cần thêm phương thức này trong MaterialDAO

if (unitId == -1) {
    request.setAttribute("message", "Đơn vị không hợp lệ!");
    request.setAttribute("messageType", "error");
    loadFormData(request);
    request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
    return;
}

material.setUnitId(unitId);
            
            // Sinh mã code tự động
            String code = "VT_" + new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date());
            material.setCode(code);
            
            // Xử lý upload ảnh
            Part filePart = request.getPart("imageFile");
            String imageUrl = "";
            
            // Nếu chưa chọn ảnh thì báo lỗi
            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("message", "Vui lòng chọn ảnh vật tư!");
                request.setAttribute("messageType", "error");
                loadFormData(request);
                request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
                return;
            }
            
            if (filePart != null && filePart.getSize() > 0) {
                // Validate file type
                String contentType = filePart.getContentType();
                if (!contentType.startsWith("image/")) {
                    request.setAttribute("message", "Vui lòng chọn file ảnh hợp lệ!");
                    request.setAttribute("messageType", "error");
                    loadFormData(request);
                    request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
                    return;
                }
                
                String originalFileName = filePart.getSubmittedFileName();
                String fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
                String fileName = System.currentTimeMillis() + "_" + name.replaceAll("[^a-zA-Z0-9]", "_") + fileExtension;
                
                // Save to build directory for immediate display
                String buildPath = request.getServletContext().getRealPath("/uploads");
                File buildDir = new File(buildPath);
                if (!buildDir.exists()) {
                    buildDir.mkdirs();
                }
                
                File buildFile = new File(buildDir, fileName);
                filePart.write(buildFile.getAbsolutePath());
                
                // Copy to source directory to persist after clean & build
                try {
                    File buildDirFile = new File(buildPath);
                    File projectRoot = buildDirFile.getParentFile().getParentFile().getParentFile();
                    File sourceUploadDir = new File(projectRoot, "web/uploads");
                    if (!sourceUploadDir.exists()) {
                        sourceUploadDir.mkdirs();
                    }
                    
                    Path source = buildFile.toPath();
                    Path target = new File(sourceUploadDir, fileName).toPath();
                    Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
                } catch (Exception e) {
                    Logger.getLogger(AddMaterialController.class.getName()).log(Level.WARNING, "Could not copy to source directory", e);
                }
                
                imageUrl = "uploads/" + fileName;
            }
            
            material.setImageUrl(imageUrl);
            
            // Set category
            try {
                int categoryId = Integer.parseInt(childCategoryId);
                MaterialCategory category = new MaterialCategory();
                category.setCategoryId(categoryId);
                material.setCategory(category);
              
            } catch (NumberFormatException e) {
                request.setAttribute("message", "Danh mục không hợp lệ!");
                request.setAttribute("messageType", "error");
                loadFormData(request);
                request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
                return;
            }
           
            
            // Save to database
            try {
                materialDAO.addMaterial(material);
                // Chuyển hướng về trang danh sách vật tư sau khi thêm thành công
                response.sendRedirect(request.getContextPath() + "/ListMaterialController?action=list");
                return;
            } catch (SQLException e) {
                Logger.getLogger(AddMaterialController.class.getName()).log(Level.SEVERE, "Error saving material", e);
                request.setAttribute("message", "Lỗi khi lưu vật tư: " + e.getMessage());
                request.setAttribute("messageType", "error");
                
                // Preserve form data on error
                request.setAttribute("name", name);
                request.setAttribute("description", description);
                request.setAttribute("unit", unit);
                // Đã xóa request.setAttribute("parentCategoryId", parentCategoryId);
                request.setAttribute("childCategory", childCategoryId);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("message", "Dữ liệu không hợp lệ! Vui lòng kiểm tra lại.");
            request.setAttribute("messageType", "error");
        } catch (Exception e) {
            Logger.getLogger(AddMaterialController.class.getName()).log(Level.SEVERE, "Unexpected error", e);
            request.setAttribute("message", "Đã xảy ra lỗi không mong muốn!");
            request.setAttribute("messageType", "error");
        }
        
        // Reload form data and forward
        try {
            loadFormData(request);
            request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(AddMaterialController.class.getName()).log(Level.SEVERE, "Error loading form data", ex);
            throw new ServletException("Không thể tải dữ liệu form", ex);
        }
    }
    
    private void loadFormData(HttpServletRequest request) throws SQLException {
        // Get parent categories for dropdown
        List<MaterialCategory> parentCategories = categoryDAO.getAllParentCategories2();
        request.setAttribute("parentCategories", parentCategories);
        
        // Get all child categories for autocomplete (chỉ lấy active)
        List<MaterialCategory> childCategories = categoryDAO.getAllActiveChildCategories();
        request.setAttribute("childCategories", childCategories);
        
        // Get all units for autocomplete
        List<String> units = materialDAO.getUnits();
        request.setAttribute("units", units);
    }
    
// Auto-generate code based on name and timestamp

}