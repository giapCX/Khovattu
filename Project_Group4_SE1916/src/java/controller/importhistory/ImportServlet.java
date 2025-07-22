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
        System.out.println("ImportServlet.doGet: role=" + role + ", proposalIdStr=" + proposalIdStr);
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
                    System.out.println("ImportServlet.doGet: proposal=" + (proposal != null ? proposal.getProposalId() : "null"));
                } catch (NumberFormatException e) {
                    System.out.println("ImportServlet.doGet: Invalid proposal ID: " + proposalIdStr);
                    request.setAttribute("error", "Invalid proposal ID: " + proposalIdStr);
                }
            }

            UserDAO userDAO = new UserDAO();
            List<User> activeUsers = userDAO.getAllActiveUsers() != null ? userDAO.getAllActiveUsers() : new ArrayList<>();
            System.out.println("ImportServlet.doGet: activeUsers.size=" + activeUsers.size());
            request.setAttribute("activeUsers", activeUsers);
            request.setAttribute("proposal", proposal);
            request.setAttribute("proposalId", proposalId);
            request.setAttribute("proposalType", proposal != null ? proposal.getProposalType() : request.getParameter("proposalType"));
            System.out.println("ImportServlet.doGet: Forwarding to importData.jsp, proposalType=" + request.getAttribute("proposalType"));
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (SQLException e) {
            System.out.println("ImportServlet.doGet: SQLException - " + e.getMessage());
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("ImportServlet.doGet: Exception - " + e.getMessage());
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
        System.out.println("ImportServlet.doPost: role=" + role + ", userId=" + userId);
        if (role == null || !role.equals("warehouse") || userId == null) {
            System.out.println("ImportServlet.doPost: Unauthorized access");
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
            System.out.println("ImportServlet.doPost: Invalid proposal ID: " + proposalIdStr);
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
            System.out.println("ImportServlet.doPost: Invalid date format: " + importDateStr);
            request.setAttribute("error", "Invalid date format. Use yyyy-MM-dd HH:mm.");
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            return;
        }
        String note = request.getParameter("note");
        if (note == null || note.trim().isEmpty()) {
            System.out.println("ImportServlet.doPost: Note is required");
            request.setAttribute("error", "Note is required.");
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            return;
        }
        String deliverySupplierName = request.getParameter("deliverySupplierName");
        String deliverySupplierPhone = request.getParameter("deliverySupplierPhone");
        String proposalType = request.getParameter("proposalType");
        System.out.println("ImportServlet.doPost: proposalId=" + proposalId + ", proposalType=" + proposalType + ", responsibleId=" + responsibleId + ", deliverySupplierName=" + deliverySupplierName + ", deliverySupplierPhone=" + deliverySupplierPhone);

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            ImportDAO importDAO = new ImportDAO(conn);
            Proposal proposal = null;
            if (proposalId != null) {
                proposal = proposalDAO.getProposalWithDetailsById(proposalId);
                if (proposal == null || !proposal.getFinalStatus().equals("approved_but_not_executed")) {
                    System.out.println("ImportServlet.doPost: Proposal not found or not approved, proposalId=" + proposalId);
                    request.setAttribute("error", "Proposal not found or not approved for import.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
                if (proposal.getProposalDetails() == null || proposal.getProposalDetails().isEmpty()) {
                    System.out.println("ImportServlet.doPost: No proposal details found for proposalId=" + proposalId);
                    request.setAttribute("error", "No proposal details found.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
                if (importDAO.checkProposalIdExists(proposalId)) {
                    System.out.println("ImportServlet.doPost: Proposal ID already used, proposalId=" + proposalId);
                    request.setAttribute("error", "Proposal ID has already been used for import.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
            }

            if (proposalType == null || proposalType.isEmpty()) {
                System.out.println("ImportServlet.doPost: Proposal type is required");
                request.setAttribute("error", "Proposal type is required.");
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                return;
            }

            if ("import_from_supplier".equals(proposalType)) {
                if (deliverySupplierName == null || deliverySupplierName.trim().isEmpty() || deliverySupplierPhone == null || deliverySupplierPhone.trim().isEmpty()) {
                    System.out.println("ImportServlet.doPost: Delivery Supplier Name and Phone required for import_from_supplier");
                    request.setAttribute("error", "Delivery Supplier Name and Phone are required for Purchase.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
            } else if ("import_returned".equals(proposalType)) {
                if (responsibleId == null) {
                    System.out.println("ImportServlet.doPost: Responsible ID required for import_returned");
                    request.setAttribute("error", "Responsible ID is required for Retrieve.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
                UserDAO userDAO = new UserDAO();
                if (userDAO.getUserById(responsibleId) == null) {
                    System.out.println("ImportServlet.doPost: Responsible ID does not exist: " + responsibleId);
                    request.setAttribute("error", "Responsible ID does not exist.");
                    request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
                    return;
                }
            }

            Import importOb = new Import();
            importOb.setProposalId(proposalId != null ? proposalId : 0);
            importOb.setImportType(proposalType);
            importOb.setImportDate(importDate);
            importOb.setNote(note);
            importOb.setExecutorId(userId);
            importOb.setDeliverySupplierName(deliverySupplierName);
            importOb.setDeliverySupplierPhone(deliverySupplierPhone);
            importOb.setResponsibleId(responsibleId);

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
                System.out.println("ImportServlet.doPost: Import successful, redirecting to importData.jsp with success message");
                response.sendRedirect(request.getContextPath() + "/view/warehouse/importData.jsp?success=Save successfully");
            } else {
                System.out.println("ImportServlet.doPost: Import failed");
                request.setAttribute("error", "Failed to process import.");
                request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            System.out.println("ImportServlet.doPost: SQLException - " + e.getMessage());
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("ImportServlet.doPost: Exception - " + e.getMessage());
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/importData.jsp").forward(request, response);
        }
    }
}