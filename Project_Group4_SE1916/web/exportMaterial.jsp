
<%-- 
    Document   : exportMaterial
    Created on : Jun 9, 2025, 7:27:11 PM
    Author     : ASUS
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Export Materials</title>
        <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <!-- Liên kết đến file CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
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
            .btn-danger, .btn-secondary, .btn-success, .btn-info, .btn-warning, .btn-dark {
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
            select.locked {
                pointer-events: none;
                background-color: #e9ecef;
                color: #6c757d;
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">
        <%
            String role = (String) session.getAttribute("role");
            String userFullName = (String) session.getAttribute("userFullName") != null ? (String) session.getAttribute("userFullName") : "Not Identified";
        %>
        <!-- Sidebar -->
        <c:choose>
            <c:when test="${role == 'admin'}">
                <jsp:include page="/view/sidebar/sidebarAdmin.jsp" />
            </c:when>
            <c:when test="${role == 'direction'}">
                <jsp:include page="/view/sidebar/sidebarDirection.jsp" />
            </c:when>
            <c:when test="${role == 'warehouse'}">
                <jsp:include page="/view/sidebar/sidebarWarehouse.jsp" />
            </c:when>
            <c:when test="${role == 'employee'}">
                <jsp:include page="/view/sidebar/sidebarEmployee.jsp" />
            </c:when>
        </c:choose>
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="container max-w-6xl mx-auto">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
<!--                    <h1 class="text-center mb-4" style="font-size: 30px; margin-left: 300px">Export Materials</h1>-->
                </div>
                <h1 class="text-center mb-4 " style="font-size: 30px">Export Materials</h1>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        ${fn:escapeXml(error)}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <c:if test="${not empty message}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        ${fn:escapeXml(message)} (Export ID: ${fn:escapeXml(exportId)})
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/exportMaterial" method="post" class="needs-validation" novalidate>
                    <div class="mb-3">
                        <label for="userFN" class="form-label">Exporter</label>
                        <input type="text" name="userFN" class="form-control" value="${fn:escapeXml(sessionScope.userFullName != null ? sessionScope.userFullName : 'Not Identified')}" readonly>
                        <c:if test="${empty sessionScope.userFullName}">
                            <p class="error mt-2">Not logged in or user information is missing. Please log in again.</p>
                        </c:if>
                    </div>

                    <div class="mb-3">
                        <label for="exportId" class="form-label">Export ID</label>
                        <input type="text" class="form-control" id="exportId" name="exportId" value="${fn:escapeXml(exportId)}" readonly>
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
                                    <td>
                                        <button type="button" class="btn btn-danger btn-sm remove-row" disabled>Delete</button>
                                        <button type="button" class="btn btn-success btn-sm edit-row">Save</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <button type="button" class="btn btn-secondary" id="addMaterialBtn">Add Row</button>
                    </div>

                    <div class="mb-3">
                        <label for="requiredDate" class="form-label">Required Export Date</label>
                        <input type="date" class="form-control" id="requiredDate" name="requiredDate" required>
                        <div class="invalid-feedback">Please select the required export date.</div>
                    </div>

                    <div class="mb-3">
                        <label for="additionalNote" class="form-label">Additional Notes</label>
                        <textarea class="form-control" id="additionalNote" name="additionalNote" rows="3" maxlength="1000" pattern="[A-Za-z0-9\s,.()-]+"></textarea>
                        <div class="invalid-feedback">Notes max 1000 characters, alphanumeric, spaces, commas, periods, parentheses, or hyphens only.</div>
                    </div>

                    <button type="submit" class="btn btn-primary">Save Export</button>
                    <button type="reset" class="btn btn-info">Reset</button>
                    <button type="button" class="btn btn-success" id="exportExcelBtn" disabled>Export to Excel</button>
                    <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="btn btn-secondary">Back to Home</a>
                </form>
            </div>
        </main>
        
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
                    
                } catch (error) {
                    console.error("Error fetching materials:", error);
                    
                }
            }

            // Show alert
//            function showAlert(type, message) {
//                const alert = document.createElement('div');
//                alert.className = `alert alert-${type} alert-dismissible fade show`;
//                alert.role = 'alert';
//                alert.innerHTML = `
//                    ${message}
//                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
//                `;
//                document.querySelector('.container').prepend(alert);
//                setTimeout(() => alert.remove(), 5000);
//            }

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
                    <td>
                        <button type="button" class="btn btn-danger btn-sm remove-row" disabled>Delete</button>
                        <button type="button" class="btn btn-success btn-sm edit-row">Save</button>
                    </td>
                `;
                tableBody.appendChild(row);
                attachAutocomplete(row.querySelector('.material-name-input'));
                updateSerialNumbers();
                updateRemoveButtons();                
                checkFormValidity();
            }

            // Remove material row
            function removeRow(button) {
                const rows = document.querySelectorAll('#materialTableBody tr');
                if (rows.length <= 1) {                    
                    return;
                }
                button.closest('tr').remove();
                updateSerialNumbers();
                updateRemoveButtons();
                checkFormValidity();
            }

            // Toggle edit mode for a row
            function toggleEditRow(button) {
                const row = button.closest('tr');
                const isEditing = button.textContent === 'Save';
                const materialNameInput = row.querySelector('.material-name-input');
                const quantityInput = row.querySelector('input[name="quantity[]"]');
                const conditionSelect = row.querySelector('select[name="condition[]"]');

                if (isEditing) {
                    // Validate
                    if (!materialNameInput.value.trim()) {                        
                        row.classList.add('error-row');
                        return;
                    }
                    if (!quantityInput.value || quantityInput.value <= 0) {                        
                        row.classList.add('error-row');
                        return;
                    }
                    if (!conditionSelect.value) {                      
                        row.classList.add('error-row');
                        return;
                    }

                    // Lock inputs
                    materialNameInput.readOnly = true;
                    quantityInput.readOnly = true;
                    conditionSelect.classList.add('locked');
                    conditionSelect.setAttribute('data-locked', 'true');
                    conditionSelect.addEventListener('mousedown', preventSelectDropdown);

                    button.textContent = 'Edit';
                    button.classList.remove('btn-success');
                    button.classList.add('btn-warning');
                    row.classList.remove('error-row');
                } else {
                    // Edit mode: unlock inputs
                    materialNameInput.readOnly = false;
                    quantityInput.readOnly = false;
                    conditionSelect.classList.remove('locked');
                    conditionSelect.removeAttribute('data-locked');
                    conditionSelect.removeEventListener('mousedown', preventSelectDropdown);

                    button.textContent = 'Save';
                    button.classList.remove('btn-warning');
                    button.classList.add('btn-success');
                }
                checkFormValidity();
            }

            function preventSelectDropdown(e) {
                e.preventDefault();
            }

            // Autocomplete functionality
            function attachAutocomplete(input) {
                input.addEventListener('input', function () {
                    if (this.readOnly)
                        return;
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
                                    checkFormValidity();
                                });
                                suggestionsDiv.appendChild(suggestion);
                            });
                            suggestionsDiv.style.display = 'block';
                        }
                    }
                });

                input.addEventListener('blur', function () {
                    setTimeout(() => {
                        this.nextElementSibling.style.display = 'none';
                    }, 200);
                });
            }

            // Export to Excel functionality
            function exportToExcel() {
                const exporter = document.querySelector('input[name="userFN"]').value;               
                const voucherId = document.getElementById('voucherId').value;
                const purpose = document.getElementById('purpose').value;
                const requiredDate = document.getElementById('requiredDate').value;
                const additionalNote = document.getElementById('additionalNote').value;

                // Create data for Excel
                const data = [
                    ["Export Voucher"],
                    ["Exporter", exporter],
                    ["Voucher ID", voucherId],
                    ["Purpose", purpose],
                    ["Required Export Date", requiredDate],
                    ["Additional Notes", additionalNote || "None"],
                    [],
                    ["Material List"],
                    ["No.", "Material Name", "Material Code", "Quantity", "Unit", "Condition"]
                ];

                // Add material rows
                const materialRows = document.querySelectorAll('#materialTableBody tr');
                materialRows.forEach((row, index) => {
                    const materialName = row.querySelector('.material-name-input').value;
                    const materialCode = row.querySelector('.material-code-input').value;
                    const quantity = row.querySelector('input[name="quantity[]"]').value;
                    const unit = row.querySelector('.unit-display').value;
                    const condition = row.querySelector('select[name="condition[]"]').value;
                    data.push([index + 1, materialName, materialCode, parseInt(quantity), unit, condition]);
                });

                // Create worksheet
                const ws = XLSX.utils.aoa_to_sheet(data);

                // Optional: Add basic styling
                ws['A1'].s = {font: {bold: true}};
                ws['A9'].s = {font: {bold: true}};
                
                ws['B10'].s = {font: {bold: true}};
                ws['C10'].s = {font: {bold: true}};
                ws['D10'].s = {font: {bold: true}};
                ws['E10'].s = {font: {bold: true}};
                ws['F10'].s = {font: {bold: true}};

                // Create workbook
                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Export Voucher");

                // Generate and download Excel file
                XLSX.writeFile(wb, `ExportVoucher_${voucherId}.xlsx`);
            }

            // Check if all rows are saved
            function areAllRowsSaved() {
                const rows = document.querySelectorAll('#materialTableBody tr');
                for (let row of rows) {
                    const saveButton = row.querySelector('.edit-row');
                    if (saveButton.textContent === 'Save') {
                        return false;
                    }
                }
                return true;
            }

            // Check form validity to enable/disable export button
            function checkFormValidity() {
                const isValid = validateForm();
                const exportBtn = document.getElementById('exportExcelBtn');
                exportBtn.disabled = !isValid;
                exportBtn.classList.toggle('btn-disabled', !isValid);
            }



            // Client-side form validation
            function validateForm() {
                const voucherId = document.getElementById('voucherId').value.trim();
                const purpose = document.getElementById('purpose').value.trim();
                const requiredDate = document.getElementById('requiredDate').value;
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

                // Check if all rows are saved
//                if (!areAllRowsSaved()) {
//                    showAlert('error', 'Please save all material rows before submitting.');
//                    return false;
//                }
//
//                if (!voucherId) {
//                    showAlert('error', 'Voucher ID cannot be empty.');
//                    return false;
//                }
//                if (voucherId.length > 50) {
//                    showAlert('error', 'Voucher ID cannot exceed 50 characters.');
//                    return false;
//                }
//                if (!idRegex.test(voucherId)) {
//                    showAlert('error', 'Voucher ID can only contain alphanumeric characters, hyphens, or underscores.');
//                    return false;
//                }
//
//                if (!purpose) {
//                    showAlert('error', 'Export purpose cannot be empty.');
//                    return false;
//                }
//                if (purpose.length > 500) {
//                    showAlert('error', 'Export purpose cannot exceed 500 characters.');
//                    return false;
//                }
//                if (!textRegex.test(purpose)) {
//                    showAlert('error', 'Export purpose can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.');
//                    return false;
//                }
//
//                if (!requiredDate) {
//                    showAlert('error', 'Required export date cannot be empty.');
//                    return false;
//                }
//
//                if (additionalNote && additionalNote.length > 1000) {
//                    showAlert('error', 'Additional notes cannot exceed 1000 characters.');
//                    return false;
//                }
//                if (additionalNote && !textRegex.test(additionalNote)) {
//                    showAlert('error', 'Additional notes can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.');
//                    return false;
//                }
//
//                if (materialNames.length === 0) {
//                    showAlert('error', 'At least one material is required.');
//                    return false;
//                }

//                for (let i = 0; i < materialNames.length; i++) {
//                    if (!materialNames[i].value.trim()) {
//                        showAlert('error', `Material name cannot be empty at row ${i + 1}`);
//                        rows[i].classList.add('error-row');
//                        return false;
//                    }
//                    if (!materialCodes[i].value.trim()) {
//                        showAlert('error', `Material code cannot be empty at row ${i + 1}`);
//                        rows[i].classList.add('error-row');
//                        return false;
//                    }
//                    if (!quantities[i].value || quantities[i].value <= 0) {
//                        showAlert('error', `Quantity must be greater than 0 at row ${i + 1}`);
//                        rows[i].classList.add('error-row');
//                        return false;
//                    }
//                    if (!units[i].value) {
//                        showAlert('error', `Unit cannot be empty at row ${i + 1}`);
//                        rows[i].classList.add('error-row');
//                        return false;
//                    }
//                    if (!conditions[i].value) {
//                        showAlert('error', `Condition cannot be empty at row ${i + 1}`);
//                        rows[i].classList.add('error-row');
//                        return false;
//                    }
//                }
                return true;
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
                    form.querySelectorAll('input, textarea, select').forEach(input => {
                        input.addEventListener('input', checkFormValidity);
                        input.addEventListener('change', checkFormValidity);
                    });
                });
            })();

            // Initialize
            document.addEventListener("DOMContentLoaded", () => {
                const tableBody = document.getElementById('materialTableBody');
                const addButton = document.getElementById('addMaterialBtn');
                const exportButton = document.getElementById('exportExcelBtn');

                if (!tableBody || !addButton || !exportButton) {
                    console.error('Required elements not found');                    
                    return;
                }

                // Fetch materials and attach autocomplete
                fetchMaterials().then(() => {
                    document.querySelectorAll(".material-name-input").forEach(attachAutocomplete);
                });

                // Add row event
                addButton.addEventListener('click', addMaterialRow);

                // Export to Excel event
                exportButton.addEventListener('click', exportToExcel);

                // Remove row and edit row events
                tableBody.addEventListener('click', (event) => {
                    if (event.target.classList.contains('remove-row')) {
                        removeRow(event.target);
                    } else if (event.target.classList.contains('edit-row')) {
                        toggleEditRow(event.target);
                    }
                });

                updateSerialNumbers();
                updateRemoveButtons();
                checkFormValidity();

            <c:if test="${not empty errorRow && errorRow >= 0}">
                const rows = document.querySelectorAll('#materialTableBody tr');
                if (rows[${fn:escapeXml(errorRow)}]) {
                    rows[${fn:escapeXml(errorRow)}].classList.add('error-row');
                } else {
                    console.warn('Error row index ${fn:escapeXml(errorRow)} is out of bounds.');
                }
            </c:if>
            });
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>