package model;

import java.sql.Timestamp;
import java.util.List;

public class Proposal {

    private int proposalId;
    private String proposalType;
    private int proposerId;
    private int executorId;
    private int receiverId;
    private String senderName;
    private String executorName;
    private String note;
    private Timestamp proposalSentDate;
    private String finalStatus;
    private Timestamp executeDate;
    private Timestamp approvalDate;
    private List<ProposalDetails> proposalDetails;
    private ProposalApprovals approval;
    private String adminStatus;
    private String directorStatus;
    private String finalApprover; // New field for final approver name

    public Proposal() {
    }

    public String getAdminStatus() {
        return adminStatus;
    }

    public void setAdminStatus(String adminStatus) {
        this.adminStatus = adminStatus;
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

    public String getFinalApprover() {
        return finalApprover;
    }

    public void setFinalApprover(String finalApprover) {
        this.finalApprover = finalApprover;
    }

    public Timestamp getExecuteDate() {
        return executeDate;
    }

    public void setExecuteDate(Timestamp executeDate) {
        this.executeDate = executeDate;
    }

    public int getExecutorId() {
        return executorId;
    }

    public void setExecutorId(int executorId) {
        this.executorId = executorId;
    }

    public String getExecutorName() {
        return executorName;
    }

    public void setExecutorName(String executorName) {
        this.executorName = executorName;
    }

    public int getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(int receiverId) {
        this.receiverId = receiverId;
    }
    
    

}
