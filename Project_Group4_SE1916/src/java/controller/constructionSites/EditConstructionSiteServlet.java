/*
 * Servlet to handle adding and editing construction sites with role-based access control.
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
import java.sql.Date;

/**
 *
 * @author Admin
 */
public class EditConstructionSiteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("admin") && !role.equals("direction"))) {
            request.getSession().setAttribute("error", "You do not have permission to add or edit construction sites.");
            response.sendRedirect("ListConstructionSites");
            return;
        }

        String siteId = request.getParameter("siteId");
        if (siteId != null && !siteId.isEmpty()) {
            try (Connection conn = DBContext.getConnection()) {
                ConstructionSiteDAO dao = new ConstructionSiteDAO(conn);
                ConstructionSite site = dao.getConstructionSiteById(Integer.parseInt(siteId));
                if (site != null) {
                    request.setAttribute("constructionSite", site);
                } else {
                    request.getSession().setAttribute("error", "Construction site not found.");
                    response.sendRedirect("ListConstructionSites");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.getSession().setAttribute("error", "An error occurred while retrieving the construction site.");
                response.sendRedirect("ListConstructionSites");
                return;
            }
        }

        try (Connection conn = DBContext.getConnection()) {
            String sql = "SELECT user_id, full_name FROM Users WHERE role_id IN (SELECT role_id FROM Roles WHERE role_name = 'direction')";
            java.util.List<String[]> managers = new java.util.ArrayList<>();
            try (java.sql.PreparedStatement ps = conn.prepareStatement(sql);
                 java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    managers.add(new String[]{rs.getString("user_id"), rs.getString("full_name")});
                }
            }
            request.setAttribute("managers", managers);
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred while retrieving managers.");
            response.sendRedirect("ListConstructionSites");
            return;
        }

        request.getRequestDispatcher("/view/constructionSites/editConstructionSite.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("admin") && !role.equals("direction"))) {
            request.getSession().setAttribute("error", "You do not have permission to add or edit construction sites.");
            response.sendRedirect("ListConstructionSites");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ConstructionSiteDAO dao = new ConstructionSiteDAO(conn);
            ConstructionSite site = new ConstructionSite();

            String siteId = request.getParameter("siteId");
            if (siteId != null && !siteId.isEmpty()) {
                site.setSiteId(Integer.parseInt(siteId));
            }

            site.setSiteName(request.getParameter("siteName"));
            site.setAddress(request.getParameter("address"));
            site.setManagerId(Integer.parseInt(request.getParameter("managerId")));
            String startDate = request.getParameter("startDate");
            if (startDate != null && !startDate.isEmpty()) {
                site.setStartDate(Date.valueOf(startDate));
            }
            String endDate = request.getParameter("endDate");
            if (endDate != null && !endDate.isEmpty()) {
                site.setEndDate(Date.valueOf(endDate));
            }
            site.setStatus(request.getParameter("status"));
            site.setNote(request.getParameter("note"));

            boolean success;
            if (siteId != null && !siteId.isEmpty()) {
                success = dao.updateConstructionSite(site);
            } else {
                success = dao.addConstructionSite(site);
            }

            if (success) {
                response.sendRedirect("ListConstructionSites");
            } else {
                request.getSession().setAttribute("error", "Failed to save construction site.");
                request.getRequestDispatcher("/view/constructionSites/editConstructionSite.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred while saving the construction site.");
            request.getRequestDispatcher("/view/constructionSites/editConstructionSite.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for adding and editing construction sites";
    }
}