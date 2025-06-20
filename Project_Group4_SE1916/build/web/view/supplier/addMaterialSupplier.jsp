<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>New Material Of Supplier</title>
        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <!-- Custom CSS -->
        <style>
            body {
                background-color: #f5f7fa;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .container {
                max-width: 1200px;
                background: #fff;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                margin-top: 20px;
            }
            h1, h2 {
                color: #2c3e50;
            }
            .table thead {
                background-color: #34495e;
                color: #fff;
            }
            .table th, .table td {
                vertical-align: middle;
            }
            .form-control, .form-select {
                border-radius: 4px;
            }
            .btn-primary {
                background-color: #0284c7;
                border: none;
            }
            .btn-primary:hover {
                background-color: #3498db;
            }
            .btn-danger {
                background-color: #e74c3c;
            }
            .btn-danger:hover {
                background-color: #c0392b;
            }
            .btn-success {
                background-color: #27ae60;
            }
            .btn-success:hover {
                background-color: #219653;
            }
            .error {
                color: #e74c3c;
                font-size:  2.5em;
            }
            .success {
                color: #27ae60;
                font-size: 2.5em;
            }
            .autocomplete-suggestion {
                padding: 8px;
                cursor: pointer;
            }
            .autocomplete-suggestion:hover {
                background-color: #e9ecef;
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

            <form action="AddMaterialSupplier" method="post">
                <input type="hidden" name="supplierId" value="${supplierId}" />
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h2 class="mb-0"><i class="fas fa-list-alt me-2"></i>Add new material for supplier </h2>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered" id="importDetailsTable">
                                <thead>
                                    <tr>
                                        <th style="width: 10%">Parent Category</th>
                                        <th style="width: 10%">Child Category</th>
                                        <th style="width: 10%">Name of Material</th>
                                        <th style="width: 10%">Unit</th>
                                    </tr>
                                </thead>
                                <tbody id="itemsBody">
                                    <tr>
                                        <td>
                                            <select class="parentCategory" name="parentCategoryId[]">
                                                <option value="">Choose parent category</option>
                                                <c:forEach var="cat" items="${parentCategories}">
                                                    <option value="${cat.categoryId}">${cat.name}</option>
                                                </c:forEach>
                                            </select>
                                        </td>
                                        <td>
                                            <select class="childCategory" name="childCategoryId[]">
                                                <option value="">Choose child category</option>
                                                <c:forEach var="cat" items="${childCategories}">
                                                    <option value="${cat.categoryId}" data-parent="${cat.parentId}">${cat.name}</option>
                                                </c:forEach>
                                            </select>
                                        </td>
                                        <td>
                                            <select class="nameMaterial" name="materialId[]">
                                                <option value="">Choose name of material</option>
                                                <c:forEach var="cat" items="${material}">
                                                    <option value="${cat.materialId}"  data-parent="${cat.category.categoryId}">${cat.name}</option>
                                                </c:forEach>
                                            </select>
                                        </td>
                                        <td>
                                            <select class="unitMaterial" name="unit[]">
                                                <option value="">Unit</option>
                                                <c:forEach var="cat" items="${material}">
                                                    <option value="${cat.unit}"  data-parent="${cat.materialId}">${cat.unit}</option>
                                                </c:forEach>
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
            // Khi chọn parent category, lọc lại child category
            document.addEventListener('change', function (e) {
                if (e.target.classList.contains('parentCategory')) {
                    const parentId = e.target.value;
                    const row = e.target.closest('tr');
                    const childSelect = row.querySelector('.childCategory');

                    childSelect.querySelectorAll('option').forEach(function (option) {
                        const optionParentId = option.getAttribute('data-parent');
                        option.style.display = (!parentId || optionParentId === parentId) ? '' : 'none';
                    });
                    childSelect.value = '';

                    // Reset material + unit
                    const materialSelect = row.querySelector('.nameMaterial');
                    filterMaterialByCategory(materialSelect, parentId);
                }
            });

// Khi chọn child category, lọc lại material
            document.addEventListener('change', function (e) {
                if (e.target.classList.contains('childCategory')) {
                    const childId = e.target.value;
                    const row = e.target.closest('tr');
                    const materialSelect = row.querySelector('.nameMaterial');
                    filterMaterialByCategory(materialSelect, childId);
                }
            });

// Khi chọn material, lọc lại unit
            document.addEventListener('change', function (e) {
                if (e.target.classList.contains('nameMaterial')) {
                    const selectedMaterialId = e.target.value;
                    const row = e.target.closest('tr');
                    const unitSelect = row.querySelector('.unitMaterial');

                    unitSelect.querySelectorAll('option').forEach(function (option) {
                        const optionParentId = option.getAttribute('data-parent');
                        if (!selectedMaterialId || optionParentId === selectedMaterialId) {
                            option.style.display = '';
                            unitSelect.value = option.value;
                        } else {
                            option.style.display = 'none';
                        }
                    });
                }
            });

            function filterMaterialByCategory(materialSelect, categoryId) {
                materialSelect.querySelectorAll('option').forEach(function (option) {
                    const optionCatId = option.getAttribute('data-parent');
                    option.style.display = (!categoryId || optionCatId === categoryId) ? '' : 'none';
                });
                materialSelect.value = '';
            }

        </script>

    </body>
</html>