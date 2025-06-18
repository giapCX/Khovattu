package dao;

import Dal.DBContext;
import model.Proposal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.sql.*;
import model.ProposalDetails;

public class ProposalDAO {

    private Connection conn;

    public ProposalDAO(Connection conn) {
        this.conn = DBContext.getConnection();
    }
public boolean addProposal(Proposal proposal) throws SQLException {
    String insertProposalSQL = "INSERT INTO EmployeeProposals (proposal_type, proposer_id, note) VALUES (?, ?, ?)";
    try (PreparedStatement ps = conn.prepareStatement(insertProposalSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
        ps.setString(1, proposal.getProposalType());
        ps.setInt(2, proposal.getProposerId());
        ps.setString(3,proposal.getNote());
        int rowsAffected = ps.executeUpdate();
        if (rowsAffected > 0) {
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int proposalId = rs.getInt(1);
                    if (proposal.getProposalDetails() != null && !proposal.getProposalDetails().isEmpty()) {
                        return addProposalDetails(proposalId, proposal.getProposalDetails());
                    }
                }
            }
        }
        return false;
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

}