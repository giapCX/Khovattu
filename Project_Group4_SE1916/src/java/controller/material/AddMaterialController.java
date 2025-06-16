package controller.material;

import Dal.DBContext;
import dao.MaterialDAO;
import dao.MaterialCategoryDAO;
import dao.SupplierDAO;
import model.Material;
import model.MaterialCategory;
import model.Supplier;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

// em note các bước ra để sau đọc lại hiểu luôn nên thầy đừng bắt bẻ em nhá =(( 
public class AddMaterialController extends HttpServlet {

    private MaterialDAO materialDAO;
    private MaterialCategoryDAO categoryDAO;
    private SupplierDAO supplierDAO;

    // Khởi tạo các DAO khi servlet được tạo
    @Override
    public void init() throws ServletException {
        materialDAO = new MaterialDAO();
        categoryDAO = new MaterialCategoryDAO();
        Connection conn = DBContext.getConnection();
        supplierDAO = new SupplierDAO(conn);
    }

    // Xử lý GET request: Hiển thị form thêm vật tư
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Lấy danh sách danh mục và nhà cung cấp từ database
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();

            // Gửi dữ liệu tới JSP để hiển thị form
            request.setAttribute("categories", categories);
            request.setAttribute("suppliers", suppliers);
            request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            // Nếu có lỗi khi lấy dữ liệu, ném ngoại lệ để server báo lỗi chi tiết
            throw new ServletException("Không thể lấy dữ liệu cho form", e);
        }
    }

    // Xử lý POST request: Lưu thông tin vật tư từ form
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Tạo đối tượng Material để lưu thông tin từ form
        Material material = new Material();

        try {
            // 1. Lấy dữ liệu từ form
            material.setCode(request.getParameter("code"));
            material.setName(request.getParameter("name"));
            material.setDescription(request.getParameter("description"));
            material.setUnit(request.getParameter("unit"));
            material.setImageUrl(request.getParameter("imageUrl"));

            // 2. Lấy và gán category
            String categoryIdStr = request.getParameter("category");
            int categoryId = Integer.parseInt(categoryIdStr); // Chuyển chuỗi thành số
            MaterialCategory category = new MaterialCategory();
            category.setCategoryId(categoryId);
            material.setCategory(category);

            // 3. Lấy danh sách supplier
            String[] supplierIds = request.getParameterValues("suppliers");
            List<Integer> supplierIdList = new ArrayList<>();
            if (supplierIds != null) {
                for (String id : supplierIds) {
                    supplierIdList.add(Integer.parseInt(id)); // Chuyển mỗi ID thành số
                }
            }

            // 4. Lưu vật tư vào database
            materialDAO.addMaterial(material, supplierIdList);

            // 5. Hiển thị thông báo thành công
            request.setAttribute("message", "Thêm vật tư thành công!");
            request.setAttribute("messageType", "success");
        } catch (NumberFormatException e) {
            // Nếu dữ liệu nhập vào không đúng định dạng (ví dụ: category không phải số)
            request.setAttribute("message", "Dữ liệu không hợp lệ! Vui lòng kiểm tra lại.");
            request.setAttribute("messageType", "danger");
        } catch (SQLException e) {
            // Xử lý lỗi database
            if (e.getSQLState().equals("23000") && e.getErrorCode() == 1062) {
                // Lỗi trùng mã vật tư
                request.setAttribute("message", "Mã vật tư đã tồn tại!");
            } else {
                // Các lỗi database khác
                request.setAttribute("message", "Lỗi khi lưu vật tư: " + e.getMessage());
            }
            request.setAttribute("messageType", "danger");
        }

        // 6. Tải lại dữ liệu cho form (để người dùng tiếp tục nhập nếu có lỗi)
        try {
            List<MaterialCategory> categories = categoryDAO.getAllChildCategories();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            request.setAttribute("categories", categories);
            request.setAttribute("suppliers", suppliers);
        } catch (SQLException e) {
            throw new ServletException("Không thể lấy dữ liệu cho form", e);
        }

        // 7. Chuyển lại về trang JSP để hiển thị kết quả
        request.getRequestDispatcher("/view/material/addMaterial.jsp").forward(request, response);
    }
}