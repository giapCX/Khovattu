package controller.proposal;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import Dal.DBContext;
import dao.InventoryDAO;
import dao.ProposalDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
import model.Proposal;
import model.ProposalDetails;

/**
 *
 * @author quanh
 */
public class AdminUpdateProposalServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AdminUpdateProposalServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminUpdateProposalServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("Entering AdminProposalDetailServlet.doGet");
        try (Connection conn = new DBContext().getConnection()) {
            // Lấy proposalId từ request
            String rawProposalId = request.getParameter("proposalId");
            System.out.println("Received proposalId: " + rawProposalId);
            if (rawProposalId == null || !rawProposalId.matches("\\d+")) {
                System.out.println("Invalid proposalId: " + rawProposalId);
                request.setAttribute("errorMessage", "ID đề xuất không hợp lệ.");
                request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);
                return;
            }

            int proposalId = Integer.parseInt(rawProposalId);
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            InventoryDAO inventoryDAO = new InventoryDAO(conn);

            // Lấy thông tin đề xuất
            Proposal proposal = proposalDAO.getProposalById(proposalId);
            if (proposal == null) {
                System.out.println("Proposal not found for ID: " + proposalId);
                request.setAttribute("errorMessage", "Không tìm thấy đề xuất với ID: " + proposalId);
                request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);
                return;
            }
            System.out.println("Proposal ID: " + proposalId + ", Type: " + proposal.getProposalType());

            // Cập nhật chi tiết đề xuất cho export
            if ("export".equalsIgnoreCase(proposal.getProposalType())) {
                List<ProposalDetails> details = proposalDAO.getProposalDetailsByProposalId(proposalId);
                System.out.println("Number of details: " + details.size());
                for (ProposalDetails detail : details) {
                    int materialId = detail.getMaterialId();
                    double requestedQuantity = detail.getQuantity();
                    String materialCondition = detail.getMaterialCondition();
                    double pendingExportQty = inventoryDAO.getReservedQuantityExcludingProposal(materialId, proposalId);
                    double currentStock = inventoryDAO.getCurrentStock(materialId, materialCondition);
                    double available = currentStock - pendingExportQty;

                    detail.setPendingExportQuantity(pendingExportQty);
                    detail.setCurrentStock(currentStock);
                    detail.setStockStatus(available >= requestedQuantity ? "enough" : "not enough");

                    
                }
                proposal.setProposalDetails(details);
            } else {
                System.out.println("Proposal is not of type 'export', skipping details processing");
            }

            // Gửi proposal tới JSP
            request.setAttribute("proposal", proposal);
            System.out.println("Forwarding to proposalDetail.jsp with proposal: " + proposal.getProposalId());
            request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("SQLException: " + e.getMessage());
            request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Exception: " + e.getMessage());
            request.setAttribute("errorMessage", "Lỗi không xác định: " + e.getMessage());
            request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try (Connection conn = new DBContext().getConnection()) {
            // 1. Lấy và kiểm tra dữ liệu đầu vào
            String rawProposalId = request.getParameter("proposalId");
            String rawAdminApproverId = request.getParameter("adminApproverId");
            String adminStatus = request.getParameter("adminStatus");
            String adminReason = Optional.ofNullable(request.getParameter("adminReason")).orElse("");
            String adminNote = Optional.ofNullable(request.getParameter("adminNote")).orElse("");

            // Kiểm tra định dạng đầu vào
            if (!rawProposalId.matches("\\d+") || !rawAdminApproverId.matches("\\d+")) {
                request.getSession().setAttribute("errorMessage", "Định dạng ID đề xuất hoặc người phê duyệt không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/AdminApproveServlet?proposalId=" + rawProposalId);
                return;
            }

            int proposalId = Integer.parseInt(rawProposalId);
            int adminApproverId = Integer.parseInt(rawAdminApproverId);

            // Kiểm tra trạng thái phê duyệt
            if (adminStatus == null || !adminStatus.matches("approved|rejected")) {
                request.getSession().setAttribute("errorMessage", "Trạng thái phê duyệt không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/AdminApproveServlet?proposalId=" + proposalId);
                return;
            }

            // 2. Chuẩn bị DAO
            ProposalDAO proposalDAO = new ProposalDAO(conn);
            InventoryDAO inventoryDAO = new InventoryDAO(conn);
            String proposalType = proposalDAO.getProposalType(proposalId);

            // 3. Lấy và cập nhật chi tiết đề xuất
            List<ProposalDetails> proposalDetailsList = proposalDAO.getProposalDetailsByProposalId(proposalId);
            boolean allEnough = true;
            StringBuilder insufficientMsg = new StringBuilder("Không đủ tồn kho cho: ");

            if ("export".equalsIgnoreCase(proposalType)) {
                for (ProposalDetails detail : proposalDetailsList) {
                    int materialId = detail.getMaterialId();
                    double requestedQuantity = detail.getQuantity();
                    String materialCondition = detail.getMaterialCondition(); // Lấy material_condition
                    double pendingExportQty = inventoryDAO.getReservedQuantityExcludingProposal(materialId, proposalId);
                    double currentStock = inventoryDAO.getCurrentStock(materialId, materialCondition); // Hoặc sử dụng getCurrentStock(materialId, materialCondition)
                    double available = currentStock - pendingExportQty;

                    // Thiết lập giá trị
                    detail.setPendingExportQuantity(pendingExportQty);
                    detail.setCurrentStock(currentStock);
                    detail.setStockStatus(available >= requestedQuantity ? "enough" : "not enough");

                    
                    if ("approved".equals(adminStatus) && available < requestedQuantity) {
                        allEnough = false;
                        insufficientMsg.append(detail.getMaterialName())
                                .append(" (available: ").append(available)
                                .append(", request: ").append(requestedQuantity).append("), ");
                    }
                }
            }

            // 4. Nếu không đủ kho khi phê duyệt
            if ("export".equalsIgnoreCase(proposalType) && "approved".equals(adminStatus) && !allEnough) {
                Proposal proposal = proposalDAO.getProposalById(proposalId);
                proposal.setProposalDetails(proposalDetailsList);
                request.setAttribute("proposal", proposal);
                request.setAttribute("errorMessage", insufficientMsg.substring(0, insufficientMsg.length() - 2));
                request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);
                return;
            }

            // 5. Cập nhật đề xuất nếu đủ kho hoặc là import/rejected
            proposalDAO.adminUpdateProposal(proposalId, adminStatus, adminReason, adminNote, adminApproverId);
            request.getSession().setAttribute("successMessage", "Đề xuất đã được cập nhật thành công.");
            response.sendRedirect(request.getContextPath() + "/AdminApproveServlet?proposalId=" + proposalId);

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Định dạng đầu vào không hợp lệ: " + e.getMessage());
            request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi không xác định: " + e.getMessage());
            request.getRequestDispatcher("/view/admin/proposalDetail.jsp").forward(request, response);
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
