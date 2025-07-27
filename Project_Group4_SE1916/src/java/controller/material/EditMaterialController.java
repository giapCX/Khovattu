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
import java.util.regex.Pattern;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class EditMaterialController extends HttpServlet {

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
            int materialId = Integer.parseInt(request.getParameter("id"));
            String origin = request.getParameter("origin");
            Material material = materialDAO.getMaterialById(materialId);
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            request.setAttribute("material", material);
            request.setAttribute("categories", categories);
            request.setAttribute("origin", origin);
            
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Failed to retrieve material data", e);
        } catch (NumberFormatException e) {
            throw new ServletException("Invalid material ID", e);
        }
        
       
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Material material = new Material();
        String origin = request.getParameter("origin");

        try {
            String materialIdStr = request.getParameter("id");
            //String code = request.getParameter("code");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String unit = request.getParameter("unit");
            String categoryIdStr = request.getParameter("category");

            StringBuilder errorMessage = new StringBuilder();

            // Validate material ID
            if (materialIdStr == null || materialIdStr.trim().isEmpty()) {
                errorMessage.append("Material ID is required. ");
            } else if (!materialIdStr.matches("\\d+")) {
                errorMessage.append("Material ID must be a number. ");
            }

            // Validate code
//            if (code == null || code.trim().isEmpty()) {
//                errorMessage.append("Code is required. ");
//            } else if (code.length() > 50) {
//                errorMessage.append("Code must not exceed 50 characters. ");
//            } else if (!Pattern.matches("^[a-zA-Z0-9_.-]+$", code)) {
//                errorMessage.append("Code can only contain letters, numbers, underscores, dots, and hyphens. ");
//            }

            // Validate name
            if (name == null || name.trim().isEmpty()) {
                errorMessage.append("Name is required. ");
            } else if (name.length() > 100) {
                errorMessage.append("Name must not exceed 100 characters. ");
            } else if (!Pattern.matches("^[\\p{L}\\d\\s_.-]+$", name)) {
                errorMessage.append("Name can only contain letters (including Vietnamese), numbers, spaces, underscores, dots, and hyphens. ");
            }

            // Validate description
            if (description != null && description.length() > 500) {
                errorMessage.append("Description must not exceed 500 characters. ");
            }

            // Validate unit
            if (unit == null || unit.trim().isEmpty()) {
                errorMessage.append("Unit is required. ");
            } else if (unit.length() > 20) {
                errorMessage.append("Unit must not exceed 20 characters. ");
            } else if (!Pattern.matches("^[\\p{L}\\d\\s_-]+$", unit)) {
                errorMessage.append("Unit can only contain letters (including Vietnamese), numbers, spaces, underscores, and hyphens. ");
            }

            // Validate category
            if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
                errorMessage.append("Category is required. ");
            } else if (!categoryIdStr.matches("\\d+")) {
                errorMessage.append("Invalid category selection. ");
            }

            // Validate duplicate name in sub category
//            int subCategoryId = Integer.parseInt(categoryIdStr);
//            if (materialDAO.isMaterialNameExistsInSubCategory(name, subCategoryId)) {
//                errorMessage.append("Material name already exists in this sub category! ");
//            }
            // Handle image upload
            Part filePart = request.getPart("imageFile");
            String imageUrl = "";

            // Get the current material to preserve existing image if no new image is uploaded
            Material currentMaterial = materialDAO.getMaterialById(Integer.parseInt(materialIdStr));
            String currentImageUrl = currentMaterial.getImageUrl();

            if (filePart != null && filePart.getSize() > 0) {
                // Validate file type
                String contentType = filePart.getContentType();
                if (!contentType.startsWith("image/")) {
                    request.setAttribute("message", "Please select a valid image file!");
                    request.setAttribute("messageType", "error");
                    
                    request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
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
                    Logger.getLogger(EditMaterialController.class.getName()).log(Level.WARNING, "Could not copy to source directory", e);
                }

                imageUrl = "uploads/" + fileName;
            } else {
                // Keep the existing image if no new image is uploaded
                imageUrl = currentImageUrl;
            }

            material.setImageUrl(imageUrl);

            // If there are validation errors, reload form with error message
            if (errorMessage.length() > 0) {
                request.setAttribute("message", errorMessage.toString());
                request.setAttribute("messageType", "danger");
                reloadFormData(request, materialIdStr, name, description, unit, imageUrl);
                request.setAttribute("origin", origin);
                request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
                return;
            }

            // Set material properties
            material.setMaterialId(Integer.parseInt(materialIdStr));
            // Don't update code field since it's not editable in the form
            material.setName(name.trim());
            material.setDescription(description != null ? description.trim() : "");
            material.setUnit(unit.trim());
            material.setImageUrl(imageUrl);

            int categoryId = Integer.parseInt(categoryIdStr);
            MaterialCategory category = new MaterialCategory();
            category.setCategoryId(categoryId);
            material.setCategory(category);

            // Update in database
            materialDAO.updateMaterial(material);

            request.setAttribute("message", "Update material success!");
            request.setAttribute("messageType", "success");

            // Reload form data
            reloadFormData(request, materialIdStr, name, description, unit, imageUrl);
            Material updatedMaterial = materialDAO.getMaterialById(material.getMaterialId());
            request.setAttribute("material", updatedMaterial);
            request.setAttribute("origin", origin);

            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("message", "Invalid input! Please check your data.");
            request.setAttribute("messageType", "danger");
            reloadFormData(request, request.getParameter("id"),
                    request.getParameter("name"), request.getParameter("description"),
                    request.getParameter("unit"), "");
            request.setAttribute("origin", origin);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("message", "Error updating material: " + e.getMessage());
            request.setAttribute("messageType", "danger");
            reloadFormData(request, request.getParameter("id"),
                    request.getParameter("name"), request.getParameter("description"),
                    request.getParameter("unit"), "");
            request.setAttribute("origin", origin);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        }
    }

    private void reloadFormData(HttpServletRequest request, String materialId,
            String name, String description, String unit, String imageUrl)
            throws ServletException {
        try {
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            request.setAttribute("categories", categories);

            Material material = new Material();
            if (materialId != null && materialId.matches("\\d+")) {
                material.setMaterialId(Integer.parseInt(materialId));
                // Get the current material to preserve its category
                Material currentMaterial = materialDAO.getMaterialById(Integer.parseInt(materialId));
                material.setCategory(currentMaterial.getCategory());
            } else {
                // Set a default category if material ID is invalid
                MaterialCategory defaultCategory = new MaterialCategory();
                defaultCategory.setCategoryId(1);
                material.setCategory(defaultCategory);
            }
            // Don't set code since it's not editable in the form
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
