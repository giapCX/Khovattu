package controller;

import dao.MaterialDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Material;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

public class MaterialAutocompleteServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(MaterialAutocompleteServlet.class.getName());
    private MaterialDAO materialDAO;

    @Override
    public void init() throws ServletException {
        materialDAO = new MaterialDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String term = request.getParameter("term");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("[");

        try {
            List<Material> materials = materialDAO.searchMaterialsByName(term);
            boolean first = true;
            for (Material material : materials) {
                if (!first) {
                    out.print(",");
                }
                out.print("{");
                out.print("\"material_id\":" + material.getMaterialId() + ",");
                out.print("\"name\":\"" + escapeJson(material.getName()) + "\",");
                out.print("\"unit\":\"" + escapeJson(material.getUnit()) + "\"");
                out.print("}");
                first = false;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching materials for autocomplete", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

        out.print("]");
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // Hỗ trợ cả POST để tương thích
    }

    // Helper method to escape special characters in JSON strings
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}