package controller.importhistory;

import Dal.DBContext;
import dao.ImportDAO;
import dao.ProposalDAO;
import dao.UserDAO;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Import;
import model.ImportDetail;
import model.Proposal;
import model.User;

public class ImportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String proposalIdStr = request.getParameter("proposalId");
        Integer proposalId = null;
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        if (role == null || !role.equals("warehouse")) {
            request.setAttribute("error", "Access denied. Please log in as warehouse.");
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            Proposal proposal = null;
            if (proposalIdStr != null) {
                try {
                    proposalId = Integer.parseInt(proposalIdStr);
                    proposal = proposalDAO.getProposalWithDetailsById(proposalId);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid proposal ID: " + proposalIdStr);
                }
            }

            UserDAO userDAO = new UserDAO();
            List<User> activeUsers = userDAO.getAllActiveUsers() != null ? userDAO.getAllActiveUsers() : new ArrayList<>();
            request.setAttribute("activeUsers", activeUsers);
            request.setAttribute("proposal", proposal);
            request.setAttribute("proposalId", proposalId);
            request.setAttribute("proposalType", proposal != null ? proposal.getProposalType() : request.getParameter("proposalType"));
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");
        if (role == null || !role.equals("warehouse") || userId == null) {
            response.sendRedirect(request.getContextPath() + "/view/warehouse/importData.jsp?error=Unauthorized");
            return;
        }

        String proposalIdStr = request.getParameter("proposalId");
        Integer proposalId = null;
        try {
            if (proposalIdStr != null && !proposalIdStr.isEmpty()) {
                proposalId = Integer.parseInt(proposalIdStr);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid proposal ID: " + proposalIdStr);
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            return;
        }

        String responsibleIdStr = request.getParameter("responsibleId");
        Integer responsibleId = responsibleIdStr != null && !responsibleIdStr.isEmpty() ? Integer.parseInt(responsibleIdStr) : null;
        String importDateStr = request.getParameter("importDate");
        Timestamp importDate = null;
        try {
            if (importDateStr != null && !importDateStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                sdf.setLenient(false);
                Date parsedDate = sdf.parse(importDateStr.replace("T", " "));
                importDate = new Timestamp(parsedDate.getTime());
            } else {
                importDate = new Timestamp(System.currentTimeMillis());
            }
        } catch (Exception e) {
            request.setAttribute("error", "Invalid date format. Use yyyy-MM-dd HH:mm.");
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            return;
        }
        String note = request.getParameter("note");
        System.out.println("Note received: " + note);
        if (note == null || note.trim().isEmpty()) {
            System.out.println("Warning: Note is null or empty");
        }
        String deliverySupplierName = request.getParameter("deliverySupplierName");
        String deliverySupplierPhone = request.getParameter("deliverySupplierPhone");
        String proposalType = request.getParameter("proposalType");

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            ImportDAO importDAO = new ImportDAO(conn);
            Proposal proposal = null;
            if (proposalId != null) {
                proposal = proposalDAO.getProposalWithDetailsById(proposalId);
                if (proposal == null || !proposal.getFinalStatus().equals("approved_but_not_executed")) {
                    request.setAttribute("error", "Proposal not found or not approved for import.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
            }

            if (proposalType == null || proposalType.isEmpty()) {
                request.setAttribute("error", "Proposal type is required.");
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                return;
            }

            Import importOb = new Import();
            importOb.setProposalId(proposalId != null ? proposalId : 0);
            importOb.setImportType(proposalType);
            importOb.setImportDate(importDate);
            importOb.setNote(note != null ? note : "");
            importOb.setExecutorId(userId);

            if ("import_from_supplier".equals(proposalType)) {
                if (deliverySupplierName == null || deliverySupplierName.trim().isEmpty() || deliverySupplierPhone == null || deliverySupplierPhone.trim().isEmpty()) {
                    request.setAttribute("error", "Delivery Supplier Name and Phone are required for Purchase.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
                importOb.setDeliverySupplierName(deliverySupplierName);
                importOb.setDeliverySupplierPhone(deliverySupplierPhone);
            } else if ("import_returned".equals(proposalType)) {
                if (responsibleId == null) {
                    request.setAttribute("error", "Responsible ID is required for Retrieve.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
                importOb.setResponsibleId(responsibleId);
            }

            if (proposal != null) {
                importOb.setProposal(proposal);
                List<ImportDetail> importDetails = new ArrayList<>();
                for (var pd : proposal.getProposalDetails()) {
                    ImportDetail id = new ImportDetail();
                    id.setMaterialId(pd.getMaterialId());
                    id.setQuantity(pd.getQuantity());
                    id.setPrice(pd.getPrice());
                    id.setMaterialCondition(pd.getMaterialCondition());
                    importDetails.add(id);
                }
                importOb.setImportDetail(importDetails);
            }

            if (importDAO.addImport(importOb)) {
                if (proposal != null && importOb.getImportDetail() != null) {
                    importDAO.addToInventory(importOb.getImportDetail());
                    importDAO.updateProposalStatusToExecuted(proposalId);
                }
                response.sendRedirect(request.getContextPath() + "/view/warehouse/importData.jsp?success=Import successful&proposalId=" + (proposalId != null ? proposalId : ""));
            } else {
                request.setAttribute("error", "Failed to process import.");
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        }
    }
}