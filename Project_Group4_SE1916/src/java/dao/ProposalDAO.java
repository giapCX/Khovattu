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
        String insertProposalSQL = "INSERT INTO EmployeeProposals (proposal_type, proposer_id, note, proposal_sent_date, final_status) VALUES (?, ?, ?, ?, ?)";
        conn.setAutoCommit(false);
        try (PreparedStatement ps = conn.prepareStatement(insertProposalSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, proposal.getProposalType());
            ps.setInt(2, proposal.getProposerId());
            ps.setString(3, proposal.getNote());
            ps.setTimestamp(4, proposal.getProposalSentDate() != null ? proposal.getProposalSentDate() : new Timestamp(System.currentTimeMillis()));
            ps.setString(5, proposal.getFinalStatus() != null ? proposal.getFinalStatus() : "pending");
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int proposalId = rs.getInt(1);
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
        String insertProposalDetailSQL = "INSERT INTO ProposalDetails (proposal_id, material_id, quantity, material_condition) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertProposalDetailSQL)) {
            for (ProposalDetails detail : proposalDetailsList) {
                ps.setInt(1, proposalId);
                ps.setInt(2, detail.getMaterialId());
                ps.setDouble(3, detail.getQuantity());
                ps.setString(4, detail.getMaterialCondition());
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
                + "COALESCE(ep.final_status, 'pending') AS admin_status, pa.admin_approval_date, pa.director_approval_date "
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
                    proposal.setFinalStatus(rs.getString("admin_status"));
                    proposal.setApprovalDate(rs.getTimestamp("admin_approval_date") != null ? rs.getTimestamp("admin_approval_date") : rs.getTimestamp("director_approval_date"));
                    String directorStatus = rs.getTimestamp("director_approval_date") != null ? "approved_by_director" : "pending";
                    proposal.setDirectorStatus(directorStatus);
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
                + "COALESCE(ep.final_status, 'pending') AS admin_status, pa.admin_approval_date, pa.director_approval_date, "
                + "ua.full_name AS admin_approver_name, pa.approval_id, pa.admin_approver_id, pa.director_approver_id, "
                + "pa.admin_reason, pa.admin_note, pa.director_reason, pa.director_note "
                + "FROM EmployeeProposals ep "
                + "LEFT JOIN Users u ON ep.proposer_id = u.user_id "
                + "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id "
                + "LEFT JOIN Users ua ON pa.admin_approver_id = ua.user_id "
                + "WHERE ep.final_status = 'approved_by_admin'"
        );

        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            // Lọc dựa trên director_status (pending, approved_by_director, rejected)
            sql.append(" AND CASE WHEN pa.director_approval_date IS NOT NULL THEN 'approved_by_director' ELSE 'pending' END = ?");
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
                    proposal.setFinalStatus(rs.getString("admin_status"));
                    proposal.setApprovalDate(rs.getTimestamp("admin_approval_date"));

                    // Tạo và gán ProposalApprovals
                    ProposalApprovals approval = new ProposalApprovals();
                    approval.setApprovalId(rs.getInt("approval_id"));
                    approval.setAdminApproverId(rs.getInt("admin_approver_id"));
                    approval.setDirectorApproverId(rs.getInt("director_approver_id"));
                    approval.setAdminApprovalDate(rs.getTimestamp("admin_approval_date"));
                    approval.setDirectorApprovalDate(rs.getTimestamp("director_approval_date"));
                    approval.setAdminReason(rs.getString("admin_reason"));
                    approval.setAdminNote(rs.getString("admin_note"));
                    approval.setDirectorReason(rs.getString("director_reason"));
                    approval.setDirectorNote(rs.getString("director_note"));
                    proposal.setApproval(approval);

                    // Xác định directorStatus
                    proposal.setDirectorStatus(rs.getTimestamp("director_approval_date") != null ? "approved_by_director" : "pending");
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
                + "WHERE ep.final_status = 'approved_by_admin'"
        );

        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            // Lọc dựa trên director_status
            sql.append(" AND CASE WHEN pa.director_approval_date IS NOT NULL THEN 'approved_by_director' ELSE 'pending' END = ?");
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

    public Proposal getProposalById(int proposalId) {
        Proposal proposal = null;
        String sql = "SELECT ep.*, u.full_name, "
                + "pd.proposal_detail_id, pd.material_id, pd.quantity, pd.material_condition, m.name AS material_name, "
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
        String sql = "SELECT pd.*, m.name AS material_name, m.unit AS material_unit, m.price AS material_price "
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
        String insertOrUpdateSql = "INSERT INTO ProposalApprovals (proposal_id, admin_approver_id, admin_status, admin_reason, admin_note, admin_approval_date) "
                + "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP) "
                + "ON DUPLICATE KEY UPDATE admin_status = VALUES(admin_status), admin_reason = VALUES(admin_reason), admin_note = VALUES(admin_note), admin_approval_date = CURRENT_TIMESTAMP, admin_approver_id = VALUES(admin_approver_id)";
        String updateFinalStatusSql = "UPDATE EmployeeProposals ep "
                + "SET final_status = CASE "
                + "    WHEN (SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'approved' "
                + "         AND (SELECT director_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'approved' THEN 'approved_but_not_executed' "
                + "    WHEN (SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'rejected' "
                + "         OR (SELECT director_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'rejected' THEN 'rejected' "
                + "    WHEN (SELECT admin_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'approved' "
                + "         AND (SELECT director_status FROM ProposalApprovals WHERE proposal_id = ep.proposal_id) = 'pending' THEN 'approved_by_admin' "
                + "    ELSE 'pending' END "
                + "WHERE proposal_id = ?";

        try (
                PreparedStatement checkStmt = conn.prepareStatement(checkSql); PreparedStatement updateStmt = conn.prepareStatement(insertOrUpdateSql); PreparedStatement updateFinalStatusStmt = conn.prepareStatement(updateFinalStatusSql)) {
            // Check if proposal already has an approval
            checkStmt.setInt(1, proposalId);
            ResultSet rs = checkStmt.executeQuery();

            boolean hasApproval = false;
            String currentAdminStatus = "pending";

            if (rs.next()) {
                hasApproval = true;
                currentAdminStatus = rs.getString("admin_status");
            }

            if (hasApproval && !"pending".equalsIgnoreCase(currentAdminStatus)) {
                throw new SQLException("Admin can only update when admin_status is 'pending'. Current: " + currentAdminStatus);
            }

            // Update or insert
            updateStmt.setInt(1, proposalId);
            updateStmt.setInt(2, adminApproverId);
            updateStmt.setString(3, adminStatus);
            updateStmt.setString(4, adminReason);
            updateStmt.setString(5, adminNote);
            updateStmt.executeUpdate();

            // Update final_status
            updateFinalStatusStmt.setInt(1, proposalId);
            updateFinalStatusStmt.executeUpdate();

        }
    }

public void directorUpdateProposal(int proposalId, String finalStatus, int directorApproverId, String directorReason, String directorNote) throws SQLException {
        String updateProposalSql = "UPDATE EmployeeProposals SET final_status = ?, executed_date = CASE WHEN ? = 'executed' THEN CURRENT_TIMESTAMP ELSE executed_date END WHERE proposal_id = ?";
        String updateApprovalSql = "INSERT INTO ProposalApprovals (proposal_id, director_approver_id, director_reason, director_note, director_approval_date) "
                + "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP) "
                + "ON DUPLICATE KEY UPDATE director_approver_id = ?, director_reason = ?, director_note = ?, director_approval_date = CURRENT_TIMESTAMP";

        conn.setAutoCommit(false);
        try (PreparedStatement ps1 = conn.prepareStatement(updateProposalSql); PreparedStatement ps2 = conn.prepareStatement(updateApprovalSql)) {

            // Cập nhật bảng EmployeeProposals
            ps1.setString(1, finalStatus);
            ps1.setString(2, finalStatus);
            ps1.setInt(3, proposalId);
            ps1.executeUpdate();

            // Cập nhật hoặc chèn bảng ProposalApprovals
            ps2.setInt(1, proposalId);
            ps2.setInt(2, directorApproverId);
            ps2.setString(3, directorReason);
            ps2.setString(4, directorNote);
            ps2.setInt(5, directorApproverId);
            ps2.setString(6, directorReason);
            ps2.setString(7, directorNote);
            ps2.executeUpdate();

            conn.commit();
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }
}
