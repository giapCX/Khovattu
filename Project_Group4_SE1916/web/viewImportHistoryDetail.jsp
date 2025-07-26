<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Import Receipt Details</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {
                font-family: 'Inter', sans-serif;
                background-color: #f0f2f5;
                color: #1a1a1a;
            }
            .container {
                max-width: 1200px;
                background-color: #fff;
                padding: 20px;
                border-radius: 0 0 0.5rem 0.5rem;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            }
            .form-control, .form-select {
                border-radius: 0.5rem;
                border: 1px solid #d1d5db;
                font-size: 0.9rem;
                padding: 0.5rem;
            }
            .btn-primary {
                background-color: #2563eb;
                border: none;
                font-size: 0.9rem;
                padding: 0.5rem 1rem;
                border-radius: 0.5rem;
                color: #fff;
            }
            .btn-secondary {
                background-color: #6F7684;
                border: none;
                font-size: 0.9rem;
                padding: 0.5rem 1rem;
                border-radius: 0.5rem;
                color: #fff;
            }
            .table th {
                background-color: #0284C7;
                color: #fff;
            }
        </style>
    </head>
    <body>
        <div class="container my-5">
            <!-- Header -->
            <div class="mb-4 border-bottom pb-2">
                <h2 class="text-primary fw-bold">Import Receipt Details</h2>
            </div>

            <!-- General Info -->
            <div class="row mb-3">
                <div class="col-md-6"><strong>Import ID:</strong> ${receipt.importId}</div>
                <div class="col-md-6"><strong>Proposal ID:</strong> ${receipt.proposalId}</div>
                <div class="col-md-6"><strong>Import Type:</strong>
                    <c:choose>
                        <c:when test="${receipt.importType == 'import_from_supplier'}">Purchase</c:when>
                        <c:when test="${receipt.importType == 'import_returned'}">Retrieve</c:when>
                        <c:otherwise>${receipt.importType}</c:otherwise>
                    </c:choose>
                </div>

                <c:if test="${receipt.deliverySupplierName != null}">
                    <div class="col-md-6"><strong>Delivery Supplier:</strong> ${receipt.deliverySupplierName}</div>
                </c:if>

                <c:if test="${receipt.deliverySupplierPhone != null}">
                    <div class="col-md-6"><strong>Supplier Phone:</strong> ${receipt.deliverySupplierPhone}</div>
                </c:if>

                <c:if test="${receipt.executorName != null}">
                    <div class="col-md-6"><strong>Executor:</strong> ${receipt.executorName}</div>
                </c:if>

                <div class="col-md-6"><strong>Import Date:</strong> ${receipt.importDate}</div>

                <c:if test="${receipt.note != null}">
                    <div class="col-12"><strong>Note:</strong> ${receipt.note}</div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger">${errorMessage}</div>
                </c:if>

            </div>

            <!-- Filter Controls -->
            <form  action="importhistorydetail" method="get" class="row mb-4">
                <input type="hidden" name="importId" value="${receipt.importId}" />
                <div class="col-md-4">
                    <input type="text" name="materialName" placeholder="Search Material Name" class="form-control"
                           value="${param.materialName}" />
                </div>
                <div class="col-md-4">
                    <select name="condition" class="form-select">
                        <option value="">All Conditions</option>
                        <option value="New" ${param.condition == 'New' ? 'selected' : ''}>New</option>
                        <option value="Used" ${param.condition == 'Used' ? 'selected' : ''}>Used</option>
                        <option value="Damaged" ${param.condition == 'Damaged' ? 'selected' : ''}>Damaged</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <button type="submit" class="btn btn-primary">Apply Filter</button>
                </div>
            </form>

            <!-- Material Table -->
            <h5 class="fw-bold mb-3">Imported Materials</h5>
            <div class="table-responsive">
                <table class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Material ID</th>
<!--                            <th>Material Code</th>-->
                            <th>Material Name</th>
                            <th>Quantity</th>
                            <th>Unit</th>
                            <th>Price/Unit</th>
                            <th>Condition</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="detail" items="${details}">

                            <tr>
                                <td>${detail.materialId}</td>
<!--                                <td>${detail.materialCode}</td>-->
                                <td>${detail.materialName}</td>
                                <td>${detail.quantity}</td>
                                <td>${detail.unit}</td>
                                <td>${detail.price}</td>
                                <td>${detail.materialCondition}</td>
                            </tr>

                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- Back Button -->
            <div class="text-center mt-4">
                <button onclick="window.location.href = './importhistory'" class="btn btn-secondary">Back to List</button>
            </div>
        </div>
    </body>
</html>
