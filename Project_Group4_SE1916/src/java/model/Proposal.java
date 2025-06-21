package model;

import java.sql.Timestamp;
import java.util.List;

public class Proposal {

    private int proposalId;
    private String proposalType;
    private int proposerId;
    private String senderName;
    private String note;
    private Timestamp proposalSentDate;
    private String finalStatus;
    private Timestamp approvalDate;
    private List<ProposalDetails> proposalDetails;
    private ProposalApprovals approval;
    private String directorStatus; // New field for director status

    public Proposal() {
    }

    public ProposalApprovals getApproval() {
        return approval;
    }

    public void setApproval(ProposalApprovals approval) {
        this.approval = approval;
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

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Timestamp getProposalSentDate() {
        return proposalSentDate;
    }

    public void setProposalSentDate(Timestamp proposalSentDate) {
        this.proposalSentDate = proposalSentDate;
    }

    public String getFinalStatus() {
        return finalStatus;
    }

    public void setFinalStatus(String finalStatus) {
        this.finalStatus = finalStatus;
    }

    public Timestamp getApprovalDate() {
        return approvalDate;
    }

    public void setApprovalDate(Timestamp approvalDate) {
        this.approvalDate = approvalDate;
    }

    public List<ProposalDetails> getProposalDetails() {
        return proposalDetails;
    }

    public void setProposalDetails(List<ProposalDetails> proposalDetails) {
        this.proposalDetails = proposalDetails;
    }

    public String getDirectorStatus() {
        return directorStatus;
    }

    public void setDirectorStatus(String directorStatus) {
        this.directorStatus = directorStatus;
    }
}
