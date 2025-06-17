package model;
import java.sql.Timestamp;
import java.util.List;

public class Proposal {
    private int proposalId;
    private String proposalType;
    private int proposerId;
    private Timestamp sendDate;
    private String status;
    private Timestamp executedDate;
    private List<ProposalDetails> proposalDetails; 

    public Proposal() {
    }

    public Proposal(int proposalId, String proposalType, int proposerId, Timestamp sendDate, String status, Timestamp executedDate, List<ProposalDetails> proposalDetails) {
        this.proposalId = proposalId;
        this.proposalType = proposalType;
        this.proposerId = proposerId;
        this.sendDate = sendDate;
        this.status = status;
        this.executedDate = executedDate;
        this.proposalDetails = proposalDetails;
    }

    public int getProposalId() {
        return proposalId;
    }

    public void setProposalId(int proposalId) {
        this.proposalId = proposalId;
    }

    public String getProposalType() {
        return proposalType;
    }

    public void setProposalType(String proposalType) {
        this.proposalType = proposalType;
    }

    public int getProposerId() {
        return proposerId;
    }

    public void setProposerId(int proposerId) {
        this.proposerId = proposerId;
    }

    public Timestamp getSendDate() {
        return sendDate;
    }

    public void setSendDate(Timestamp sendDate) {
        this.sendDate = sendDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getExecutedDate() {
        return executedDate;
    }

    public void setExecutedDate(Timestamp executedDate) {
        this.executedDate = executedDate;
    }

    public List<ProposalDetails> getProposalDetails() {
        return proposalDetails;
    }

    public void setProposalDetails(List<ProposalDetails> proposalDetails) {
        this.proposalDetails = proposalDetails;
    }

   
    

}