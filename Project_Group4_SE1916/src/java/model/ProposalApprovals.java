/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

public class ProposalApprovals {

    private int approvalId;
    private Proposal proposal;
    private int adminApproverId;
    private int directorApproverId;
    private Timestamp adminApprovalDate;
    private String adminReason;
    private String adminNote;
    private Timestamp directorApprovalDate;
    private String directorReason;
    private String directorNote;
    private String adminStatus;
    private String directorStatus;

    public ProposalApprovals() {
        this.adminStatus = "pending";
        this.directorStatus = "pending";
    }

    public ProposalApprovals(int approvalId, Proposal proposal, int adminApproverId, int directorApproverId, Timestamp adminApprovalDate, String adminReason, String adminNote, Timestamp directorApprovalDate, String directorReason, String directorNote) {
        this.approvalId = approvalId;
        this.proposal = proposal;
        this.adminApproverId = adminApproverId;
        this.directorApproverId = directorApproverId;
        this.adminApprovalDate = adminApprovalDate;
        this.adminReason = adminReason;
        this.adminNote = adminNote;
        this.directorApprovalDate = directorApprovalDate;
        this.directorReason = directorReason;
        this.directorNote = directorNote;
    }

    public String getAdminStatus() {
        return adminStatus;
    }

    public void setAdminStatus(String adminStatus) {
        this.adminStatus = adminStatus;
    }

    public String getDirectorStatus() {
        return directorStatus;
    }

    public void setDirectorStatus(String directorStatus) {
        this.directorStatus = directorStatus;
    }

    public int getApprovalId() {
        return approvalId;
    }

    public void setApprovalId(int approvalId) {
        this.approvalId = approvalId;
    }

    public Proposal getProposal() {
        return proposal;
    }

    public void setProposal(Proposal proposal) {
        this.proposal = proposal;
    }

    public int getAdminApproverId() {
        return adminApproverId;
    }

    public void setAdminApproverId(int adminApproverId) {
        this.adminApproverId = adminApproverId;
    }

    public int getDirectorApproverId() {
        return directorApproverId;
    }

    public void setDirectorApproverId(int directorApproverId) {
        this.directorApproverId = directorApproverId;
    }

    public Timestamp getAdminApprovalDate() {
        return adminApprovalDate;
    }

    public void setAdminApprovalDate(Timestamp adminApprovalDate) {
        this.adminApprovalDate = adminApprovalDate;
    }

    public String getAdminReason() {
        return adminReason;
    }

    public void setAdminReason(String adminReason) {
        this.adminReason = adminReason;
    }

    public String getAdminNote() {
        return adminNote;
    }

    public void setAdminNote(String adminNote) {
        this.adminNote = adminNote;
    }

    public Timestamp getDirectorApprovalDate() {
        return directorApprovalDate;
    }

    public void setDirectorApprovalDate(Timestamp directorApprovalDate) {
        this.directorApprovalDate = directorApprovalDate;
    }

    public String getDirectorReason() {
        return directorReason;
    }

    public void setDirectorReason(String directorReason) {
        this.directorReason = directorReason;
    }

    public String getDirectorNote() {
        return directorNote;
    }

    public void setDirectorNote(String directorNote) {
        this.directorNote = directorNote;
    }

}
