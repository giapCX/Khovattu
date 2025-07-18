package dao;

import Dal.DBContext;
import model.Proposal;
import model.ProposalDetails;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.ProposalApprovals;

public class ProposalDAO {

    private Connection conn;

    public ProposalDAO(Connection conn) {
        this.conn = conn;
    }

    public boolean addProposal(Proposal proposal) throws SQLException {
        String insertProposalSQL = "INSERT INTO EmployeeProposals (proposal_type, proposer_id, note, proposal_sent_date, final_status,supplier_id, site_id) VALUES (?, ?, ?, ?, ?,?,?)";
        conn.setAutoCommit(false);
        try (PreparedStatement ps = conn.prepareStatement(insertProposalSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, proposal.getProposalType());
            ps.setInt(2, proposal.getProposerId());
            ps.setString(3, proposal.getNote());
            ps.setTimestamp(4, proposal.getProposalSentDate() != null ? proposal.getProposalSentDate() : new Timestamp(System.currentTimeMillis()));
            ps.setString(5, proposal.getFinalStatus() != null ? proposal.getFinalStatus() : "pending");
            ps.setObject(6, proposal.getSupplierId(), java.sql.Types.INTEGER);
            ps.setObject(7, proposal.getSiteId(), java.sql.Types.INTEGER);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int proposalId = rs.getInt(1);
                        String insertApprovalSQL = "INSERT INTO ProposalApprovals (proposal_id, admin_status, director_status) VALUES (?, 'pending', 'pending')";
                        try (PreparedStatement approvalStmt = conn.prepareStatement(insertApprovalSQL)) {
                            approvalStmt.setInt(1, proposalId);
                            approvalStmt.executeUpdate();
                        }
                        if (proposal.getProposalDetails() != null && !proposal.getProposalDetails().isEmpty()) {
                            if (addProposalDetails(proposalId, proposal.getProposalDetails())) {
                                conn.commit();
                                return true;
                            }
                        } else {
                            conn.commit();
                            return true;
                        }
                    }
                }
            }
            conn.rollback();
            return false;
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    private boolean addProposalDetails(int proposalId, List<ProposalDetails> proposalDetailsList) throws SQLException {
        String insertProposalDetailSQL = "INSERT INTO ProposalDetails (proposal_id, material_id, quantity, material_condition, price_per_unit) VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(insertProposalDetailSQL)) {
            for (ProposalDetails detail : proposalDetailsList) {
                ps.setInt(1, proposalId);
                ps.setInt(2, detail.getMaterialId());
                ps.setDouble(3, detail.getQuantity());
                ps.setString(4, detail.getMaterialCondition());

                if (detail.getPrice() != null) {
                    ps.setDouble(5, detail.getPrice());
                } else {
                    ps.setNull(5, java.sql.Types.DOUBLE);
                }
                ps.addBatch();
            }

            int[] result = ps.executeBatch();
            for (int i : result) {
                if (i == PreparedStatement.EXECUTE_FAILED) {
                    return false;
                }
            }
            return true;
        }
    }

    public List<Proposal> getPendingProposals(String search, String dateFrom, String dateTo, String status, int limit, int offset) throws SQLException {
        List<Proposal> proposals = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT ep.proposal_id, ep.proposal_type, ep.proposer_id, u.full_name AS sender_name, ep.note, ep.proposal_sent_date, "
                + "COALESCE(ep.final_status, 'pending') AS final_status, pa.admin_approval_date, pa.director_approval_date, "
                + "pa.approval_id, pa.admin_status, pa.director_status, pa.admin_reason, pa.admin_note, pa.director_reason, pa.director_note "
                + "FROM EmployeeProposals ep "
                + "LEFT JOIN Users u ON ep.proposer_id = u.user_id "
                + "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id "
                + "WHERE 1=1"
        );

        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            sql.append(" AND COALESCE(ep.final_status, 'pending') = ?");
            params.add(status);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND u.full_name LIKE ?");
            params.add("%" + search + "%");
        }
        if (dateFrom != null && !dateFrom.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date >= ?");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date <= ?");
            params.add(dateTo);
        }

        sql.append(" ORDER BY ep.proposal_sent_date DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        System.out.println("Executing SQL: " + sql.toString() + " with params: " + params);
        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Proposal proposal = new Proposal();
                    proposal.setProposalId(rs.getInt("proposal_id"));
                    proposal.setProposalType(rs.getString("proposal_type"));
                    proposal.setProposerId(rs.getInt("proposer_id"));
                    proposal.setSenderName(rs.getString("sender_name"));
                    proposal.setNote(rs.getString("note"));
                    proposal.setProposalSentDate(rs.getTimestamp("proposal_sent_date"));
                    proposal.setFinalStatus(rs.getString("final_status"));
                    proposal.setApprovalDate(rs.getTimestamp("admin_approval_date") != null ? rs.getTimestamp("admin_approval_date") : rs.getTimestamp("director_approval_date"));

                    // Gán đối tượng ProposalApprovals
                    ProposalApprovals approval = new ProposalApprovals();
                    approval.setApprovalId(rs.getInt("approval_id"));
                    approval.setAdminStatus(rs.getString("admin_status"));
                    approval.setDirectorStatus(rs.getString("director_status"));
                    approval.setAdminApprovalDate(rs.getTimestamp("admin_approval_date"));
                    approval.setDirectorApprovalDate(rs.getTimestamp("director_approval_date"));
                    approval.setAdminReason(rs.getString("admin_reason"));
                    approval.setAdminNote(rs.getString("admin_note"));
                    approval.setDirectorReason(rs.getString("director_reason"));
                    approval.setDirectorNote(rs.getString("director_note"));
                    proposal.setApproval(approval);

                    // Gán directorStatus để tương thích với mã cũ (tùy chọn)
                    proposal.setDirectorStatus(rs.getString("director_status"));

                    proposals.add(proposal);
                }
            }
        }
        return proposals;
    }

    public int getPendingProposalsCount(String search, String dateFrom, String dateTo, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) "
                + "FROM EmployeeProposals ep "
                + "LEFT JOIN Users u ON ep.proposer_id = u.user_id "
                + "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id "
                + "WHERE 1=1"
        );

        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            sql.append(" AND COALESCE(ep.final_status, 'pending') = ?");
            params.add(status);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND u.full_name LIKE ?");
            params.add("%" + search + "%");
        }
        if (dateFrom != null && !dateFrom.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date >= ?");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date <= ?");
            params.add(dateTo);
        }

        System.out.println("Executing Count SQL: " + sql.toString() + " with params: " + params);
        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<Proposal> directorGetPendingProposals(String search, String startDate, String endDate, String status, int limit, int offset) throws SQLException {
        List<Proposal> proposals = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT ep.proposal_id, ep.proposal_type, ep.proposer_id, u.full_name AS sender_name, ep.note, ep.proposal_sent_date, "
                + "COALESCE(ep.final_status, 'pending') AS final_status, pa.admin_approval_date, pa.director_approval_date, "
                + "ua.full_name AS admin_approver_name, pa.approval_id, pa.admin_approver_id, pa.director_approver_id, "
                + "pa.admin_status, pa.director_status, pa.admin_reason, pa.admin_note, pa.director_reason, pa.director_note "
                + "FROM EmployeeProposals ep "
                + "LEFT JOIN Users u ON ep.proposer_id = u.user_id "
                + "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id "
                + "LEFT JOIN Users ua ON pa.admin_approver_id = ua.user_id "
                + "WHERE pa.admin_status = 'approved'"
        );

        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            sql.append(" AND pa.director_status = ?");
            params.add(status);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR ep.proposal_id LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date <= ?");
            params.add(endDate);
        }

        sql.append(" ORDER BY ep.proposal_sent_date DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        System.out.println("Executing SQL: " + sql.toString() + " with params: " + params);
        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Proposal proposal = new Proposal();
                    proposal.setProposalId(rs.getInt("proposal_id"));
                    proposal.setProposalType(rs.getString("proposal_type"));
                    proposal.setProposerId(rs.getInt("proposer_id"));
                    proposal.setSenderName(rs.getString("sender_name"));
                    proposal.setNote(rs.getString("note"));
                    proposal.setProposalSentDate(rs.getTimestamp("proposal_sent_date"));
                    proposal.setFinalStatus(rs.getString("final_status"));
                    proposal.setApprovalDate(rs.getTimestamp("admin_approval_date"));

                    ProposalApprovals approval = new ProposalApprovals();
                    approval.setApprovalId(rs.getInt("approval_id"));
                    approval.setAdminApproverId(rs.getInt("admin_approver_id"));
                    approval.setDirectorApproverId(rs.getInt("director_approver_id"));
                    approval.setAdminStatus(rs.getString("admin_status"));
                    approval.setDirectorStatus(rs.getString("director_status"));
                    approval.setAdminApprovalDate(rs.getTimestamp("admin_approval_date"));
                    approval.setDirectorApprovalDate(rs.getTimestamp("director_approval_date"));
                    approval.setAdminReason(rs.getString("admin_reason"));
                    approval.setAdminNote(rs.getString("admin_note"));
                    approval.setDirectorReason(rs.getString("director_reason"));
                    approval.setDirectorNote(rs.getString("director_note"));
                    proposal.setApproval(approval);

                    proposal.setDirectorStatus(rs.getString("director_status"));
                    proposal.setFinalApprover(rs.getString("admin_approver_name"));
                    proposals.add(proposal);
                }
            }
        }
        return proposals;
    }

    public int directorGetPendingProposalsCount(String search, String startDate, String endDate, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) "
                + "FROM EmployeeProposals ep "
                + "LEFT JOIN Users u ON ep.proposer_id = u.user_id "
                + "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id "
                + "WHERE pa.admin_status = 'approved'"
        );

        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            sql.append(" AND pa.director_status = ?");
            params.add(status);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR ep.proposal_id LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date <= ?");
            params.add(endDate);
        }

        System.out.println("Executing Count SQL: " + sql.toString() + " with params: " + params);
        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public void directorUpdateProposal(int proposalId, String directorStatus, String directorReason, String directorNote, int directorApproverId) throws SQLException {
        String checkSql = "SELECT director_status FROM ProposalApprovals WHERE proposal_id = ?";
        String updateSql = "UPDATE ProposalApprovals SET director_status = ?, director_approver_id = ?, director_reason = ?, director_note = ?, director_approval_date = CURRENT_TIMESTAMP WHERE proposal_id = ?";
        String updateFinalStatusSql = "UPDATE EmployeeProposals ep SET final_status = "
                + "CASE "
                + "    WHEN (SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'approved' "
                + "     AND (SELECT director_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'approved' THEN 'approved_but_not_executed' "
                + "    WHEN (SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'rejected' "
                + "     OR (SELECT director_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'rejected' THEN 'rejected' "
                + "    WHEN (SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'approved' "
                + "     AND (SELECT director_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'pending' THEN 'approved_by_admin' "
                + "    ELSE 'pending' "
                + "END "
                + "WHERE proposal_id = ?";

        conn.setAutoCommit(false);
        try (
                PreparedStatement checkStmt = conn.prepareStatement(checkSql); PreparedStatement updateStmt = conn.prepareStatement(updateSql); PreparedStatement updateFinalStmt = conn.prepareStatement(updateFinalStatusSql)) {
            // Kiểm tra trạng thái hiện tại
            checkStmt.setInt(1, proposalId);
            ResultSet rs = checkStmt.executeQuery();
            String currentDirectorStatus = "pending";
            if (rs.next()) {
                currentDirectorStatus = rs.getString("director_status");
                if (currentDirectorStatus != null && !"pending".equals(currentDirectorStatus)) {
                    throw new SQLException("Director can only update when director_status is 'pending'. Current status: " + currentDirectorStatus);
                }
            } else {
                throw new SQLException("No approval record found for proposal ID: " + proposalId);
            }

            // Cập nhật ProposalApprovals
            updateStmt.setString(1, directorStatus);
            updateStmt.setInt(2, directorApproverId);
            updateStmt.setString(3, directorReason);
            updateStmt.setString(4, directorNote);
            updateStmt.setInt(5, proposalId);
            updateStmt.executeUpdate();

            // Cập nhật final_status trong EmployeeProposals
            updateFinalStmt.setInt(1, proposalId);
            updateFinalStmt.executeUpdate();

            conn.commit();
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    public Proposal getProposalById(int proposalId) {
        Proposal proposal = null;
        String sql = "SELECT ep.*, u.full_name, "
                + "pd.proposal_detail_id, pd.material_id, pd.quantity, pd.material_condition, m.name AS material_name, m.unit AS material_unit, "
                + "pa.approval_id, pa.admin_approver_id, pa.director_approver_id, "
                + "pa.admin_status, pa.director_status, "
                + "pa.admin_approval_date, pa.admin_reason, pa.admin_note, "
                + "pa.director_approval_date, pa.director_reason, pa.director_note "
                + "FROM EmployeeProposals ep "
                + "JOIN Users u ON ep.proposer_id = u.user_id "
                + "LEFT JOIN ProposalDetails pd ON ep.proposal_id = pd.proposal_id "
                + "LEFT JOIN Materials m ON pd.material_id = m.material_id "
                + "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id "
                + "WHERE ep.proposal_id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, proposalId);
            ResultSet rs = ps.executeQuery();

            Map<Integer, ProposalDetails> detailsMap = new LinkedHashMap<>();
            ProposalApprovals approval = null;

            while (rs.next()) {
                if (proposal == null) {
                    proposal = new Proposal();
                    proposal.setProposalId(rs.getInt("proposal_id"));
                    proposal.setProposalType(rs.getString("proposal_type"));
                    proposal.setProposerId(rs.getInt("proposer_id"));
                    proposal.setSenderName(rs.getString("full_name"));
                    proposal.setNote(rs.getString("note"));
                    proposal.setProposalSentDate(rs.getTimestamp("proposal_sent_date"));
                    proposal.setFinalStatus(rs.getString("final_status"));
                }

                // Detail
                int detailId = rs.getInt("proposal_detail_id");
                if (detailId > 0 && !detailsMap.containsKey(detailId)) {
                    ProposalDetails detail = new ProposalDetails();
                    detail.setProposalDetailId(detailId);
                    detail.setProposal(proposal);
                    detail.setMaterialId(rs.getInt("material_id"));
                    detail.setMaterialName(rs.getString("material_name"));
                    detail.setQuantity(rs.getDouble("quantity"));
                    detail.setMaterialCondition(rs.getString("material_condition"));
                    detail.setUnit(rs.getString("material_unit"));
                    detailsMap.put(detailId, detail);
                }

                // Approval (nếu có)
                if (approval == null && rs.getObject("approval_id") != null) {
                    approval = new ProposalApprovals();
                    approval.setApprovalId(rs.getInt("approval_id"));
                    approval.setProposal(proposal);
                    approval.setAdminApproverId(rs.getInt("admin_approver_id"));
                    approval.setDirectorApproverId(rs.getInt("director_approver_id"));
                    approval.setAdminStatus(rs.getString("admin_status"));
                    approval.setDirectorStatus(rs.getString("director_status"));
                    approval.setAdminApprovalDate(rs.getTimestamp("admin_approval_date"));
                    approval.setAdminReason(rs.getString("admin_reason"));
                    approval.setAdminNote(rs.getString("admin_note"));
                    approval.setDirectorApprovalDate(rs.getTimestamp("director_approval_date"));
                    approval.setDirectorReason(rs.getString("director_reason"));
                    approval.setDirectorNote(rs.getString("director_note"));
                }
            }

            if (proposal != null) {
                proposal.setProposalDetails(new ArrayList<>(detailsMap.values()));

                // nếu không có dòng nào trong bảng ProposalApprovals, gán approval dummy
                if (approval == null) {
                    approval = new ProposalApprovals();
                    approval.setAdminStatus("pending");
                    approval.setDirectorStatus("pending");
                    approval.setProposal(proposal);
                }

                proposal.setApproval(approval);

                // Thiết lập approvalDate nếu có
                if (approval.getDirectorApprovalDate() != null) {
                    proposal.setApprovalDate(approval.getDirectorApprovalDate());
                } else if (approval.getAdminApprovalDate() != null) {
                    proposal.setApprovalDate(approval.getAdminApprovalDate());
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return proposal;
    }

    public List<ProposalDetails> getProposalDetailsByProposalId(int proposalId) {
        List<ProposalDetails> list = new ArrayList<>();
        String sql = "SELECT pd.*, m.name AS material_name, m.unit AS material_unit "
                + "FROM ProposalDetails pd "
                + "LEFT JOIN Materials m ON pd.material_id = m.material_id "
                + "WHERE pd.proposal_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, proposalId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ProposalDetails detail = new ProposalDetails();
                detail.setProposalDetailId(rs.getInt("proposal_detail_id"));
                detail.setMaterialId(rs.getInt("material_id"));
                detail.setMaterialName(rs.getString("material_name"));
                detail.setQuantity(rs.getDouble("quantity"));
                detail.setMaterialCondition(rs.getString("material_condition"));
                Proposal p = new Proposal();
                p.setProposalId(proposalId);
                detail.setProposal(p);

                list.add(detail);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public ProposalApprovals getApprovalByProposalId(int proposalId) {
        ProposalApprovals approval = null;
        String sql = "SELECT approval_id, proposal_id, admin_approver_id, director_approver_id, "
                + "admin_status, director_status, admin_approval_date, admin_reason, admin_note, "
                + "director_approval_date, director_reason, director_note "
                + "FROM ProposalApprovals WHERE proposal_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, proposalId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                approval = new ProposalApprovals();
                approval.setApprovalId(rs.getInt("approval_id"));
                approval.setAdminApproverId(rs.getInt("admin_approver_id"));
                approval.setDirectorApproverId(rs.getInt("director_approver_id"));
                approval.setAdminStatus(rs.getString("admin_status"));
                approval.setDirectorStatus(rs.getString("director_status"));
                approval.setAdminApprovalDate(rs.getTimestamp("admin_approval_date"));
                approval.setAdminReason(rs.getString("admin_reason"));
                approval.setAdminNote(rs.getString("admin_note"));
                approval.setDirectorApprovalDate(rs.getTimestamp("director_approval_date"));
                approval.setDirectorReason(rs.getString("director_reason"));
                approval.setDirectorNote(rs.getString("director_note"));

                Proposal p = new Proposal();
                p.setProposalId(proposalId);
                approval.setProposal(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error retrieving approval for proposal ID: " + proposalId, e);
        }
        return approval;
    }

    public void adminUpdateProposal(int proposalId, String adminStatus, String adminReason, String adminNote, int adminApproverId) throws SQLException {
        String checkSql = "SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ?";
        String insertSql = "INSERT INTO ProposalApprovals (proposal_id, admin_approver_id, admin_status, admin_reason, admin_note, admin_approval_date) "
                + "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        String updateSql = "UPDATE ProposalApprovals SET admin_status = ?, admin_reason = ?, admin_note = ?, admin_approver_id = ?, admin_approval_date = CURRENT_TIMESTAMP "
                + "WHERE proposal_id = ?";
        String updateFinalStatusSql
                = "UPDATE EmployeeProposals ep SET final_status = "
                + "  CASE "
                + "    WHEN (SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'approved' "
                + "     AND (SELECT director_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'approved' THEN 'approved_but_not_executed' "
                + "    WHEN (SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'rejected' "
                + "     OR (SELECT director_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'rejected' THEN 'rejected' "
                + "    WHEN (SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'approved' "
                + "     AND (SELECT director_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'pending' THEN 'approved_by_admin' "
                + "    ELSE 'pending' "
                + "  END "
                + "WHERE proposal_id = ?";

        try (
                PreparedStatement checkStmt = conn.prepareStatement(checkSql); PreparedStatement insertStmt = conn.prepareStatement(insertSql); PreparedStatement updateStmt = conn.prepareStatement(updateSql); PreparedStatement updateFinalStmt = conn.prepareStatement(updateFinalStatusSql)) {
            // Kiểm tra trạng thái hiện tại
            checkStmt.setInt(1, proposalId);
            ResultSet rs = checkStmt.executeQuery();

            boolean isUpdate = false;
            String currentAdminStatus = "pending";
            if (rs.next()) {
                currentAdminStatus = rs.getString("admin_status");
                if (currentAdminStatus != null && !"pending".equals(currentAdminStatus)) {
                    throw new SQLException("Admin can only update when admin_status is 'pending'. Current status: " + currentAdminStatus);
                }
                isUpdate = true;
            }

            // Thực hiện insert hoặc update tùy vào trạng thái
            if (isUpdate) {
                updateStmt.setString(1, adminStatus);
                updateStmt.setString(2, adminReason);
                updateStmt.setString(3, adminNote);
                updateStmt.setInt(4, adminApproverId);
                updateStmt.setInt(5, proposalId);
                updateStmt.executeUpdate();
            } else {
                insertStmt.setInt(1, proposalId);
                insertStmt.setInt(2, adminApproverId);
                insertStmt.setString(3, adminStatus);
                insertStmt.setString(4, adminReason);
                insertStmt.setString(5, adminNote);
                insertStmt.executeUpdate();
            }

            // Cập nhật trạng thái cuối cùng của proposal
            updateFinalStmt.setInt(1, proposalId);
            updateFinalStmt.executeUpdate();
        }
    }

    public int countProposalsByProposerTypeStatusFromStartDateToEndDate(int proposerId, String type, String status, Timestamp startDate, Timestamp endDate) {
        int total = 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM EmployeeProposals WHERE proposer_id = ?");

        List<Object> parameters = new ArrayList<>();
        parameters.add(proposerId);

        if (type != null && !type.isEmpty()) {
            sql.append(" AND proposal_type = ?");
            parameters.add(type);
        }

        if (status != null && !status.isEmpty()) {
            sql.append(" AND final_status = ?");
            parameters.add(status);
        }

        if (startDate != null) {
            sql.append(" AND proposal_sent_date >= ?");
            parameters.add(startDate);
        }

        if (endDate != null) {
            sql.append(" AND proposal_sent_date <= ?");
            parameters.add(endDate);
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return total;
    }

    public List<Proposal> searchProposalsByProposerTypeStatusFromStartDateToEndDateWithPaging(
            int proposerId, String type, String status, Timestamp startDate, Timestamp endDate, int offset, int limit) {

        List<Proposal> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM EmployeeProposals WHERE proposer_id = ?");

        List<Object> params = new ArrayList<>();
        params.add(proposerId);

        if (type != null && !type.isEmpty()) {
            sql.append(" AND proposal_type = ?");
            params.add(type);
        }

        if (status != null && !status.isEmpty()) {
            sql.append(" AND final_status = ?");
            params.add(status);
        }

        if (startDate != null) {
            sql.append(" AND proposal_sent_date >= ?");
            params.add(startDate);
        }

        if (endDate != null) {
            sql.append(" AND proposal_sent_date <= ?");
            params.add(endDate);
        }

        sql.append(" ORDER BY proposal_sent_date DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Proposal p = new Proposal();
                p.setProposalId(rs.getInt("proposal_id"));
                p.setProposalType(rs.getString("proposal_type"));
                p.setProposerId(rs.getInt("proposer_id"));
                p.setNote(rs.getString("note"));
                p.setProposalSentDate(rs.getTimestamp("proposal_sent_date"));
                p.setFinalStatus(rs.getString("final_status"));

                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Proposal getProposalWithDetailsById(int proposalId) throws SQLException {
        Proposal proposal = null;

        String sql = "SELECT ep.proposal_id, ep.proposal_type, ep.proposer_id, u.full_name AS sender_name, "
                + "ep.executor_id, executor.full_name AS executor_name, ep.note, "
                + "ep.proposal_sent_date, ep.final_status, ep.executed_date, "
                + "pd.proposal_detail_id, pd.material_id, pd.quantity, pd.material_condition, "
                + "ep.site_id, ep.supplier_id, pd.price_per_unit, "
                + "m.name AS material_name, m.unit AS material_unit, "
                + "cs.site_name, s.name AS supplier_name "
                + "FROM EmployeeProposals ep "
                + "JOIN Users u ON ep.proposer_id = u.user_id "
                + "LEFT JOIN Users executor ON ep.executor_id = executor.user_id "
                + "LEFT JOIN ProposalDetails pd ON ep.proposal_id = pd.proposal_id "
                + "LEFT JOIN Materials m ON pd.material_id = m.material_id "
                + "LEFT JOIN ConstructionSites cs ON ep.site_id = cs.site_id "
                + "LEFT JOIN Suppliers s ON ep.supplier_id = s.supplier_id "
                + "WHERE ep.proposal_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, proposalId);
            try (ResultSet rs = ps.executeQuery()) {
                List<ProposalDetails> detailsList = new ArrayList<>();
                while (rs.next()) {
                    if (proposal == null) {
                        proposal = new Proposal();
                        proposal.setProposalId(rs.getInt("proposal_id"));
                        proposal.setProposalType(rs.getString("proposal_type"));
                        proposal.setProposerId(rs.getInt("proposer_id"));
                        proposal.setSenderName(rs.getString("sender_name"));
                        proposal.setExecutorId(rs.getInt("executor_id"));
                        proposal.setExecutorName(rs.getString("executor_name"));
                        proposal.setNote(rs.getString("note"));
                        proposal.setProposalSentDate(rs.getTimestamp("proposal_sent_date"));
                        proposal.setFinalStatus(rs.getString("final_status"));
                        proposal.setExecuteDate(rs.getTimestamp("executed_date"));
                        proposal.setSiteId((Integer) rs.getObject("site_id"));
                        proposal.setSiteName(rs.getString("site_name"));
                        proposal.setSupplierId((Integer) rs.getObject("supplier_id"));
                        proposal.setSupplierName(rs.getString("supplier_name"));
                    }

                    int detailId = rs.getInt("proposal_detail_id");
                    if (detailId > 0) {
                        ProposalDetails detail = new ProposalDetails();
                        detail.setProposalDetailId(detailId);
                        detail.setProposal(proposal);
                        detail.setMaterialId(rs.getInt("material_id"));
                        detail.setMaterialName(rs.getString("material_name"));
                        detail.setQuantity(rs.getDouble("quantity"));
                        detail.setMaterialCondition(rs.getString("material_condition"));
                        detail.setUnit(rs.getString("material_unit"));
                        detail.setPrice(rs.getDouble("price_per_unit"));
                        detailsList.add(detail);
                    }
                }

                if (proposal != null) {
                    proposal.setProposalDetails(detailsList);
                }
            }
        }

        return proposal;
    }

    public boolean updateProposalById(Integer proposalId, Proposal proposal) throws SQLException {
        String updateProposalSQL = "UPDATE EmployeeProposals SET proposal_type = ?, proposer_id = ?, note = ?, proposal_sent_date = ?, final_status = ?, supplier_id = ?, site_id = ? WHERE proposal_id = ?";
        String deleteProposalDetailsSQL = "DELETE FROM ProposalDetails WHERE proposal_id = ?";
        String insertProposalDetailSQL = "INSERT INTO ProposalDetails (proposal_id, material_id, quantity, material_condition, price_per_unit) VALUES (?, ?, ?, ?, ?)";

        conn.setAutoCommit(false);
        try (
                PreparedStatement updateStmt = conn.prepareStatement(updateProposalSQL); PreparedStatement deleteStmt = conn.prepareStatement(deleteProposalDetailsSQL); PreparedStatement insertStmt = conn.prepareStatement(insertProposalDetailSQL)) {
            // Cập nhật thông tin Proposal chính
            updateStmt.setString(1, proposal.getProposalType());
            updateStmt.setInt(2, proposal.getProposerId());
            updateStmt.setString(3, proposal.getNote());
            updateStmt.setTimestamp(4, proposal.getProposalSentDate() != null ? proposal.getProposalSentDate() : new Timestamp(System.currentTimeMillis()));
            updateStmt.setString(5, proposal.getFinalStatus() != null ? proposal.getFinalStatus() : "pending");
            updateStmt.setObject(6, proposal.getSupplierId(), java.sql.Types.INTEGER);
            updateStmt.setObject(7, proposal.getSiteId(), java.sql.Types.INTEGER);
            updateStmt.setInt(8, proposalId);

            int rowsAffected = updateStmt.executeUpdate();
            if (rowsAffected == 0) {
                conn.rollback();
                throw new SQLException("Proposal ID không tồn tại: " + proposalId);
            }

            // Xóa hết chi tiết cũ
            deleteStmt.setInt(1, proposalId);
            deleteStmt.executeUpdate();

            // Thêm chi tiết mới (nếu có)
            if (proposal.getProposalDetails() != null && !proposal.getProposalDetails().isEmpty()) {
                for (ProposalDetails detail : proposal.getProposalDetails()) {
                    insertStmt.setInt(1, proposalId);
                    insertStmt.setInt(2, detail.getMaterialId());
                    insertStmt.setDouble(3, detail.getQuantity());
                    insertStmt.setString(4, detail.getMaterialCondition());
                    // Giá - nếu null thì setNull
                    if (detail.getPrice() != null) {
                        insertStmt.setDouble(5, detail.getPrice());
                    } else {
                        insertStmt.setNull(5, java.sql.Types.DOUBLE);
                    }

                    insertStmt.addBatch();
                }
                int[] result = insertStmt.executeBatch();
                for (int res : result) {
                    if (res == PreparedStatement.EXECUTE_FAILED) {
                        conn.rollback();
                        return false;
                    }
                }
            }
            conn.commit();
            return true;

        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    public void updateApprovedByProposalId(int proposalId) throws SQLException {
        String updateApprovalStatusSql = "UPDATE ProposalApprovals "
                + "SET admin_status = 'pending', director_status = 'pending' "
                + "WHERE proposal_id = ?";

        conn.setAutoCommit(false);
        try (PreparedStatement updateStmt = conn.prepareStatement(updateApprovalStatusSql)) {
            updateStmt.setInt(1, proposalId);

            int rowsAffected = updateStmt.executeUpdate();
            if (rowsAffected == 0) {
                conn.rollback();
                throw new SQLException("Không tìm thấy Proposal với proposal_id: " + proposalId);
            }
            conn.commit();
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    public int countProposalsByTypeExecuteStatusFromStartDateToEndDate(String[] proposalTypes, String searchStatus, Timestamp searchStartDate, Timestamp searchEndDate) {
        int total = 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM EmployeeProposals WHERE final_status IN ('approved_but_not_executed', 'executed')");

        List<Object> parameters = new ArrayList<>();

        // Filter by proposal types
        if (proposalTypes != null && proposalTypes.length > 0) {
            sql.append(" AND proposal_type IN (");
            for (int i = 0; i < proposalTypes.length; i++) {
                sql.append("?");
                if (i < proposalTypes.length - 1) {
                    sql.append(",");
                }
                parameters.add(proposalTypes[i]);
            }
            sql.append(")");
        }

        // Filter by status
        if (searchStatus != null && !searchStatus.isEmpty()) {
            sql.append(" AND final_status = ?");
            parameters.add(searchStatus);
        }

        // Filter by start date
        if (searchStartDate != null) {
            sql.append(" AND proposal_sent_date >= ?");
            parameters.add(searchStartDate);
        }

        // Filter by end date
        if (searchEndDate != null) {
            sql.append(" AND proposal_sent_date <= ?");
            parameters.add(searchEndDate);
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return total;
    }

    public List<Proposal> searchProposalsByTypeExecuteStatusFromStartDateToEndDateWithPaging(
            String[] proposalTypes, String searchStatus, Timestamp searchStartDate, Timestamp searchEndDate,
            int offset, int recordsPerPage) {

        List<Proposal> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT ep.*, u.full_name AS sender_name "
                + "FROM EmployeeProposals ep "
                + "LEFT JOIN Users u ON ep.proposer_id = u.user_id "
                + "WHERE ep.final_status IN ('approved_but_not_executed', 'executed') ");

        List<Object> params = new ArrayList<>();

        // Filter by proposal types
        if (proposalTypes != null && proposalTypes.length > 0) {
            sql.append(" AND ep.proposal_type IN (");
            for (int i = 0; i < proposalTypes.length; i++) {
                sql.append("?");
                if (i < proposalTypes.length - 1) {
                    sql.append(",");
                }
                params.add(proposalTypes[i]);
            }
            sql.append(")");
        }

        // Filter by status
        if (searchStatus != null && !searchStatus.isEmpty()) {
            if (searchStatus.equals("approved_but_not_executed") || searchStatus.equals("executed")) {
                sql.append(" AND ep.final_status = ?");
                params.add(searchStatus);
            } else {
                return list; // Return empty list if invalid status
            }
        }

        // Filter by start date
        if (searchStartDate != null) {
            sql.append(" AND ep.proposal_sent_date >= ?");
            params.add(searchStartDate);
        }

        // Filter by end date
        if (searchEndDate != null) {
            sql.append(" AND ep.proposal_sent_date <= ?");
            params.add(searchEndDate);
        }

        // Pagination
        sql.append(" ORDER BY ep.proposal_sent_date DESC LIMIT ? OFFSET ?");
        params.add(recordsPerPage);
        params.add(offset);

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Proposal p = new Proposal();
                p.setProposalId(rs.getInt("proposal_id"));
                p.setProposalType(rs.getString("proposal_type"));
                p.setProposerId(rs.getInt("proposer_id"));
                p.setSenderName(rs.getString("sender_name"));
                p.setNote(rs.getString("note"));
                p.setProposalSentDate(rs.getTimestamp("proposal_sent_date"));
                p.setFinalStatus(rs.getString("final_status"));
                p.setExecuteDate(rs.getTimestamp("executed_date"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    public void updateProposalStatusToExecuted(int proposalId) throws SQLException {
    String sql = "UPDATE EmployeeProposals SET final_status = 'executed' WHERE proposal_id = ?";
    try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, proposalId);
        ps.executeUpdate();
    }
}
}
