package model;

import java.util.Date;

public class Proposal {
    private int id;
    private String type;
    private String sender;
    private Date sendDate;
    private String finalApprover;
    private Date approvalDate;
    private String status;

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