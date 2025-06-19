<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Import Receipt Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light text-dark">
<div class="container my-5">

    <!-- Title -->
    <div class="mb-4 border-bottom pb-2">
        <h2 class="text-primary fw-bold">Import Receipt Details</h2>
    </div>

    <!-- General Information -->
    <div class="row mb-3">
        <div class="col-md-6">
            <strong>Receipt Code:</strong> ${receipt.voucherId}
        </div>
        <div class="col-md-6">
            <strong>Import Date:</strong> ${receipt.importDate}
        </div>
        <div class="col-md-6">
            <strong>Importer:</strong> ${receipt.importerName}
        </div>
        <div class="col-md-6">
            <strong>Total Amount:</strong> ${receipt.total} đ
        </div>
        <div class="col-12">
            <strong>Note:</strong> ${receipt.note}
        </div>
    </div>

    <!-- Filters -->
    <form method="get" action="importhistorydetail" class="row g-2 mb-4">
        <input type="hidden" name="importId" value="${receipt.importId}" />
        <div class="col-md-5">
            <input type="text" name="keyword" value="${param.keyword}" class="form-control" placeholder="Search material name..." />
        </div>
        <div class="col-md-4">
            <select name="sort" class="form-select">
                <option value="">Sort by price</option>
                <option value="asc" ${param.sort == 'asc' ? 'selected' : ''}>Ascending</option>
                <option value="desc" ${param.sort == 'desc' ? 'selected' : ''}>Descending</option>
            </select>
        </div>
        <div class="col-md-3">
            <button type="submit" class="btn btn-primary w-100">Filter</button>
        </div>
    </form>

    <!-- Material Details Table -->
    <h5 class="fw-bold mb-3">Imported Materials List</h5>
    <div class="table-responsive">
        <table class="table table-bordered table-hover align-middle">
            <thead class="table-primary">
                <tr>
                    <th>Material ID</th>
                    <th>Material Name</th>
                    <th>Quantity</th>
                    <th>Unit Price</th>
                    <th>Total Price</th>
                    <th>Supplier</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="detail" items="${details}">
                    <tr>
                        <td>${detail.materialId}</td>
                        <td>${detail.materialName}</td>
                        <td>${detail.quantity}</td>
                        <td>${detail.pricePerUnit}</td>
                        <td>${detail.totalPrice}</td>
                        <td>${detail.supplierName}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <nav class="mt-4">
        <ul class="pagination justify-content-center">
            <c:forEach var="i" begin="1" end="${totalPages}">
                <li class="page-item ${i == currentPage ? 'active' : ''}">
                    <a class="page-link"
                       href="importhistorydetail?importId=${receipt.importId}&page=${i}&keyword=${param.keyword}&sort=${param.sort}">
                        ${i}
                    </a>
                </li>
            </c:forEach>
        </ul>
    </nav>

</div>
</body>
</html>
