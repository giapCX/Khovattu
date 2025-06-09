package model;

import java.util.Date;

public class Proposal {

    private int id; // Mã đề xuất (proposal_id)
    private String type; // Loại đề xuất (proposal_type)
    private String sender; // Người gửi (full_name từ Users dựa trên proposer_id)
    private Date sendDate; // Ngày gửi (proposal_sent_date)
    private String finalApprover; // Người duyệt cuối (full_name từ Users dựa trên director_approver_id hoặc admin_approver_id)
    private Date approvalDate; // Ngày duyệt (director_approval_date hoặc admin_approval_date)
    private String status; // Trạng thái duyệt (status từ EmployeeProposals)

    // Constructor
    public Proposal(int id, String type, String sender, Date sendDate, String finalApprover, Date approvalDate, String status) {
        this.id = id;
        this.type = type;
        this.sender = sender;
        this.sendDate = sendDate;
        this.finalApprover = finalApprover;
        this.approvalDate = approvalDate;
        this.status = status;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public Date getSendDate() {
        return sendDate;
    }

    public void setSendDate(Date sendDate) {
        this.sendDate = sendDate;
    }

    public String getFinalApprover() {
        return finalApprover;
    }

    public void setFinalApprover(String finalApprover) {
        this.finalApprover = finalApprover;
    }

    public Date getApprovalDate() {
        return approvalDate;
    }

    public void setApprovalDate(Date approvalDate) {
        this.approvalDate = approvalDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
