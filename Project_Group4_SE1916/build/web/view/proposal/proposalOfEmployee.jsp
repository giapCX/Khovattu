<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Proposal</title>
        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <!-- Custom CSS -->
        <style>
            /* Reset mặc định nhẹ */
            * {
                box-sizing: border-box;
            }

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

            /* Tiêu đề */
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

            /* Form */
            .form-control,
            .form-select {
                border-radius: 6px;
                padding: 10px;
                font-size: 0.95rem;
            }

            /* Table */
            .table {
                margin-bottom: 0;
            }

            .table th,
            .table td {
                vertical-align: middle !important;
                text-align: center;
                font-size: 0.95rem;
            }

            .table thead {
                background-color: #34495e;
                color: white;
            }

            /* Button styles */
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

            .btn-success {
                background-color: #27ae60;
                border: none;
            }

            .btn-success:hover {
                background-color: #219653;
            }

            .btn-danger {
                background-color: #e74c3c;
                border: none;
            }

            .btn-danger:hover {
                background-color: #c0392b;
            }

            .btn-secondary {
                background-color: #95a5a6;
                border: none;
            }

            .btn-secondary:hover {
                background-color: #7f8c8d;
            }

            /* Thông báo */
            .success,
            .error {
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

            /* Autocomplete suggestion */
            .autocomplete-suggestion {
                padding: 8px;
                cursor: pointer;
            }

            .autocomplete-suggestion:hover {
                background-color: #e9ecef;
            }

            /* Responsive table */
            @media screen and (max-width: 768px) {
                .table-responsive {
                    overflow-x: auto;
                }
            }

        </style>
    </head>
    <body>
        <%
            String role = (String) session.getAttribute("role");
            Integer userId = (Integer) session.getAttribute("userId");
            String userFullName = (String) session.getAttribute("userFullName");
        %>
        <div class="container">
            <h1 class="mb-4"><i class="fas fa-warehouse me-2"></i>Proposal</h1>

            <form action="${pageContext.request.contextPath}/ProposalServlet" method="post">
                <!-- Information -->
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h2 class="mb-0"><i class="fas fa-info-circle me-2"></i>Information Proposal</h2>
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="row mb-3">
                                <label class="col-sm-2 col-form-label">Proposer</label>
                                <div class="col-sm-10">
                                    <input class="form-control" value="${sessionScope.userFullName}" readonly>
                                </div>
                            </div>
                            <label class="col-sm-2 col-form-label">Proposal Type</label>
                            <div class="col-sm-10">
                                <select name="proposalType" class="form-select" required>
                                    <option value="export">Export</option>
                                    <option value="import">Import</option>
                                    <c:if test="${role == 'warehouse'}">
                                        <option value="repair">Repair</option>               
                                    </c:if>
                                </select>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <label class="col-sm-2 col-form-label">Note</label>
                            <div class="col-sm-10">
                                <textarea class="form-control" name="note" rows="3"></textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h2 class="mb-0"><i class="fas fa-list-alt me-2"></i>List of Proposed Materials </h2>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered" id="importDetailsTable">
                                <thead>
                                    <tr>
                                        <th style="width: 10%">Name of Material</th>
                                        <th style="width: 10%">Unit</th>
                                        <th style="width: 15%">Quantity</th>
                                        <th style="width: 10%">Material Condition </th>
                                        <th style="width: 5%">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="itemsBody">
                                    <tr>
                                        <td>
                                            <input list="materialList" class="form-control nameMaterialInput" name="materialName[]" autocomplete="off">
                                            <datalist id="materialList">
                                                <c:forEach var="cat" items="${material}">
                                                    <option 
                                                        value="${cat.name}" 
                                                        data-id="${cat.materialId}" 
                                                        data-parent="${cat.category.categoryId}" 
                                                        data-unit="${cat.unit}">
                                                        ${cat.name}
                                                    </option>
                                                </c:forEach>
                                            </datalist>
                                            <input type="hidden" name="materialId[]" class="materialIdHidden">
                                        </td>
                                        <td>
                                            <input type="text" name="unit[]" class="form-control unitMaterial" readonly>
                                        </td>
                                        <td><input type="number" name="quantity[]" class="form-control" value="0.00" step="0.01" min="0.01" required></td>
                                        <td>
                                            <select name="materialCondition[]" class="form-select" required>
                                                <option value="new">New</option>
                                                <option value="used">Used</option>
                                                <option value="damaged">Damaged</option>
                                            </select>
                                        </td>
                                        <td>
                                            <button type="button" class="btn btn-danger btn-sm" onclick="removeRow(this)">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <button type="button" class="btn btn-success mt-2" onclick="addRow()">
                            <i class="fas fa-plus me-2"></i>Add
                        </button>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save me-2"></i>Submit Proposal
                    </button>                   
                    <c:choose>
                        <c:when test="${role == 'warehouse'}">
                            <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="btn btn-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Back to home 
                            </a>
                        </c:when>
                        <c:when test="${role == 'employee'}">
                            <a href="${pageContext.request.contextPath}/view/employee/employeeDashboard.jsp" class="btn btn-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Back to home 
                            </a>                    
                        </c:when>
                    </c:choose>
                </div>

                <!-- Thông báo -->
                <c:if test="${not empty message}">
                    <p class="success mt-3">${message}</p>
                </c:if>
                <c:if test="${not empty error}">
                    <p class="error mt-3">${error}</p>
                </c:if>
            </form>
        </div>

        <script>
            function addRow() {
                const tbody = document.getElementById('itemsBody');
                const newRow = tbody.rows[0].cloneNode(true);
                newRow.querySelectorAll('input').forEach(input => input.value = '');
                newRow.querySelectorAll('select').forEach(select => select.selectedIndex = 0);
                tbody.appendChild(newRow);
                document.getElementById('itemCount').value = tbody.rows.length;
            }
            function removeRow(btn) {
                const tbody = document.getElementById('itemsBody');
                if (tbody.rows.length > 1) {
                    btn.closest('tr').remove();
                    document.getElementById('itemCount').value = tbody.rows.length;
                }
            }
            document.addEventListener('input', function (e) {
                if (e.target.classList.contains('nameMaterialInput')) {
                    const input = e.target;
                    const value = input.value.trim();
                    const row = input.closest('tr');
                    const hiddenInput = row.querySelector('.materialIdHidden');
                    const unitInput = row.querySelector('.unitMaterial');
                    const datalist = document.getElementById('materialList');
                    const options = datalist.options;

                    let foundId = '';
                    let foundUnit = '';

                    for (let i = 0; i < options.length; i++) {
                        if (options[i].value === value) {
                            foundId = options[i].getAttribute('data-id');
                            foundUnit = options[i].getAttribute('data-unit');
                            break;
                        }
                    }

                    hiddenInput.value = foundId;
                    unitInput.value = foundUnit;
                }
            });



        </script>

    </body>
</html>