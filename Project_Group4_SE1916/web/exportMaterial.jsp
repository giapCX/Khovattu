<%-- 
    Document   : exportMaterial
    Created on : Jun 9, 2025, 7:27:11 PM
    Author     : ASUS
--%>
<%@page import="dao.MaterialDAO"%>
<%@page import="model.Material"%>
<%@page import="dao.MaterialCategoryDAO"%>
<%@ page import="java.util.List" %>
<%@ page import="model.MaterialCategory" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Export Materials</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            /*background: linear-gradient(135deg, #6e8efb, #a777e3);*/
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #333;
        }
        .container {
            max-width: 900px;
            margin-top: 40px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            padding: 30px;
            backdrop-filter: blur(5px);
        }
        h1 {
            color: #2c3e50;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .form-label {
            font-weight: 500;
            color: #34495e;
        }
        .form-control, .form-select {
            border-radius: 8px;
            border: 1px solid #ddd;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        .form-control:focus, .form-select:focus {
            border-color: #6e8efb;
            box-shadow: 0 0 5px rgba(110, 142, 251, 0.5);
        }
        .table {
            background: #fff;
            border-radius: 10px;
            overflow: hidden;
        }
        .table th {
            background: #6e8efb;
            color: #fff;
            font-weight: 600;
        }
        .table th:first-child {
            width: 60px; /* Fixed width for STT column */
        }
        .btn-primary {
            background: linear-gradient(45deg, #6e8efb, #a777e3);
            border: none;
            border-radius: 8px;
            padding: 10px 20px;
            font-weight: 600;
        }
        .btn-danger, .btn-secondary, .btn-success, .btn-info {
            border-radius: 8px;
        }
        .alert {
            margin-top: 20px;
        }
        .error-row {
            background-color: #ffe6e6;
        }
        .btn-disabled {
            opacity: 0.65;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <%
        MaterialDAO materialDAO = new MaterialDAO();
        MaterialCategoryDAO cateDAO = new MaterialCategoryDAO();
        List<MaterialCategory> parentCategories = cateDAO.getAllParentCategories(); // Parent categories
        //List<Material> allCategories = materialDAO.getAllMaterials(); // All categories (including subcategories)
    %>

    <div class="container">
        <h1 class="text-center mb-4">Export Materials</h1>

        <!-- Display error message if present -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Display success message with exportId if present -->
        <c:if test="${not empty message}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${message} <c:if test="${not empty exportId}">(Export ID: ${exportId})</c:if>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/exportMaterial" method="post" class="needs-validation" novalidate>
            <div class="mb-3">
                <label for="userFN" class="form-label">Exporter</label>
                <input type="text" name="userFN" class="form-control" value="${sessionScope.userFullName != null ? sessionScope.userFullName : 'Not Identified'}" readonly>
                <c:if test="${empty sessionScope.userFullName}">
                    <p class="error mt-2">Not logged in or user information is missing. Please log in again.</p>
                </c:if>
            </div>

            <div class="mb-3">
                <label for="exportId" class="form-label">Export ID</label>
                <input type="text" class="form-control" id="exportId" name="exportId" required>
                <div class="invalid-feedback">Please enter the export ID.</div>
            </div>

            <div class="mb-3">
                <label for="voucherId" class="form-label">Voucher ID</label>
                <input type="text" class="form-control" id="voucherId" name="voucherId" required>
                <div class="invalid-feedback">Please enter the voucher ID.</div>
            </div>    

            <div class="mb-3">
                <label for="purpose" class="form-label">Export Purpose</label>
                <textarea class="form-control" id="purpose" name="purpose" rows="3" required></textarea>
                <div class="invalid-feedback">Please enter the export purpose.</div>
            </div>

            <div class="mb-3">
                <label class="form-label">Material List</label>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Parent Category</th> <!-- Select first -->
                            <th>Child Category</th>       <!-- Select based on parent -->
                            <th>Material Name</th>
                            <th>Material Code</th>
                            <th>Quantity</th>
                            <th>Unit</th>
                            <th>Condition</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="materialTableBody">
                        <tr>
                            <td class="serial-number">1</td>
                            <td>
                                <select class="form-select parent-category-select" name="parentCategoryId[]" required>
                                    <option value="">Select parent category</option>
                                    <%
                                        for (MaterialCategory cat : parentCategories) {
                                    %>
                                        <option value="<%= cat.getCategoryId()%>"><%= cat.getName()%></option>
                                    <%
                                        }
                                    %>
                                </select>
                            </td>
                            <td>
                                <select class="form-select category-select" name="categoryId[]" required disabled>
                                    <option value="">Select child category</option>
                                </select>
                            </td>
                            <td>
                                <select class="form-select material-name-select" name="materialName[]" required disabled>
                                    <option value="">-- Select material name --</option>
                                </select>
                            </td>
                            <td>
                                <select class="form-select material-code-select" name="materialCode[]" required disabled>
                                    <option value="">-- Select material code --</option>
                                </select>
                            </td>
                            <td><input type="number" class="form-control" name="quantity[]" min="1" required></td>
                            <td><input type="text" class="form-control unit-display" name="unit[]" readonly></td>
                            <td>
                                <select class="form-select" name="condition[]" required>
                                    <option value="">Select condition</option>
                                    <option value="new">New</option>
                                    <option value="used">Used</option>
                                    <option value="damaged">Damaged</option>
                                </select>
                            </td>
                            <td><button type="button" class="btn btn-danger btn-sm remove-row" disabled>Delete</button></td>
                        </tr>
                    </tbody>
                </table>
                <button type="button" class="btn btn-secondary" id="addMaterialBtn">Add Material</button>
            </div>

            <div class="mb-3">
                <label for="requiredDate" class="form-label">Required Export Date</label>
                <input type="date" class="form-control" id="requiredDate" name="requiredDate" required>
                <div class="invalid-feedback">Please select the required export date.</div>
            </div>

            <div class="mb-3">
                <label for="additionalNote" class="form-label">Additional Notes</label>
                <textarea class="form-control" id="additionalNote" name="additionalNote" rows="3"></textarea>
            </div>

            <button type="submit" class="btn btn-primary">Save Export Voucher</button>
            <button type="reset" class="btn btn-info">Reset</button>
            <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
        </form>
    </div>

    <script>
        let materialData = []; // Initialize empty

        // Function to attach event listeners to parent category select
        function attachParentCategoryListener(parentCategorySelect) {
            parentCategorySelect.addEventListener("change", function () {
                const selectedParentCategoryId = this.value;
                console.log('Selected parentCategoryId:', selectedParentCategoryId); // Log for debugging
                const row = this.closest("tr");
                const categorySelect = row.querySelector(".category-select");
                const nameSelect = row.querySelector(".material-name-select");
                const codeSelect = row.querySelector(".material-code-select");
                const unitInput = row.querySelector(".unit-display");

                // Reset
                categorySelect.innerHTML = '<option value="">Select child category</option>';
                nameSelect.innerHTML = '<option value="">-- Select material name --</option>';
                codeSelect.innerHTML = '<option value="">-- Select material code --</option>';
                unitInput.value = '';
                categorySelect.disabled = !selectedParentCategoryId;
                nameSelect.disabled = true;
                codeSelect.disabled = true;

                if (!selectedParentCategoryId) return;

                // Filter subcategories based on parentCategoryId
                const childCategories = materialData
                    .filter(mat => mat.category.parentId == selectedParentCategoryId)
                    .map(mat => ({ categoryId: mat.category.categoryId, name: mat.category.name }))
                    .reduce((unique, item) => {
                        if (!unique.some(cat => cat.categoryId === item.categoryId)) unique.push(item);
                        return unique;
                    }, []);

                childCategories.forEach(cat => {
                    categorySelect.add(new Option(cat.name, cat.categoryId));
                });

                // Attach event for categorySelect
                categorySelect.onchange = function () {
                    const selectedCategoryId = this.value;
                    console.log('Selected categoryId:', selectedCategoryId);
                    nameSelect.innerHTML = '<option value="">-- Select material name --</option>';
                    codeSelect.innerHTML = '<option value="">-- Select material code --</option>';
                    unitInput.value = '';
                    nameSelect.disabled = !selectedCategoryId;
                    codeSelect.disabled = !selectedCategoryId;

                    if (!selectedCategoryId) return;

                    const filteredMaterials = materialData.filter(mat => mat.category.categoryId == selectedCategoryId);
                    console.log('Filtered materials:', filteredMaterials);

                    if (filteredMaterials.length > 0) {
                        filteredMaterials.forEach(mat => {
                            nameSelect.add(new Option(mat.name, mat.name));
                            codeSelect.add(new Option(mat.code, mat.code));
                        });

                        const updateUnit = () => {
                            const selected = filteredMaterials.find(m => m.name === nameSelect.value || m.code === codeSelect.value);
                            unitInput.value = selected ? selected.unit : "";
                        };

                        nameSelect.onchange = updateUnit;
                        codeSelect.onchange = updateUnit;
                    } else {
                        showAlert('warning', 'No materials found for this category.');
                    }
                };
            });
        }

        // Show alert
//        function showAlert(type, message) {
//            const alert = document.createElement('div');
//            alert.className = `alert alert-${type} alert-dismissible fade show`;
//            alert.role = 'alert';
//            alert.innerHTML = `
//                ${message}
//                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
//            `;
//            document.querySelector('.container').prepend(alert);
//            setTimeout(() => alert.remove(), 5000);
//        }

        // Update serial numbers for No. column
        function updateSerialNumbers() {
            const rows = document.querySelectorAll('#materialTableBody tr');
            rows.forEach((row, index) => {
                const serialCell = row.querySelector('.serial-number');
                if (serialCell) {
                    serialCell.textContent = index + 1;
                }
            });
        }

        // Update remove button states
        function updateRemoveButtons() {
            const rows = document.querySelectorAll('#materialTableBody tr');
            const removeButtons = document.querySelectorAll('.remove-row');
            const isSingleRow = rows.length === 1;
            removeButtons.forEach(button => {
                button.disabled = isSingleRow;
                button.classList.toggle('btn-disabled', isSingleRow);
            });
        }

        // Add new material row
        function addMaterialRow() {
            const tableBody = document.getElementById('materialTableBody');
            if (!tableBody) {
                console.error('Table body with ID "materialTableBody" not found.');
                showAlert('danger', 'Cannot add material: System error.');
                return;
            }
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="serial-number"></td>
                <td>
                    <select class="form-select parent-category-select" name="parentCategoryId[]" required>
                        <option value="">Select parent category</option>
                        <%
                            for (MaterialCategory cat : parentCategories) {
                        %>
                            <option value="<%= cat.getCategoryId()%>"><%= cat.getName()%></option>
                        <%
                            }
                        %>
                    </select>
                </td>
                <td>
                    <select class="form-select category-select" name="categoryId[]" required disabled>
                        <option value="">Select category</option>
                    </select>
                </td>
                <td>
                    <select class="form-select material-name-select" name="materialName[]" required disabled>
                        <option value="">-- Select material name --</option>
                    </select>
                </td>
                <td>
                    <select class="form-select material-code-select" name="materialCode[]" required disabled>
                        <option value="">-- Select material code --</option>
                    </select>
                </td>
                <td><input type="number" class="form-control" name="quantity[]" min="1" required></td>
                <td><input type="text" class="form-control unit-display" name="unit[]" readonly></td>
                <td>
                    <select class="form-select" name="condition[]" required>
                        <option value="">Select condition</option>
                        <option value="new">New</option>
                        <option value="used">Used</option>
                        <option value="damaged">Damaged</option>
                    </select>
                </td>
                <td><button type="button" class="btn btn-danger btn-sm remove-row">Delete</button></td>
            `;
            tableBody.appendChild(row);
            attachParentCategoryListener(row.querySelector('.parent-category-select'));
            updateSerialNumbers();
            updateRemoveButtons();
            showAlert('success', 'Added new material row.');
        }

        // Remove material row
        function removeRow(button) {
            const rows = document.querySelectorAll('#materialTableBody tr');
            if (rows.length <= 1) {
                showAlert('warning', 'Cannot delete: At least one material row is required.');
                return;
            }
            const row = button.closest('tr');
            if (!row) {
                showAlert('danger', 'Cannot delete row: System error.');
                return;
            }
            row.remove();
            updateSerialNumbers();
            updateRemoveButtons();
            showAlert('success', 'Deleted material row.');
        }

        // Bootstrap form validation
        (function () {
            'use strict';
            const forms = document.querySelectorAll('.needs-validation');
            Array.from(forms).forEach(form => {
                form.addEventListener('submit', event => {
                    if (!form.checkValidity() || !validateForm()) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
        })();

        // Client-side form validation
        function validateForm() {
            const purpose = document.getElementById('purpose').value.trim();
            const exportId = document.getElementById('exportId').value.trim();
            const voucherId = document.getElementById('voucherId').value.trim();
            const materialNames = document.getElementsByName('materialName[]');
            const materialCodes = document.getElementsByName('materialCode[]');
            const quantities = document.getElementsByName('quantity[]');
            const parentCategories = document.getElementsByName('parentCategoryId[]');
            const categories = document.getElementsByName('categoryId[]');
            const units = document.getElementsByName('unit[]');
            const conditions = document.getElementsByName('condition[]');
            const rows = document.querySelectorAll('#materialTableBody tr');

            // Clear previous error highlights
            rows.forEach(row => row.classList.remove('error-row'));

            // Validate purpose, exportId, and voucherId
            if (!exportId) {
                showAlert('danger', 'Export ID cannot be empty.');
                return false;
            }
            if (!voucherId) {
                showAlert('danger', 'Voucher ID cannot be empty.');
                return false;
            }
            if (!purpose) {
                showAlert('danger', 'Export purpose cannot be empty.');
                return false;
            }

            // Validate material rows
            if (materialNames.length === 0) {
                showAlert('danger', 'At least one material is required.');
                return false;
            }

            for (let i = 0; i < materialNames.length; i++) {
                if (!parentCategories[i].value) {
                    showAlert('danger', `Parent category cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!categories[i].value) {
                    showAlert('danger', `Category cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!materialNames[i].value.trim()) {
                    showAlert('danger', `Material name cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!materialCodes[i].value.trim()) {
                    showAlert('danger', `Material code cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!quantities[i].value || quantities[i].value <= 0) {
                    showAlert('danger', `Quantity must be greater than 0 at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!units[i].value) {
                    showAlert('danger', `Unit cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!conditions[i].value) {
                    showAlert('danger', `Condition cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
            }
            return true;
        }

        // Load materials and initialize listeners
        document.addEventListener("DOMContentLoaded", () => {
            const tableBody = document.getElementById('materialTableBody');
            const addButton = document.getElementById('addMaterialBtn');

            if (!tableBody || !addButton) {
                console.error('Required elements not found: materialTableBody or addMaterialBtn');
                showAlert('danger', 'System error: Table or add button not found.');
                return;
            }

            // Fetch materials
            fetch('${pageContext.request.contextPath}/exportMaterial', {
                method: 'GET',
                headers: {
                    'Accept': 'application/json'
                }
            })
                    .then(response => {
                        if (!response.ok) {
                            return response.text().then(errorText => {
                                throw new Error(`Server error: ${response.status} - ${errorText || 'No error details'}`);
                            });
                        }
                        return response.json();
                    })
                    .then(data => {
                        materialData = data;
                        console.log('Material data loaded:', materialData); // Log data for debugging
                        document.querySelectorAll(".parent-category-select").forEach(attachParentCategoryListener);
                    })
                    .catch(error => {
                        console.error('Error fetching materials:', error);
                        showAlert('danger', `Failed to load material data. Error: ${error.message}`);
                    });

            // Add row event
            addButton.addEventListener('click', addMaterialRow);

            // Remove row event
            tableBody.addEventListener('click', (event) => {
                if (event.target.classList.contains('remove-row')) {
                    removeRow(event.target);
                }
            });

            // Initialize serial numbers and remove button states
            updateSerialNumbers();
            updateRemoveButtons();

            // Highlight error row on page load
            <c:if test="${not empty errorRow}">
                const rows = document.querySelectorAll('#materialTableBody tr');
                if (rows[${errorRow}]) {
                    rows[${errorRow}].classList.add('error-row');
                } else {
                    console.warn('Error row index ${errorRow} is out of bounds.');
                }
            </c:if>
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>