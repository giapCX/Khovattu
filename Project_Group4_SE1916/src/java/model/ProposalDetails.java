/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class ProposalDetails {

    private int proposalDetailId;
    private String materialName;
    private Proposal proposal;
    private int materialId;
    private double quantity;
    private String materialCondition;
    private String unit;
    private Double  price;
    private Integer supplierId;
    private String supplierName;
    private Integer  siteId;
    private String siteName;

    public ProposalDetails() {
    }

    public ProposalDetails(int proposalDetailId, Proposal proposal, int materialId, double quantity, String materialCondition) {
        this.proposalDetailId = proposalDetailId;
        this.proposal = proposal;
        this.materialId = materialId;
        this.quantity = quantity;
        this.materialCondition = materialCondition;
    }

    public ProposalDetails(int proposalDetailId, String materialName, Proposal proposal, int materialId, double quantity, String materialCondition, String unit) {
        this.proposalDetailId = proposalDetailId;
        this.materialName = materialName;
        this.proposal = proposal;
        this.materialId = materialId;
        this.quantity = quantity;
        this.materialCondition = materialCondition;
        this.unit = unit;
    }

    public int getProposalDetailId() {
        return proposalDetailId;
    }

    public void setProposalDetailId(int proposalDetailId) {
        this.proposalDetailId = proposalDetailId;
    }

    public String getMaterialName() {
        return materialName;
    }

    public void setMaterialName(String materialName) {
        this.materialName = materialName;
    }

    public Proposal getProposal() {
        return proposal;
    }

    public void setProposal(Proposal proposal) {
        this.proposal = proposal;
    }

    public int getMaterialId() {
        return materialId;
    }

    public void setMaterialId(int materialId) {
        this.materialId = materialId;
    }

    public double getQuantity() {
        return quantity;
    }

    public void setQuantity(double quantity) {
        this.quantity = quantity;
    }

    public String getMaterialCondition() {
        return materialCondition;
    }

    public void setMaterialCondition(String materialCondition) {
        this.materialCondition = materialCondition;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public Double getPrice() {
        return price;
    }

    public void setPrice(Double price) {
        this.price = price;
    }

    public Integer getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Integer supplierId) {
        this.supplierId = supplierId;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public Integer getSiteId() {
        return siteId;
    }

    public void setSiteId(Integer siteId) {
        this.siteId = siteId;
    }

    public String getSiteName() {
        return siteName;
    }

    public void setSiteName(String siteName) {
        this.siteName = siteName;
    }

    

}
