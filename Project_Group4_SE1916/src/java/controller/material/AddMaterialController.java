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
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Không thể lấy dữ liệu cho form", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Material material = new Material();

        try {
            // Lấy dữ liệu từ form
            material.setCode(request.getParameter("code"));
            material.setName(request.getParameter("name"));
            material.setDescription(request.getParameter("description"));
            material.setUnit(request.getParameter("unit"));

            // Xử lý upload ảnh
            Part filePart = request.getPart("imageFile");
            String imageUrl = "";
            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("message", "Vui lòng chọn ảnh cho vật tư.");
                request.setAttribute("messageType", "danger");
                List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
                request.setAttribute("categories", categories);
                request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
                return;
            }

            if (filePart != null && filePart.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_" + Path.of(filePart.getSubmittedFileName()).getFileName();

                // ✅ 1. Ghi vào thư mục build để có thể hiển thị khi chạy
                String buildPath = request.getServletContext().getRealPath("/uploads");
                File buildDir = new File(buildPath);
                if (!buildDir.exists()) {
                    buildDir.mkdirs();
                }
                filePart.write(buildPath + File.separator + fileName);

                // ✅ 2. Copy về thư mục dự án để không bị mất khi Clean & Build
                File buildDirFile = new File(buildPath);
                File projectRoot = buildDirFile.getParentFile().getParentFile().getParentFile(); // build/web/uploads → build/web → build → root
                File sourceUploadDir = new File(projectRoot, "web/uploads");
                if (!sourceUploadDir.exists()) {
                    sourceUploadDir.mkdirs();
                }

                Path source = Path.of(buildPath, fileName);
                Path target = Path.of(sourceUploadDir.getAbsolutePath(), fileName);
                Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);

                imageUrl = "uploads/" + fileName;
            }

            material.setImageUrl(imageUrl);

            // Lấy và gán category
            int categoryId = Integer.parseInt(request.getParameter("category"));
            MaterialCategory category = new MaterialCategory();
            category.setCategoryId(categoryId);
            material.setCategory(category);

            // Lưu vào CSDL
            materialDAO.addMaterial(material);
            request.setAttribute("message", "Thêm vật tư thành công!");
            request.setAttribute("messageType", "success");

        } catch (NumberFormatException e) {
            request.setAttribute("message", "Dữ liệu không hợp lệ! Vui lòng kiểm tra lại.");
            request.setAttribute("messageType", "danger");
        } catch (SQLException e) {
            if ("23000".equals(e.getSQLState()) && e.getErrorCode() == 1062) {
                request.setAttribute("message", "Mã vật tư đã tồn tại!");
            } else {
                request.setAttribute("message", "Lỗi khi lưu vật tư: " + e.getMessage());
            }
            request.setAttribute("messageType", "danger");
        }

        // Tải lại danh sách category
        try {
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            request.setAttribute("categories", categories);
        } catch (SQLException e) {
            throw new ServletException("Không thể lấy dữ liệu cho form", e);
        }

        request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
    }
}
