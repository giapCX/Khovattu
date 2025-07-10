
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
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
            <div class="flex items-center gap-4 mb-6">
                <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                    <i class="fas fa-bars text-2xl"></i>
                </button>
            </div>
            <div class="container max-w-6xl mx-auto">

                <h1 class="text-center mb-4" style="font-size: 30px">Export Materials</h1>

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
                        <label for="voucherId" class="form-label">Receipt ID</label>
                        <input type="text" class="form-control" id="voucherId" name="voucherId" required maxlength="50" pattern="[A-Za-z0-9-_]+">
                        <div class="invalid-feedback">Voucher ID is required, max 50 characters, alphanumeric, hyphens, or underscores only.</div>
                    </div>

                    <div class="mb-3">
                        <label for="receiver" class="form-label">Receiver</label>
                        <input type="text" class="form-control receiver-input" id="receiver" name="receiver" required autocomplete="off">
                        <div class="autocomplete-suggestions" style="display: none;"></div>
                        <div class="invalid-feedback">Please select a receiver.</div>
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
            let materialData = [];
            let employeeData = [];

            // Fetch materials from Servlet via AJAX
            async function fetchMaterials() {
                try {
                    const response = await fetch('${pageContext.request.contextPath}/exportMaterial?fetch=materials');
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    materialData = await response.json();
                    console.log("Material Data:", materialData);
                } catch (error) {
                    console.error("Error fetching materials:", error);
                }
            }

            // Fetch employees from Servlet via AJAX
            async function fetchEmployees() {
                try {
                    const response = await fetch('${pageContext.request.contextPath}/exportMaterial?fetch=employees');
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    employeeData = await response.json();
                    console.log("Employee Data:", employeeData);
                } catch (error) {
                    console.error("Error fetching employees:", error);
                }
            }

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
                    </td>
                `;
                tableBody.appendChild(row);
                attachMaterialAutocomplete(row.querySelector('.material-name-input'));
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

            // Autocomplete for materials
            function attachMaterialAutocomplete(input) {
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

            // Autocomplete for employees
            function attachEmployeeAutocomplete(input) {
                input.addEventListener('input', function () {
                    if (this.readOnly)
                        return;
                    const value = this.value.toLowerCase();
                    const suggestionsDiv = this.nextElementSibling;
                    suggestionsDiv.innerHTML = '';
                    suggestionsDiv.style.display = 'none';

                    if (value) {
                        const matches = employeeData.filter(emp =>
                            emp.fullName.toLowerCase().includes(value)
                        );
                        if (matches.length > 0) {
                            matches.forEach(emp => {
                                const suggestion = document.createElement('div');
                                suggestion.className = 'autocomplete-suggestion';
                                suggestion.textContent = emp.fullName;
                                suggestion.addEventListener('click', () => {
                                    this.value = emp.fullName;
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
                if (!checkFormValidity())
                    return;

                const exporter = document.querySelector('input[name="userFN"]').value;
                const voucherId = document.getElementById('voucherId').value;
                const receiver = document.getElementById('receiver').value;
                const purpose = document.getElementById('purpose').value;
                const requiredDate = document.getElementById('requiredDate').value;
                const additionalNote = document.getElementById('additionalNote').value;

                const data = [
                    ["Export Voucher"],
                    ["Exporter", exporter],
                    ["Receipt ID", voucherId],
                    ["Receiver", receiver],
                    ["Purpose", purpose],
                    ["Required Export Date", requiredDate],
                    ["Additional Notes", additionalNote || "None"],
                    [],
                    ["Material List"],
                    ["No.", "Material Name", "Material Code", "Quantity", "Unit", "Condition"]
                ];

                const materialRows = document.querySelectorAll('#materialTableBody tr');
                materialRows.forEach((row, index) => {
                    const materialName = row.querySelector('.material-name-input').value;
                    const materialCode = row.querySelector('.material-code-input').value;
                    const quantity = row.querySelector('input[name="quantity[]"]').value;
                    const unit = row.querySelector('.unit-display').value;
                    const condition = row.querySelector('select[name="condition[]"]').value;
                    data.push([index + 1, materialName, materialCode, parseInt(quantity), unit, condition]);
                });

                const ws = XLSX.utils.aoa_to_sheet(data);
                ws['A1'].s = {font: {bold: true}};
                ws['A9'].s = {font: {bold: true}};
                ws['A10'].s = {font: {bold: true}};
                ws['B10'].s = {font: {bold: true}};
                ws['C10'].s = {font: {bold: true}};
                ws['D10'].s = {font: {bold: true}};
                ws['E10'].s = {font: {bold: true}};
                ws['F10'].s = {font: {bold: true}};

                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Export Voucher");
                XLSX.writeFile(wb, `ExportVoucher_${voucherId}.xlsx`);
            }

            // Check form validity to enable/disable export button
            function checkFormValidity() {
                const isValid = validateForm();
                const exportBtn = document.getElementById('exportExcelBtn');
                exportBtn.disabled = !isValid;
                exportBtn.classList.toggle('btn-disabled', !isValid);
                return isValid;
            }

            // Client-side form validation
            function validateForm() {
                const voucherId = document.getElementById('voucherId').value.trim();
                const receiver = document.getElementById('receiver').value.trim();
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

                const idRegex = /^[A-Za-z0-9-_]+$/;
                const textRegex = /^[A-Za-z0-9\s,.()-]+$/;

                if (!voucherId || voucherId.length > 50 || !idRegex.test(voucherId)) {
                    rows[0].classList.add('error-row');
                    return false;
                }

                if (!receiver || !employeeData.some(emp => emp.fullName === receiver)) {
                    rows[0].classList.add('error-row');
                    return false;
                }

                if (!purpose || purpose.length > 500 || !textRegex.test(purpose)) {
                    rows[0].classList.add('error-row');
                    return false;
                }

                if (!requiredDate) {
                    rows[0].classList.add('error-row');
                    return false;
                }

                if (additionalNote && (additionalNote.length > 1000 || !textRegex.test(additionalNote))) {
                    rows[0].classList.add('error-row');
                    return false;
                }

                if (materialNames.length === 0) {
                    return false;
                }

                for (let i = 0; i < materialNames.length; i++) {
                    if (!materialNames[i].value.trim() || !materialCodes[i].value.trim() ||
                            !quantities[i].value || quantities[i].value <= 0 ||
                            !units[i].value || !conditions[i].value) {
                        rows[i].classList.add('error-row');
                        return false;
                    }
                }

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
                const receiverInput = document.getElementById('receiver');

                if (!tableBody || !addButton || !exportButton || !receiverInput) {
                    console.error('Required elements not found');
                    return;
                }

                // Fetch data and attach autocompletes
                Promise.all([fetchMaterials(), fetchEmployees()]).then(() => {
                    document.querySelectorAll(".material-name-input").forEach(attachMaterialAutocomplete);
                    attachEmployeeAutocomplete(receiverInput);
                });

                // Add row event
                addButton.addEventListener('click', addMaterialRow);

                // Export to Excel event
                exportButton.addEventListener('click', exportToExcel);

                // Remove row event
                tableBody.addEventListener('click', (event) => {
                    if (event.target.classList.contains('remove-row')) {
                        removeRow(event.target);
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