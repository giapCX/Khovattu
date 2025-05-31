package controller;

import dao.MaterialCategoryDAO;
import model.MaterialCategory;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/materialCategories")
public class MaterialCategoryController extends HttpServlet {
    private Connection conn;
    private MaterialCategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            String url = "jdbc:sqlserver://localhost:1433;databaseName=YOUR_DB_NAME;encrypt=false";
            String user = "YOUR_DB_USER";
            String pass = "YOUR_DB_PASS";
            conn = DriverManager.getConnection(url, user, pass);
            categoryDAO = new MaterialCategoryDAO(conn);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<MaterialCategory> categories = categoryDAO.getAllCategories();
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/view/material/materialCategories.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("add".equals(action)) {
                String name = request.getParameter("name");
                MaterialCategory cat = new MaterialCategory();
                cat.setName(name);
                categoryDAO.addCategory(cat);
            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String name = request.getParameter("name");
                MaterialCategory cat = new MaterialCategory();
                cat.setCategoryId(id);
                cat.setName(name);
                categoryDAO.updateCategory(cat);
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                categoryDAO.deleteCategory(id);
            }
            response.sendRedirect("materialCategories");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    public void destroy() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
} 