//exMa servlet
package controller.importhistory;

import Dal.DBContext;
import dao.ExportDAO;
import dao.ProposalDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.Export;
import model.ExportDetail;
import model.Proposal;
import model.User;
import java.sql.*;
import com.google.gson.Gson;

public class ExportMaterial extends HttpServlet {

    private static final String NOTE_REGEX = "^[A-Za-z0-9\\s,.()-]+$";
    private static final int NOTE_MAX_LENGTH = 1000;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        if (role == null || !role.equals("warehouse")) {
            request.setAttribute("error", "Access denied. Please log in as warehouse.");
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
            return;
        }

        String action = request.getParameter("action");
        if ("getEmployees".equals(action)) {
            try (Connection conn = DBContext.getConnection()) {
                UserDAO userDAO = new UserDAO(conn); // <-- Truyền connection
                List<User> employees = userDAO.getAllEmployees(); // <-- Gọi đúng
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                Gson gson = new Gson();
                String json = gson.toJson(employees);
                response.getWriter().write(json);
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"Database error: " + e.getMessage() + "\"}");
            }
            return;
        }

        String proposalIdStr = request.getParameter("proposalId");
        Integer proposalId = null;
        Proposal proposal = null;

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            if (proposalIdStr != null) {
                try {
                    proposalId = Integer.parseInt(proposalIdStr);
                    proposal = proposalDAO.getProposalWithDetailsById(proposalId);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid proposal ID: " + proposalIdStr);
                }
            }

            request.setAttribute("proposal", proposal);
            request.setAttribute("proposalId", proposalId);
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");
        if (role == null || !role.equals("warehouse") || userId == null) {
            response.sendRedirect(request.getContextPath() + "/view/warehouse/exportMaterial.jsp?error=Unauthorized");
            return;
        }

        String proposalIdStr = request.getParameter("proposalId");
        Integer proposalId = null;
        try {
            if (proposalIdStr != null && !proposalIdStr.isEmpty()) {
                proposalId = Integer.parseInt(proposalIdStr);
            } else {
                request.setAttribute("error", "Proposal ID is required.");
                request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid proposal ID: " + proposalIdStr);
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
            return;
        }

        String note = request.getParameter("note");
        if (note == null || note.trim().isEmpty()) {
            request.setAttribute("error", "Note is required.");
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
            return;
        }
        if (note.length() > NOTE_MAX_LENGTH) {
            request.setAttribute("error", "Note must not exceed " + NOTE_MAX_LENGTH + " characters.");
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
            return;
        }
        if (!note.matches(NOTE_REGEX)) {
            request.setAttribute("error", "Invalid note format.");
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
            return;
        }

        String receiverId = request.getParameter("receiverId");
        if (receiverId == null || receiverId.trim().isEmpty()) {
            request.setAttribute("error", "Receiver is required.");
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            ExportDAO exportDAO = new ExportDAO(conn);
            Proposal proposal = proposalDAO.getProposalWithDetailsById(proposalId);

            if (proposal == null || !proposal.getFinalStatus().equals("approved_but_not_executed")) {
                request.setAttribute("error", "Proposal not found or not approved for execution.");
                request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
                return;
            }
            if (proposal.getProposalDetails() == null || proposal.getProposalDetails().isEmpty()) {
                request.setAttribute("error", "No proposal details found.");
                request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
                return;
            }
            if (exportDAO.checkProposalIdExists(proposalId)) {
                request.setAttribute("error", "Proposal ID has already been used for export.");
                request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
                return;
            }

            // Validate inventory for each detail
            for (var detail : proposal.getProposalDetails()) {
                String selectSql = "SELECT quantity_in_stock FROM Inventory WHERE material_id = ? AND material_condition = ?";
                try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
                    selectStmt.setInt(1, detail.getMaterialId());
                    selectStmt.setString(2, detail.getMaterialCondition());
                    ResultSet rs = selectStmt.executeQuery();
                    if (!rs.next()) {
                        request.setAttribute("error", "Material ID " + detail.getMaterialId() + " with condition " + detail.getMaterialCondition() + " not found in inventory.");
                        request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
                        return;
                    }
                    double quantityInStock = rs.getDouble("quantity_in_stock");
                    if (quantityInStock < detail.getQuantity()) {
                        request.setAttribute("error", "Insufficient inventory for material ID " + detail.getMaterialId() + " with condition " + detail.getMaterialCondition());
                        request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
                        return;
                    }
                }
            }

            // Create Export object
            Export export = new Export();
            export.setProposalId(proposalId);
            export.setExporterId(userId);
            export.setReceiverId(Integer.parseInt(receiverId));
            export.setSiteId(proposal.getSiteId());
            export.setExportDate(new Timestamp(System.currentTimeMillis()));
            export.setNote(note);

            // Map ProposalDetails to ExportDetails
            List<ExportDetail> exportDetails = new ArrayList<>();
            for (var detail : proposal.getProposalDetails()) {
                ExportDetail exportDetail = new ExportDetail();
                exportDetail.setMaterialId(detail.getMaterialId());
                exportDetail.setQuantity(detail.getQuantity());
                exportDetail.setMaterialCondition(detail.getMaterialCondition());
                exportDetails.add(exportDetail);
            }
            export.setExportDetail(exportDetails);

            // Save export and update inventory
            int exportId = exportDAO.saveExport(export);
            if (exportId > 0) {
                exportDAO.exportMaterial(exportId, exportDetails);
                exportDAO.updateProposalStatusToExecuted(proposalId);
                response.sendRedirect(request.getContextPath() + "/view/warehouse/exportMaterial.jsp?success=Export%20successfully%20saved&exportId=" + exportId + "&proposalId=" + proposalId);
            } else {
                request.setAttribute("error", "Failed to save export.");
                request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/view/warehouse/exportMaterial.jsp").forward(request, response);
        }
    }
}
