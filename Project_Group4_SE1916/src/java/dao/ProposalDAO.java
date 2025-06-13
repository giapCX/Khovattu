package dao;

import Dal.DBContext;
import model.Proposal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ProposalDAO {

    private Connection conn;

    public ProposalDAO() {
        this.conn = DBContext.getConnection();
    }

    public List<Proposal> getProposals(String search, String status, String startDate, String endDate, int page, int itemsPerPage) throws SQLException {
        List<Proposal> proposals = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT ep.proposal_id, ep.proposal_type, ep.final_status, u.full_name AS sender, ep.proposal_sent_date, " +
                "ua.full_name AS final_approver, pa.director_approval_date AS approval_date " +
                "FROM EmployeeProposals ep " +
                "LEFT JOIN Users u ON ep.proposer_id = u.user_id " +
                "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id AND pa.approval_level = 'director' " +
                "LEFT JOIN Users ua ON pa.director_approver_id = ua.user_id " +
                "WHERE 1=1");

        // Thêm điều kiện tìm kiếm
        List<Object> params = new ArrayList<>();
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (ep.proposal_id LIKE ? OR u.full_name LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }

        // Thêm điều kiện trạng thái
        if (status != null && !status.isEmpty()) {
            sql.append(" AND ep.final_status = ?");
            params.add(status);
        }

        // Thêm điều kiện ngày
        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date <= ?");
            params.add(endDate);
        }

        // Phân trang
        sql.append(" LIMIT ? OFFSET ?");
        params.add(itemsPerPage);
        params.add((page - 1) * itemsPerPage);

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("proposal_id");
                String type = rs.getString("proposal_type");
                String sender = rs.getString("sender");
                Date sendDate = rs.getDate("proposal_sent_date");
                String finalApprover = rs.getString("final_approver");
                Date approvalDate = rs.getDate("approval_date");
                String finalStatus = rs.getString("final_status");

                Proposal proposal = new Proposal(id, type, sender, sendDate, finalApprover, approvalDate, finalStatus);
                proposals.add(proposal);
            }
        }
        return proposals;
    }

    public int getTotalProposals(String search, String status, String startDate, String endDate) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total " +
                "FROM EmployeeProposals ep " +
                "LEFT JOIN Users u ON ep.proposer_id = u.user_id " +
                "LEFT JOIN ProposalApprovals pa ON ep.proposal_id = pa.proposal_id AND pa.approval_level = 'director' " +
                "WHERE 1=1");

        List<Object> params = new ArrayList<>();
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (ep.proposal_id LIKE ? OR u.full_name LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }

        if (status != null && !status.isEmpty()) {
            sql.append(" AND ep.final_status = ?");
            params.add(status);
        }

        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND ep.proposal_sent_date <= ?");
            params.add(endDate);
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        }
        return 0;
    }
}