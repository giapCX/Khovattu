<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Import Receipt Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8f9fa;
        }
        .container {
            max-width: 1200px;
        }
        /* Form styles */
        .form-control, .form-select {
            border-radius: 0.375rem;
            border: 1px solid #ced4da;
            font-size: 0.9rem;
            padding: 0.5rem;
        }
        .form-control:focus, .form-select:focus {
            border-color: #0d6efd;
            box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
        }
        .btn-primary {
            background-color: #0d6efd;
            border: none;
            font-size: 0.9rem;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
        }
        .btn-primary:hover {
            background-color: #0b5ed7;
        }
        .btn-back {
            background-color: #6c757d;
            border: none;
            font-size: 0.9rem;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            color: white;
        }
        .btn-back:hover {
            background-color: #5c636a;
        }
        /* Table styles */
        .table {
            background-color: #fff;
            border-radius: 0.375rem;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        .table th, .table td {
            vertical-align: middle;
            padding: 0.75rem;
        }
        .table-primary {
            background-color: #0d6efd;
            color: white;
        }
        .table-hover tbody tr:hover {
            background-color: #f1f3f5;
        }
        /* General info styles */
        .row.mb-3 > div {
            padding: 0.5rem 0;
            font-size: 0.95rem;
        }
        .row.mb-3 strong {
            color: #1f2937;
        }
        /* Pagination styles */
        .pagination .page-link {
            border-radius: 0.375rem;
            margin: 0 0.2rem;
            font-size: 0.9rem;
            color: #0d6efd;
        }
        .pagination .page-item.active .page-link {
            background-color: #0d6efd;
            border-color: #0d6efd;
        }
        .pagination .page-link:hover {
            background-color: #e9ecef;
        }
        /* Back button container */
        .back-button-container {
            text-align: center;
            margin-top: 1.5rem;
        }
    </style>
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
                    <a class="page-link text-white"
                       href="importhistorydetail?importId=${receipt.importId}&page=${i}&keyword=${param.keyword}&sort=${param.sort}">
                        ${i}
                    </a>
                </li>
            </c:forEach>
        </ul>
    </nav>

    <!-- Back Button -->
    <div class="back-button-container">
        <button onclick="history.back()" class="btn btn-back">Back</button>
    </div>
</div>
</body>
</html>