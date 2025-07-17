//invenServlet

package controller.inventory;

import Dal.DBContext;
import dao.InventoryDAO;
import model.Inventory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.util.List;


public class InventoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Retrieve parameters from the request
        String materialId = request.getParameter("materialId");
        String materialName = request.getParameter("materialName");
        String condition = request.getParameter("condition");
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        String pageParam = request.getParameter("page");
        String sortOrder = request.getParameter("sortOrder");

        // Debugging: Log parameters
        System.out.println("Received parameters: materialId=" + materialId + ", materialName=" + materialName
                + ", condition=" + condition + ", fromDate=" + fromDateStr + ", toDate=" + toDateStr
                + ", page=" + pageParam + ", sortOrder=" + sortOrder);

        // Set up pagination
        int page = (pageParam != null && !pageParam.trim().isEmpty()) ? Integer.parseInt(pageParam) : 1;
        int pageSize = 10;

        // Convert dates
        Date fromDate = null;
        Date toDate = null;
        try {
            if (fromDateStr != null && !fromDateStr.trim().isEmpty()) {
                fromDate = java.sql.Date.valueOf(fromDateStr);
            }
            if (toDateStr != null && !toDateStr.trim().isEmpty()) {
                toDate = java.sql.Date.valueOf(toDateStr);
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Invalid date format. Use YYYY-MM-DD.");
            request.getRequestDispatcher("inventory.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            InventoryDAO dao = new InventoryDAO(conn);
            List<Inventory> inventoryList;
            int totalRecords;

            // Handle search or display all
            if ((materialId != null && !materialId.trim().isEmpty())
                    || (materialName != null && !materialName.trim().isEmpty())
                    || (condition != null && !condition.trim().isEmpty())
                    || (fromDate != null || toDate != null)) {
                inventoryList = dao.searchInventory(materialId, materialName, condition, fromDate, toDate, page, pageSize, sortOrder);
                totalRecords = dao.countInventory(materialId, materialName, condition, fromDate, toDate);
            } else {
                inventoryList = dao.searchInventory(null, null, null, null, null, page, pageSize, sortOrder);
                totalRecords = dao.countInventory(null, null, null, null, null);
            }

            // Calculate total pages
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

            // Set attributes for JSP
            request.setAttribute("inventoryData", inventoryList);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("materialId", materialId);
            request.setAttribute("materialName", materialName);
            request.setAttribute("condition", condition);
            request.setAttribute("fromDate", fromDateStr);
            request.setAttribute("toDate", toDateStr);
            request.setAttribute("sortOrder", sortOrder);

            // Debugging: Log results
            System.out.println("Inventory list size: " + inventoryList.size() + ", Total pages: " + totalPages);

            // Forward to JSP
            request.getRequestDispatcher("inventory.jsp").forward(request, response);
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
        return "Servlet to handle inventory requests with search, pagination, and sorting";
    }
}
