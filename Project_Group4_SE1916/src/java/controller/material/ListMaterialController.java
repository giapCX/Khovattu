package controller.material;

import dao.MaterialDAO;
import dao.MaterialCategoryDAO;
import model.Material;
import model.MaterialCategory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ListMaterialController", urlPatterns = {"/listMaterialController"})
public class ListMaterialController extends HttpServlet {
    private MaterialDAO materialDAO;
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        materialDAO = new MaterialDAO();
        categoryDAO = new MaterialCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            listMaterials(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if (action.equals("delete")) {
                deleteMaterial(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void listMaterials(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        List<Material> materials = materialDAO.getAllMaterials();
        List<MaterialCategory> categories = categoryDAO.getAllCategories();
        
        request.setAttribute("materials", materials);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/view/material/listMaterial.jsp").forward(request, response);
    }

    private void deleteMaterial(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        int materialId = Integer.parseInt(request.getParameter("id"));
        materialDAO.deleteMaterial(materialId);
        request.getSession().setAttribute("successMessage", "Xóa vật tư thành công!");
        response.sendRedirect(request.getContextPath() + "/ListMaterialController?action=list");
    }
}