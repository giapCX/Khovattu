/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.unit;

import Dal.DBContext;
import dao.UnitDAO;
import model.Unit;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.util.List;


public class UnitServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Retrieve parameters from the request
        String name = request.getParameter("name");
        String pageParam = request.getParameter("page");

        // Debugging: Log parameters
        System.out.println("Received parameters: name=" + name + ", page=" + pageParam);

        // Set up pagination
        int page = (pageParam != null && !pageParam.trim().isEmpty()) ? Integer.parseInt(pageParam) : 1;
        int pageSize = 10;

        try (Connection conn = DBContext.getConnection()) {
            UnitDAO dao = new UnitDAO(conn);
            List<Unit> unitList;
            int totalRecords;

            // Handle search or display all
            if (name != null && !name.trim().isEmpty()) {
                unitList = dao.searchUnits(name, page, pageSize);
                totalRecords = dao.countUnits(name);
            } else {
                unitList = dao.searchUnits(null, page, pageSize);
                totalRecords = dao.countUnits(null);
            }

            // Calculate total pages
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

            // Set attributes for JSP
            request.setAttribute("unitData", unitList);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("name", name);

            // Debugging: Log results
            System.out.println("Unit list size: " + unitList.size() + ", Total pages: " + totalPages);

            // Forward to JSP
            request.getRequestDispatcher("unitList.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while processing the request.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // Handle POST the same as GET
    }

    @Override
    public String getServletInfo() {
        return "Servlet to handle unit requests with search and pagination";
    }
}
