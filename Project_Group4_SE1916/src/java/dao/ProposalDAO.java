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
import java.util.List;

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
            "SELECT ep.proposal_id, ep.proposal_type, ep.proposer_id, u.full_name AS sender_name, ep.note, ep.proposal_sent_date, COALESCE(ep.final_status, 'pending') AS status, pa.admin_approval_date, pa.director_approval_date " +
            "FROM EmployeeProposals ep " +
            "LEFT JOIN Users u ON ep.proposer_id = u.user_id " +
            "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id " +
            "WHERE 1=1"
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
                    proposal.setSenderName(rs.getString("sender_name")); // New field
                    proposal.setNote(rs.getString("note"));
                    proposal.setProposalSentDate(rs.getTimestamp("proposal_sent_date"));
                    proposal.setFinalStatus(rs.getString("status"));
                    proposal.setApprovalDate(rs.getTimestamp("admin_approval_date") != null ? rs.getTimestamp("admin_approval_date") : rs.getTimestamp("director_approval_date")); // Use admin or director approval date
                    proposals.add(proposal);
                }
            }
        }
        return proposals;
    }

    public int getPendingProposalsCount(String search, String dateFrom, String dateTo, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) " +
            "FROM EmployeeProposals ep " +
            "LEFT JOIN Users u ON ep.proposer_id = u.user_id " +
            "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id " +
            "WHERE 1=1"
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
}