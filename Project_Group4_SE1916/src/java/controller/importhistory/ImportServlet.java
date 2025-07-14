package controller.importhistory;

import Dal.DBContext;
import dao.ImportDAO;
import dao.ProposalDAO;
import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Import;
import model.ImportDetail;
import model.Proposal;
import model.User;

/**
 *
 * @author Admin
 */
public class ImportServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ImportServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ImportServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer proposalId = Integer.parseInt(request.getParameter("proposalId"));
        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            Proposal proposal = proposalDAO.getProposalWithDetailsById(proposalId);
            UserDAO userDAO = new UserDAO();
            List<User> activeUsers = userDAO.getAllActiveUsers();
            request.setAttribute("activeUsers", activeUsers);
            request.setAttribute("proposal", proposal);
            request.setAttribute("proposalId", proposalId);
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String proposalId = request.getParameter("proposalId");
        String proposalType = request.getParameter("proposalType");
        String importDateStr = request.getParameter("importDate");

        HttpSession session = request.getSession();
        Integer executorId = (Integer) session.getAttribute("userId");
        if (executorId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not logged in");
            return;
        }
        String note = request.getParameter("note");
        String[] materialIds = request.getParameterValues("materialId[]");
        String[] units = request.getParameterValues("unit[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] conditions = request.getParameterValues("materialCondition[]");
        String[] supplierIds = request.getParameterValues("supplierIds[]");
        String[] prices = request.getParameterValues("pricePerUnit[]");
        String[] siteIds = request.getParameterValues("siteId[]");

        // Validate input arrays
        if (materialIds == null || units == null || quantities == null || conditions == null ||
            materialIds.length == 0 || units.length == 0 || quantities.length == 0 || conditions.length == 0 ||
            materialIds.length != units.length || materialIds.length != quantities.length || materialIds.length != conditions.length) {
            request.setAttribute("error", "Invalid or missing material data");
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            return;
        }

        Import importOb = new Import();
        importOb.setProposalId(Integer.parseInt(proposalId));
        importOb.setImportType(proposalType);
        importOb.setNote(note);

        // Set import date
        Timestamp importDate;
        if (importDateStr != null && !importDateStr.trim().isEmpty()) {
            try {
                importDate = Timestamp.valueOf(importDateStr + " 00:00:00");
            } catch (IllegalArgumentException e) {
                importDate = new Timestamp(System.currentTimeMillis());
            }
        } else {
            importDate = new Timestamp(System.currentTimeMillis());
        }
        importOb.setImportDate(importDate);

        List<ImportDetail> details = new ArrayList<>();

        for (int i = 0; i < materialIds.length; i++) {
            try {
                ImportDetail detail = new ImportDetail();
                detail.setMaterialId(Integer.parseInt(materialIds[i]));
                detail.setQuantity(Double.parseDouble(quantities[i]));
                detail.setUnit(units[i]);
                detail.setMaterialCondition(conditions[i]);

                if ("import_from_supplier".equals(proposalType)) {
                    if (supplierIds != null && i < supplierIds.length && supplierIds[i] != null && !supplierIds[i].trim().isEmpty()) {
                        detail.setSupplierId(Integer.parseInt(supplierIds[i]));
                    }
                    if (prices != null && i < prices.length && prices[i] != null && !prices[i].trim().isEmpty()) {
                        detail.setPrice(Double.parseDouble(prices[i]));
                    }
                } else if ("import_returned".equals(proposalType)) {
                    if (siteIds != null && i < siteIds.length && siteIds[i] != null && !siteIds[i].trim().isEmpty()) {
                        detail.setSiteId(Integer.parseInt(siteIds[i]));
                    }
                    String responsibleId = request.getParameter("responsibleId");
                    if (responsibleId != null && !responsibleId.trim().isEmpty()) {
                        importOb.setResponsibleId(Integer.parseInt(responsibleId));
                    } else {
                        request.setAttribute("error", "Responsible ID is required for import_returned");
                        request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                        return;
                    }
                }

                details.add(detail);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid numeric data in material details");
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                return;
            }
        }
        importOb.setImportDetail(details);

        try (Connection conn = DBContext.getConnection()) {
            ImportDAO importDAO = new ImportDAO(conn);
            boolean isInserted = importDAO.addImport(importOb);
            if (isInserted) {
                importDAO.addToInventory(details);
                importDAO.updateProposalStatusToExecuted(Integer.parseInt(proposalId));
                response.sendRedirect(request.getContextPath() + "/ListProposalExecute?filter=import_only");
            } else {
                request.setAttribute("error", "Failed to submit import");
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles import operations for warehouse";
    }
}