<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Director Approve Proposal</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <!-- Custom CSS -->
    <style>
        body {
            background-color: #f4f6f9;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #2c3e50;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 1200px;
            background-color: #fff;
            margin: 30px auto;
            padding: 25px 30px;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.08);
        }
        h1, h2 {
            font-weight: bold;
            margin-bottom: 20px;
        }
        h1 {
            font-size: 2rem;
            display: flex;
            align-items: center;
            gap: 10px;
            color: #1d3557;
        }
        .card {
            border: none;
            border-radius: 8px;
            overflow: hidden;
        }
        .card-header {
            padding: 15px 20px;
        }
        .card-header.bg-primary {
            background-color: #0284c7 !important;
            color: white;
        }
        .card-body {
            padding: 20px;
        }
        .form-control, .form-select {
            border-radius: 6px;
            padding: 10px;
            font-size: 0.95rem;
        }
        .table {
            margin-bottom: 0;
        }
        .table th, .table td {
            vertical-align: middle !important;
            text-align: center;
            font-size: 0.95rem;
        }
        .table thead {
            background-color: #34495e;
            color: white;
        }
        .btn {
            border-radius: 5px;
            font-weight: 500;
        }
        .btn-primary {
            background-color: #0284c7;
            border: none;
        }
        .btn-primary:hover {
            background-color: #3498db;
        }
        .btn-secondary {
            background-color: #95a5a6;
            border: none;
        }
        .btn-secondary:hover {
            background-color: #7f8c8d;
        }
        .success, .error {
            font-size: 1.3rem;
            margin-top: 20px;
            font-weight: bold;
        }
        .success {
            color: #27ae60;
        }
        .error {
            color: #e74c3c;
        }
        @media screen and (max-width: 768px) {
            .table-responsive {
                overflow-x: auto;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="mb-4"><i class="fas fa-file-alt me-2"></i>Director Approve Proposal #${proposal.proposalId}</h1>

        <!-- Back Button -->
        <div class="mb-4">
            <a href="${pageContext.request.contextPath}/proposals" class="btn btn-secondary">
                <i class="fas fa-arrow-left me-2"></i>Back to Proposals History
            </a>
        </div>

        <!-- Information Proposal -->
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h2 class="mb-0"><i class="fas fa-info-circle me-2"></i>Information Proposal</h2>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <label class="col-sm-2 col-form-label">Proposal ID</label>
                    <div class="col-sm-10">
                        <input class="form-control" value="${proposal.proposalId}" readonly>
                    </div>
                </div>
                <div class="row mb-3">
                    <label class="col-sm-2 col-form-label">Proposer</label>
                    <div class="col-sm-10">
                        <input class="form-control" value="${proposal.senderName}" readonly>
                    </div>
                </div>
                <div class="row mb-3">
                    <label class="col-sm-2 col-form-label">Proposal Type</label>
                    <div class="col-sm-10">
                        <input class="form-control" value="${proposal.proposalType}" readonly>
                    </div>
                </div>
                <div class="row mb-3">
                    <label class="col-sm-2 col-form-label">Submission Date</label>
                    <div class="col-sm-10">
                        <input class="form-control" value="<fmt:formatDate value='${proposal.proposalSentDate}' pattern='yyyy-MM-dd'/>" readonly>
                    </div>
                </div>
                <div class="row mb-3">
                    <label class="col-sm-2 col-form-label">Note</label>
                    <div class="col-sm-10">
                        <textarea class="form-control" rows="3" readonly>${proposal.note}</textarea>
                    </div>
                </div>
                <div class="row mb-3">
                    <label class="col-sm-2 col-form-label">Admin Status</label>
                    <div class="col-sm-10">
                        <input class="form-control" value="${proposal.approval.adminStatus}" readonly>
                    </div>
                </div>
                <div class="row mb-3">
                    <label class="col-sm-2 col-form-label">Admin Reason</label>
                    <div class="col-sm-10">
                        <textarea class="form-control" rows="2" readonly>${proposal.approval.adminReason}</textarea>
                    </div>
                </div>
                <div class="row mb-3">
                    <label class="col-sm-2 col-form-label">Admin Note</label>
                    <div class="col-sm-10">
                        <textarea class="form-control" rows="2" readonly>${proposal.approval.adminNote}</textarea>
                    </div>
                </div>
                <div class="row mb-3">
                    <label class="col-sm-2 col-form-label">Director Status</label>
                    <div class="col-sm-10">
                        <input class="form-control" value="${proposal.approval.directorStatus}" readonly>
                    </div>
                </div>
                <c:if test="${proposal.approval.directorStatus != 'pending'}">
                    <div class="row mb-3">
                        <label class="col-sm-2 col-form-label">Director Note</label>
                        <div class="col-sm-10">
                            <textarea class="form-control" rows="3" readonly>${proposal.approval.directorNote}</textarea>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>

        <!-- List of Proposed Materials -->
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h2 class="mb-0"><i class="fas fa-list-alt me-2"></i>List of Proposed Materials</h2>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th style="width: 10%">Name of Material</th>
                                <th style="width: 10%">Unit</th>
                                <th style="width: 15%">Quantity</th>
                                <th style="width: 10%">Material Condition</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="detail" items="${proposal.proposalDetails}">
                                <tr>
                                    <td>${detail.materialName}</td>
                                    <td>${detail.unit}</td>
                                    <td>${detail.quantity}</td>
                                    <td>${detail.materialCondition}</td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty proposal.proposalDetails}">
                                <tr>
                                    <td colspan="4" class="text-center">No materials proposed.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Director Approval Form -->
        <c:if test="${proposal.approval.directorStatus == 'pending'}">
            <div class="card mb-4">
                <div class="card-header bg-primary text-white">
                    <h2 class="mb-0"><i class="fas fa-check-circle me-2"></i>Director Approval</h2>
                </div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/DirectorApproveProposal" method="post" onsubmit="return validateForm()">
                        <input type="hidden" name="proposalId" value="${proposal.proposalId}">
                        <div class="row mb-3">
                            <label class="col-sm-2 col-form-label">Director Status</label>
                            <div class="col-sm-10">
                                <select name="directorStatus" id="directorStatus" class="form-select" required>
                                    <option value="approved">Approved</option>
                                    <option value="rejected">Rejected</option>
                                </select>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <label class="col-sm-2 col-form-label">Director Note</label>
                            <div class="col-sm-10">
                                <textarea class="form-control" name="directorNote" id="directorNote" rows="3" placeholder="Enter your notes (required if rejected)"></textarea>
                                <small id="noteError" class="text-danger" style="display:none;">Note is required when rejecting</small>
                            </div>
                        </div>
                        <div class="d-flex justify-content-end gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-2"></i>Submit Decision
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            
            <script>
                function validateForm() {
                    const status = document.getElementById('directorStatus').value;
                    const note = document.getElementById('directorNote').value.trim();
                    const noteError = document.getElementById('noteError');
                    
                    if (status === 'rejected' && note === '') {
                        noteError.style.display = 'block';
                        return false;
                    }
                    noteError.style.display = 'none';
                    return true;
                }
                
                // Show/hide note requirement based on status selection
                document.getElementById('directorStatus').addEventListener('change', function() {
                    const noteLabel = document.querySelector('label[for="directorNote"]');
                    if (this.value === 'rejected') {
                        noteLabel.innerHTML = 'Director Note <span class="text-danger">*</span>';
                    } else {
                        noteLabel.innerHTML = 'Director Note';
                    }
                });
            </script>
        </c:if>

        <!-- Messages -->
        <c:if test="${not empty message}">
            <p class="success mt-3">${message}</p>
        </c:if>
        <c:if test="${not empty error}">
            <p class="error mt-3">${error}</p>
        </c:if>
    </div>
</body>
</html>