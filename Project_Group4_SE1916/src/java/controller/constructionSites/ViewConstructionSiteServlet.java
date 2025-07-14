/*
 * Servlet to handle viewing details of a construction site.
 */
package controller.constructionSites;

import dao.ConstructionSiteDAO;
import Dal.DBContext;
import model.ConstructionSite;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;

/**
 *
 * @author Admin
 */
public class ViewConstructionSiteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String siteId = request.getParameter("siteId");
        if (siteId == null || siteId.isEmpty()) {
            request.getSession().setAttribute("error", "No construction site ID provided.");
            response.sendRedirect("ListConstructionSites");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ConstructionSiteDAO dao = new ConstructionSiteDAO(conn);
            ConstructionSite site = dao.getConstructionSiteById(Integer.parseInt(siteId));
            if (site == null) {
                request.getSession().setAttribute("error", "Construction site not found.");
                response.sendRedirect("ListConstructionSites");
                return;
            }

            // Fetch manager's full name
            String sql = "SELECT full_name FROM Users WHERE user_id = ?";
            try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, site.getManagerId());
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("managerName", rs.getString("full_name"));
                    } else {
                        request.setAttribute("managerName", "Unknown");
                    }
                }
            }

            request.setAttribute("constructionSite", site);
            request.getRequestDispatcher("/view/constructionSites/viewConstructionSite.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred while retrieving the construction site details.");
            response.sendRedirect("ListConstructionSites");
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for viewing construction site details";
    }
}