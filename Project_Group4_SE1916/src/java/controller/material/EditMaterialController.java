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
            List<MaterialCategory> categories = categoryDAO.getAllCategories();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();

            // 3. Gửi dữ liệu tới JSP để hiển thị form
            request.setAttribute("material", material);
            request.setAttribute("categories", categories);
            request.setAttribute("suppliers", suppliers);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            // Nếu có lỗi khi lấy dữ liệu, báo lỗi chi tiết
            throw new ServletException("Không thể lấy dữ liệu vật tư", e);
        } catch (NumberFormatException e) {
            // Nếu ID không hợp lệ (không phải số)
            throw new ServletException("ID vật tư không hợp lệ", e);
        }
    }

    // Xử lý POST request: Lưu thông tin chỉnh sửa vật tư
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Tạo đối tượng Material để chứa thông tin từ form
        Material material = new Material();

        try {
            // 1. Lấy dữ liệu từ form và gán vào đối tượng Material
            material.setMaterialId(Integer.parseInt(request.getParameter("id")));
            material.setCode(request.getParameter("code"));
            material.setName(request.getParameter("name"));
            material.setDescription(request.getParameter("description"));
            material.setUnit(request.getParameter("unit"));
            material.setImageUrl(request.getParameter("imageUrl"));

            // 2. Lấy và gán danh mục (category)
            String categoryIdStr = request.getParameter("category");
            int categoryId = Integer.parseInt(categoryIdStr); // Chuyển chuỗi thành số
            MaterialCategory category = new MaterialCategory();
            category.setCategoryId(categoryId);
            material.setCategory(category);

            // 3. Lấy danh sách nhà cung cấp (suppliers)
            String[] supplierIds = request.getParameterValues("suppliers");
            List<Integer> supplierIdList = new ArrayList<>();
            if (supplierIds != null) {
                for (String id : supplierIds) {
                    supplierIdList.add(Integer.parseInt(id)); // Chuyển mỗi ID thành số
                }
            }

            // 4. Cập nhật vật tư trong database
            materialDAO.updateMaterial(material, supplierIdList);

            // 5. Lưu thông báo thành công vào session
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Cập nhật vật tư thành công!");

            // 6. Chuyển hướng về trang danh sách vật tư
            response.sendRedirect(request.getContextPath() + "/ListMaterialController?action=list");
        } catch (NumberFormatException e) {
            // Lỗi khi dữ liệu nhập vào không đúng định dạng (ví dụ: ID hoặc category không phải số)
            request.setAttribute("message", "Dữ liệu không hợp lệ! Vui lòng kiểm tra lại.");
            request.setAttribute("messageType", "danger");
            // Tải lại dữ liệu để hiển thị form
            reloadFormData(request);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            // Xử lý lỗi từ database
            request.setAttribute("message", "Lỗi khi cập nhật vật tư: " + e.getMessage());
            request.setAttribute("messageType", "danger");
            // Tải lại dữ liệu để hiển thị form
            reloadFormData(request);
            request.getRequestDispatcher("/view/material/editMaterial.jsp").forward(request, response);
        }
    }

    // Hàm hỗ trợ: Tải lại dữ liệu cho form khi có lỗi
    private void reloadFormData(HttpServletRequest request) throws ServletException {
        try {
            List<MaterialCategory> categories = categoryDAO.getAllCategories();
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
            throw new ServletException("Không thể tải lại dữ liệu cho form", e);
        }
    }
}