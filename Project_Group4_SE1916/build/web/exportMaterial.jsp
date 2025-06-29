<%-- 
    Document   : exportMaterial
    Created on : Jun 9, 2025, 7:27:11 PM
    Author     : ASUS
--%>
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
        }
        .table th {
            background: #6e8efb;
            color: #fff;
            font-weight: 600;
        }
        .table th:first-child {
            width: 60px;
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
        .autocomplete-suggestions {
            position: absolute;
            border: 1px solid #ddd;
            border-radius: 4px;
            background: #fff;
            max-height: 200px;
            overflow-y: auto;
            z-index: 1000;
            width: 100%;
        }
        .autocomplete-suggestion {
            padding: 8px;
            cursor: pointer;
        }
        .autocomplete-suggestion:hover {
            background: #f0f0f0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="text-center mb-4">Export Materials</h1>

        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

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
                <input type="text" class="form-control" id="exportId" name="exportId" required maxlength="50" pattern="[A-Za-z0-9-_]+">
                <div class="invalid-feedback">Export ID is required, max 50 characters, alphanumeric, hyphens, or underscores only.</div>
            </div>

            <div class="mb-3">
                <label for="voucherId" class="form-label">Voucher ID</label>
                <input type="text" class="form-control" id="voucherId" name="voucherId" required maxlength="50" pattern="[A-Za-z0-9-_]+">
                <div class="invalid-feedback">Voucher ID is required, max 50 characters, alphanumeric, hyphens, or underscores only.</div>
            </div>    

            <div class="mb-3">
                <label for="purpose" class="form-label">Export Purpose</label>
                <textarea class="form-control" id="purpose" name="purpose" rows="3" required maxlength="500" pattern="[A-Za-z0-9\s,.()-]+"></textarea>
                <div class="invalid-feedback">Purpose is required, max 500 characters, alphanumeric, spaces, commas, periods, parentheses, or hyphens only.</div>
            </div>

            <div class="mb-3">
                <label class="form-label">Material List</label>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>No.</th>
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
                            <td style="position: relative;">
                                <input type="text" class="form-control material-name-input" name="materialName[]" required autocomplete="off">
                                <div class="autocomplete-suggestions" style="display: none;"></div>
                            </td>
                            <td><input type="text" class="form-control material-code-input" name="materialCode[]" readonly></td>
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
                <textarea class="form-control" id="additional printable" name="additionalNote" rows="3" maxlength="1000" pattern="[A-Za-z0-9\s,.()-]+"></textarea>
                <div class="invalid-feedback">Notes max 1000 characters, alphanumeric, spaces, commas, periods, parentheses, or hyphens only.</div>
            </div>

            <button type="submit" class="btn btn-primary">Save Export Voucher</button>
            <button type="reset" class="btn btn-info">Reset</button>
            <button type="button" class="btn btn-success" onclick="window.print()">Print Voucher</button>
            <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="btn btn-secondary">Back to Home</a>
        </form>
    </div>

    <script>
        // Initialize materialData
        let materialData = [];

        // Fetch materials from Servlet via AJAX
        async function fetchMaterials() {
            try {
                const response = await fetch('${pageContext.request.contextPath}/exportMaterial?fetch=materials');
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                const data = await response.json();
                materialData = data.map(item => ({
                    name: item.name || '',
                    code: item.code || '',
                    unit: item.unit || ''
                }));
                console.log("Material Data:", materialData);
                if (materialData.length === 0) {
                    showAlert('warning', 'No material data available.');
                }
            } catch (error) {
                console.error("Error fetching materials:", error);
                showAlert('error', 'Failed to load material data. Please try again.');
            }
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

        // Update serial numbers
        function updateSerialNumbers() {
            document.querySelectorAll('#materialTableBody tr').forEach((row, index) => {
                row.querySelector('.serial-number').textContent = index + 1;
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
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="serial-number"></td>
                <td style="position: relative;">
                    <input type="text" class="form-control material-name-input" name="materialName[]" required autocomplete="off">
                    <div class="autocomplete-suggestions" style="1"></div>
                </td>
                <td><input type="text" class="form-control material-code-input" name="materialCode[]" readonly></td>
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
            attachAutocomplete(row.querySelector('.material-name-input'));
            updateSerialNumbers();
            1;
            showAlert('success', 'Added new material row.');
        }

        // Remove material row
        function removeRow(button) {
            const rows = document.querySelectorAll('#materialTableBody tr');
            if (rows.length <= 1) {
                showAlert('warning', 'Cannot delete: At least one material row is required.');
                return;
            }
            button.closest('tr').remove();
            updateSerialNumbers();
            updateRemoveButtons();
            showAlert('success', 'Deleted material row.');
        }

        // Autocomplete functionality
        function attachAutocomplete(input) {
            input.addEventListener('input', function() {
                const value = this.value.toLowerCase();
                const suggestionsDiv = this.nextElementSibling;
                suggestionsDiv.innerHTML = '';
                suggestionsDiv.style.display = 'none';

                if (value) {
                    const matches = materialData.filter(mat => 
                        mat.name.toLowerCase().includes(value)
                    );
                    if (matches.length > 0) {
                        matches.forEach(mat => {
                            const suggestion = document.createElement('div');
                            suggestion.className = 'autocomplete-suggestion';
                            suggestion.textContent = mat.name;
                            suggestion.addEventListener('click', () => {
                                this.value = mat.name;
                                this.closest('tr').querySelector('.material-code-input').value = mat.code;
                                this.closest('tr').querySelector('.unit-display').value = mat.unit;
                                suggestionsDiv.style.display = 'none';
                            });
                            suggestionsDiv.appendChild(suggestion);
                        });
                        suggestionsDiv.style.display = 'block';
                    }
                }
            });

            input.addEventListener('blur', function() {
                setTimeout(() => {
                    this.nextElementSibling.style.display = 'none';
                }, 200);
            });
        }

        // Bootstrap form validation
        (function() {
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
            const exportId = document.getElementById('exportId').value.trim();
            const voucherId = document.getElementById('voucherId').value.trim();
            const purpose = document.getElementById('purpose').value.trim();
            const additionalNote = document.getElementById('additionalNote').value.trim();
            const materialNames = document.getElementsByName('materialName[]');
            const materialCodes = document.getElementsByName('materialCode[]');
            const quantities = document.getElementsByName('quantity[]');
            const units = document.getElementsByName('unit[]');
            const conditions = document.getElementsByName('condition[]');
            const rows = document.querySelectorAll('#materialTableBody tr');

            rows.forEach(row => row.classList.remove('error-row'));

            // Regex for allowed characters
            const idRegex = /^[A-Za-z0-9-_]+$/;
            const textRegex = /^[A-Za-z0-9\s,.()-]+$/;

            if (!exportId) {
                showAlert('error', 'Export ID cannot be empty.');
                return false;
            }
            if (exportId.length > 50) {
                showAlert('error', 'Export ID cannot exceed 50 characters.');
                return false;
            }
            if (!idRegex.test(exportId)) {
                showAlert('error', 'Export ID can only contain alphanumeric characters, hyphens, or underscores.');
                return false;
            }

            if (!voucherId) {
                showAlert('error', 'Voucher ID cannot be empty.');
                return false;
            }
            if (voucherId.length > 50) {
                showAlert('error', 'Voucher ID cannot exceed 50 characters.');
                return false;
            }
            if (!idRegex.test(voucherId)) {
                showAlert('error', 'Voucher ID can only contain alphanumeric characters, hyphens, or underscores.');
                return false;
            }

            if (!purpose) {
                showAlert('error', 'Export purpose cannot be empty.');
                return false;
            }
            if (purpose.length > 500) {
                showAlert('error', 'Export purpose cannot exceed 500 characters.');
                return false;
            }
            if (!textRegex.test(purpose)) {
                showAlert('error', 'Export purpose can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.');
                return false;
            }

            if (additionalNote && additionalNote.length > 1000) {               
                showAlert('error', 'Additional notes cannot exceed 1000 characters.');
                return false;
            }
            if (additionalNote && !textRegex.test(additionalNote)) {
                showAlert('error', 'Additional notes can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.');
                return false;
            }

            if (materialNames.length === 0) {
                showAlert('error', 'At least one material is required.');
                return false;
            }

            for (let i = 0; i < materialNames.length; i++) {
                if (!materialNames[i].value.trim()) {
                    showAlert('error', `Material name cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!materialCodes[i].value.trim()) {
                    showAlert('error', `Material code cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!quantities[i].value || quantities[i].value <= 0) {
                    showAlert('error', `Quantity must be greater than 0 at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!units[i].value) {
                    showAlert('error', `Unit cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!conditions[i].value) {
                    showAlert('error', `Condition cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
            }
            return true;
        }

        // Initialize
        document.addEventListener("DOMContentLoaded", () => {
            const tableBody = document.getElementById('materialTableBody');
            const addButton = document.getElementById('addMaterialBtn');

            if (!tableBody || !addButton) {
                console.error('Required elements not found');
                showAlert('error', 'System error: Table or add button not found.');
                return;
            }

            // Fetch materials and attach autocomplete
            fetchMaterials().then(() => {
                document.querySelectorAll(".material-name-input").forEach(attachAutocomplete);
            });

            // Add row event
            addButton.addEventListener('click', addMaterialRow);

            // Remove row event
            tableBody.addEventListener('click', (event) => {
                if (event.target.classList.contains('remove-row')) {
                    removeRow(event.target);
                }
            });

            updateSerialNumbers();
            updateRemoveButtons();

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