
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://.netbeans/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
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
import java.net.URLEncoder;


public class UnitServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("toggle".equals(action)) {
            // Handle toggle request
            String unitIdStr = request.getParameter("unitId");
            String currentStatus = request.getParameter("status");
            String nameFilter = request.getParameter("name");
            String page = request.getParameter("page");

            // Validate parameters
            if (unitIdStr == null || currentStatus == null) {
                request.setAttribute("errorMessage", "Invalid unit ID or status");
                displayUnitList(request, response, nameFilter, page, null);
                return;
            }

            try (Connection conn = DBContext.getConnection()) {
                UnitDAO dao = new UnitDAO(conn);
                int unitId = Integer.parseInt(unitIdStr);

                // Validate status
                if (!currentStatus.equals("active") && !currentStatus.equals("inactive")) {
                    request.setAttribute("errorMessage", "Invalid status value");
                    displayUnitList(request, response, nameFilter, page, null);
                    return;
                }

                // Check role-based access
                String role = (String) request.getSession().getAttribute("role");
                if (!"admin".equals(role) && !"warehouse".equals(role)) {
                    request.setAttribute("errorMessage", "Unauthorized access");
                    displayUnitList(request, response, nameFilter, page, null);
                    return;
                }

                // Toggle status
//                boolean updated = dao.toggleUnitStatus(unitId, currentStatus);
                String sortByStatus = request.getParameter("sortByStatus");
//                if (updated) {
                    // Redirect to the unit list with the same filters
                    String redirectUrl = "unit?page=" + (page != null ? page : "1");
                    if (nameFilter != null && !nameFilter.trim().isEmpty()) {
                        redirectUrl += "&name=" + URLEncoder.encode(nameFilter, "UTF-8");
                    }
                    
                    if (sortByStatus != null && !sortByStatus.trim().isEmpty()) {
                        redirectUrl += "&sortByStatus=" + URLEncoder.encode(sortByStatus, "UTF-8");
                    }
                    response.sendRedirect(redirectUrl);
//                } else {
//                    request.setAttribute("errorMessage", "Failed to toggle unit status");
//                    displayUnitList(request, response, nameFilter, page, sortByStatus);
//                }
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Error toggling unit status: " + e.getMessage());
                displayUnitList(request, response, nameFilter, page, null);
            }
        } else {
            // Handle unit list request
            String name = request.getParameter("name");
            String pageParam = request.getParameter("page");
            String sortByStatus = request.getParameter("sortByStatus");

            // Debugging: Log parameters
            System.out.println("Received parameters: name=" + name + ", page=" + pageParam + ", sortByStatus=" + sortByStatus);

            displayUnitList(request, response, name, pageParam, sortByStatus);
        }
    }

    private void displayUnitList(HttpServletRequest request, HttpServletResponse response, String name, String pageParam, String sortByStatus)
            throws ServletException, IOException {
        // Set up pagination
        int page = (pageParam != null && !pageParam.trim().isEmpty()) ? Integer.parseInt(pageParam) : 1;
        int pageSize = 10;

        try (Connection conn = DBContext.getConnection()) {
            UnitDAO dao = new UnitDAO(conn);
            List<Unit> unitList;
            int totalRecords;

            // Handle search or display all with status filter
            if (name != null && !name.trim().isEmpty()) {
                unitList = dao.searchUnits(name, sortByStatus, page, pageSize);
                totalRecords = dao.countUnits(name, sortByStatus);
            } else {
                unitList = dao.searchUnits(null, sortByStatus, page, pageSize);
                totalRecords = dao.countUnits(null, sortByStatus);
            }

            // Calculate total pages
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

            // Set attributes for JSP
            request.setAttribute("unitData", unitList);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("name", name);
            request.setAttribute("sortByStatus", sortByStatus); // Pass sortByStatus to JSP

            // Debugging: Log results
            System.out.println("Unit list size: " + unitList.size() + ", Total pages: " + totalPages);

            // Forward to JSP
            request.getRequestDispatcher("unitList.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error retrieving units: " + e.getMessage());
            request.getRequestDispatcher("unitList.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // Handle POST the same as GET
    }

    @Override
    public String getServletInfo() {
        return "Servlet to handle unit requests with search, pagination, and status toggling";
    }
}