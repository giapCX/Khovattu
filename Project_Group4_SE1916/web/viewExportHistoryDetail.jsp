

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Export Receipt Details</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        
        <style>
            body {
                font-family: 'Inter', sans-serif;
                background-color: #f0f2f5; /* Matches bg-gray-50 from exportHistory */
                color: #1a1a1a;
            }
            .container {
                max-width: 1200px;
                background-color: #fff;
                padding: 20px;
                border-radius: 0 0 0.5rem 0.5rem; /* Rounded corners at the bottom */
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); /* Matches exportHistory shadow */
            }
            /* Form styles */
            .form-control, .form-select {
                border-radius: 0.5rem; /* Matches exportHistory input border-radius */
                border: 1px solid #d1d5db; /* Matches border-gray-300 */
                font-size: 0.9rem;
                padding: 0.5rem;
                background-color: #fff;
                transition: border-color 0.2s, box-shadow 0.2s;
            }
            .form-control:focus, .form-select:focus {
                border-color: #2563eb; /* Matches focus:ring-primary-500 */
                box-shadow: 0 0 0 0.2rem rgba(37, 99, 235, 0.2);
                outline: none;
            }
            .btn-primary {
                background-color: #2563eb; /* Matches bg-primary-600 */
                border: none;
                font-size: 0.9rem;
                padding: 0.5rem 1rem;
                border-radius: 0.5rem;
                color: #fff;
                transition: background-color 0.3s;
            }
            .btn-primary:hover {
                background-color: #1d4ed8; /* Darker shade of primary-600 */
            }
            .btn-secondary {
                background-color: #6F7684; /* Matches bg-yellow-500 from exportHistory */
                border: none;
                font-size: 0.9rem;
                padding: 0.5rem 1rem;
                border-radius: 0.5rem;
                color: #fff;
                transition: background-color 0.3s;
            }
            .btn-secondary:hover {
                /*                background-color: #ca8a04;  Darker shade of yellow-500 */
                opacity: 0.8;
            }
            /* Table styles */
            .table-container {
                background-color: #fff;
                border-radius: 0 0 0.5rem 0.5rem; /* Rounded corners at the bottom */
                overflow: hidden; /* Ensure no content spills out */
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); /* Matches exportHistory shadow */
            }
            .table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 0; /* Remove default margin to avoid gap */
            }
            .table th, .table td {
                vertical-align: middle;
                padding: 0.75rem;
                border-bottom: 1px solid #e5e7eb; /* Matches border-gray-200, ensure bottom border */
                text-align: left;
            }
            .table th {
                background-color: #0284C7; /* Matches bg-primary-600 */
                color: #fff;
                font-weight: bold;
            }
            .table tbody tr:nth-child(even) {
                background-color: #f9fafb; /* Matches bg-gray-50 */
            }
            .table tbody tr:hover {
                background-color: #f3f4f6; /* Matches hover:bg-gray-100 */
            }
            /* General info styles */
            .row.mb-3 > div {
                padding: 0.5rem 0;
                font-size: 0.95rem;
            }
            .row.mb-3 strong {
                color: #1f2937; /* Matches text-gray-800 */
            }
            /* Pagination styles */
            .pagination .page-link {
                border-radius: 0.5rem;
                margin: 0 0.2rem;
                font-size: 0.9rem;
                color: #2563eb; /* Matches text-primary-600 */
                border: 1px solid #d1d5db; /* Matches border-gray-300 */
                transition: background-color 0.3s, border-color 0.3s;
            }
            .pagination .page-item.active .page-link {
                background-color: #2563eb; /* Matches bg-primary-600 */
                border-color: #2563eb;
                color: #fff;
            }
            .pagination .page-link:hover {
                background-color: #e5e7eb; /* Matches hover:bg-gray-200 */
                border-color: #2563eb;
            }
            /* Back button container */
            .back-button-container {
                text-align: center;
                margin-top: 1.5rem;
            }

            .filter-form input[type="button"] {
                padding: 8px 16px;
                background-color: #eab308;
                color: #fff;
                border: none;
                border-radius: 0.5rem;
                cursor: pointer;
                transition: background-color 0.3s;
            }
        </style>
    </head>
    <body class="bg-light text-dark">
        <div class="container my-5">
            <!-- Title -->
            <div class="mb-4 border-bottom pb-2">
                <h2 class="text-primary fw-bold">Export Receipt Details</h2>
            </div>

            <!-- General Information -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <strong>Receipt Code:</strong> ${receipt.receiptId}
                </div>
                <div class="col-md-6">
                    <strong>Export Date:</strong> ${receipt.exportDate}
                </div>
                <div class="col-md-6">
                    <strong>Exporter:</strong> ${receipt.exporterName}
                </div>
                <div class="col-12">
                    <strong>Note:</strong> ${receipt.note}
                </div>
            </div>

            <!-- Filters -->
            <form method="get" action="exportHistoryDetail" class="row g-2 mb-4">
                <input type="hidden" name="exportId" value="${receipt.exportId}" />
                <div class="col-md-3">
                    <input type="text" name="materialName" value="${param.materialName}" class="form-control" placeholder="Search material name..." />
                </div>
                <div class="col-md-3">
                    <input type="text" name="unit" value="${param.unit}" class="form-control" placeholder="Search unit ..." />
                </div>
                <div class="col-md-3">
<!--                    <input type="text" name="condition" value="${param.condition}" class="form-control" placeholder="Search material condition..." />-->
                    <select name="condition" value="${param.condition}" class="form-control">
                        <option value=""> All condition</option>
                        <option value="New" ${param.condition == 'New' ? 'selected' : ''}>New</option>
                        <option value="Used" ${param.condition == 'Used' ? 'selected' : ''}>Used</option>
                        <option value="Damaged" ${param.condition == 'Damaged' ? 'selected' : ''}>Damaged</option>

                    </select>
                </div>
                <div class="col-md-1">
                    <button type="submit" class="btn btn-primary w-100">Search</button>
                </div>
                <div class="col-md-1 filter-form">
                    <input type="button" value="Reset" onclick="window.location.href = 'exportHistoryDetail?exportId=${receipt.exportId}';">
                </div>

            </form>

            <!-- Material Details Table -->
            <h5 class="fw-bold mb-3">Exported Materials List</h5>
            <div class="table-container">
                <div class="table-responsive">
                    <table class="table table-bordered table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Material ID</th>
                                <th>Material Code</th>
                                <th>Material Name</th>
                                <th>Quantity</th>
                                <th>Unit</th>
                                <th>Condition</th>

                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="detail" items="${details}">
                                <tr>
                                    <td>${detail.materialId}</td>
                                    <td>${detail.materialCode}</td>
                                    <td>${detail.materialName}</td>
                                    <td>${detail.quantity}</td>
                                    <td>${detail.unit}</td>
                                    <td>${detail.materialCondition}</td>

                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <nav class="mt-4">
                <ul class="pagination justify-content-center">
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                            <a class="page-link"
                               href="exportHistoryDetail?exportId=${receipt.exportId}&page=${i}&materialName=${param.materialName}&unit=${param.unit}&materialCondition=${param.condition}">
                                ${i}
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </nav>

            <!-- Back Button -->
            <div class="back-button-container">
                <button onclick="window.location.href = './exportHistory'" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to List</button>
            </div>
        </div>
    </body>
</html>